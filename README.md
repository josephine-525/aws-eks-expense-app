# expenseapp

Application code for the expense demo — one piece of an 8-repo EKS platform-engineering project. See [`aws-eks-gitops-platform`](https://github.com/josephine-525/aws-eks-gitops-platform) for the full picture (architecture diagram, why it's split into 8 repos, the platform's isolation/GitOps layer).

This repo builds two Docker images and deploys them onto EKS via the shared [`aws-eks-helm-charts`](https://github.com/josephine-525/aws-eks-helm-charts) chart — it does **not** contain any Kubernetes manifests of its own (those live in the chart), and doesn't touch Lambda or ECS (both retired when the project moved to an EKS-only, `terraform-live`-based infra layout — see "AWS runtime" note further down for why they existed at all).

| Directory | Contents |
|-----------|----------|
| `frontend/` | `index.html.tpl` + `render_build.py` (template rendered at Docker build time) and `Dockerfile`/`nginx-eks.conf` |
| `backend/` | `server.py` + `Dockerfile` (Flask app, EKS / local HTTP) |
| `dashboards/` | Grafana dashboard as code, delivered by the `aws-eks-observability` repo's ApplicationSet, not by this repo's own CI |

Infrastructure (Terraform) lives in [`aws-eks-infra`](https://github.com/josephine-525/aws-eks-infra); the actual Kubernetes manifests this app deploys as live in [`aws-eks-helm-charts`](https://github.com/josephine-525/aws-eks-helm-charts).

### Local Docker

From this repo root:

```bash
docker compose up --build
```

- UI: [http://localhost:3000](http://localhost:3000) (static `index.html` built with `API_BASE=http://localhost:8080`)
- API: [http://localhost:8080](http://localhost:8080) (`/expenses`, `/months`, `/summary`)
- DynamoDB Local: port `8000`; the backend creates `expenses-local` on first start when `DYNAMODB_ENDPOINT` is set.

For production-like API URLs in the browser (e.g. behind another host), rebuild the frontend image with `docker compose build --build-arg API_BASE=https://your-api.example frontend` (see `docker-compose.yml` `frontend.build.args`).

### GitLab CI → ECR → EKS (terraform-live/dev)

Rewritten 2026-09-21, twice the same day. First pass made this repo's CI EKS-only (the old lambda/ecs paths had nothing left to target — `terraform-live`'s compute module is EKS-only). Second pass split out everything not actually specific to this app:

| Repo | Responsibility |
|---|---|
| [`ci-templates`](../ci-templates) | Reusable `build_push_image` job template (`include`d below) — generic Docker build/tag/push, parameterized by Dockerfile path/ECR repo name |
| **expenseapp** (this repo) | `build-backend`/`build-frontend` (extend the template with this app's own params) + `deploy-values` (bump this app's own `values-backend.yaml`/`values-frontend.yaml` image tag and `ingress/team-payments-ingress.yaml`'s ALB security group ID, push, wait for its own Applications/Deployments/Ingress) |
| [`gitops`](../gitops) | Platform bootstrap pipeline (LBC/metrics-server/ArgoCD installs, ArgoCD repo-creds Secrets, applying its own Application/ApplicationSet files) — cluster-lifecycle work, not per-app, run once per fresh cluster |

**Required run order**: `expenseinfra` compute apply → `gitops`'s bootstrap pipeline → **this repo's** pipeline (manual trigger, GitLab → CI/CD → Pipelines → "Run pipeline", not on every push).

**Image tags**: `$CI_COMMIT_SHORT_SHA` (no SSM counter — `terraform-live` never had one, a commit-SHA tag needs no extra state and is directly traceable). Images push as `:$CI_COMMIT_SHORT_SHA` and `:latest`.

Set **GitLab CI/CD variables** on this project: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION` (this identity needs an EKS access entry already granted via `expenseinfra`'s `EKS_CI_PRINCIPAL_ARN`) and `GITOPS_PUSH_TOKEN` (write_repository, scoped to this project — pushes the tag/SG-ID bump commit). `GRAFANA_ADMIN_PASSWORD`/`GITOPS_READ_TOKEN` now live on the `gitops` project instead, not here. ECR repo names (`demoapp-backend`/`-frontend`) and the EKS cluster name (`demoapp-dev-expense-eks`) are hardcoded rather than derived from one shared prefix — conflating those two was a real bug (see `expenseinfra/README.md`'s troubleshooting log).

After deploy, `deploy-values`' final log lines print the live ALB hostname to open the app at.

### AWS runtime: why Lambda/ECS aren't here anymore (historical)

This app originally ran on Lambda, ECS Fargate, and EKS from the same codebase, specifically to compare them with a real workload rather than on paper — see `aws-eks-infra`'s README for that trade-off table. EKS won on "most real design surface to learn from," not "best fit for this toy app" (it's the highest-overhead option of the three). Once EKS was chosen, `expenseinfra` moved to a layered, EKS-only Terraform setup with nowhere for the Lambda/ECS paths to deploy to, so this repo's CI dropped them at the same time — the Lambda handler and Docker-Compose-only ECS paths in this repo are dead code kept for reference, not a currently-exercised deployment target.

---

## GitLab CI → EKS (when infra uses `enable_expense_eks`) — RETIRED FLOW, historical reference only

> **This whole section describes the pre-`terraform-live` flow, which no longer runs.** The old templates live in `k8s_deprecated/` now (renamed from `k8s/` 2026-09-21, kept for reference, not deleted). See "GitLab CI → ECR → EKS (terraform-live/dev)" near the top of this README for what's actually live today (`ci-templates`/`gitops`/this repo, `team-payments` namespace, `common-web-service` chart).

`deploy-eks` in `.gitlab-ci.yml` builds images (same `resolve-version`/`IMAGE_VERSION` flow as ECS), then:

1. Installs/updates the **AWS Load Balancer Controller** (Helm), reading `vpcId` from `aws eks describe-cluster` and the IRSA role ARN from SSM (see expenseinfra README's Observability section).
2. Installs/updates **kube-prometheus-stack** and **ArgoCD** (Helm) — see the two sections below.
3. Renders `k8s_deprecated/eks-serviceaccount.yaml` / `k8s_deprecated/eks-workload.yaml` (`envsubst`) into `k8s_deprecated/rendered/`, commits, and pushes — **ArgoCD applies them**, not this job directly.
4. Waits for the ArgoCD `Application` to reach `Synced` + `Healthy`, then checks pod rollout status and waits for the ALB hostname.

Required GitLab CI/CD variables beyond the ECS ones: `GRAFANA_ADMIN_PASSWORD` (masked) and `GITOPS_PUSH_TOKEN` (masked — see GitOps section). `EKS_EXPENSE_BACKEND_ROLE_ARN`, `EKS_AWS_LBC_ROLE_ARN`, `EKS_ALB_SG_ID` are **not** CI variables — they're read from SSM at deploy time (published by expenseinfra).

---

## Resiliency & Autoscaling (EKS)

Defined in [`aws-eks-helm-charts`](https://github.com/josephine-525/aws-eks-helm-charts)'s `common-web-service` chart (`templates/hpa.yaml`, `templates/pdb.yaml`), turned on per-release via this repo's `values-backend.yaml`/`values-frontend.yaml`: both start at **2 replicas** and are managed by a **`HorizontalPodAutoscaler`** (CPU target 70%, `minReplicas: 2` / `maxReplicas: 5`) — deliberately modest given this cluster runs small nodes with no Cluster Autoscaler; a higher ceiling would just produce `Pending` pods instead of an actual scale-up. HPA reads from the **`metrics-server`** API (`metrics.k8s.io`). Sanity check after a fresh deploy: `kubectl top nodes` / `kubectl top pods -n team-payments` should return real numbers; if the HPA's `TARGETS` column shows `<unknown>/70%`, check `kubectl logs -n kube-system -l app.kubernetes.io/name=metrics-server` first.

Each Deployment also has a **`PodDisruptionBudget`** — `maxUnavailable: 1`, not a fixed `minAvailable`, since replica count now moves with load. A fixed `minAvailable: 2` would block **all** voluntary eviction the moment HPA scales down to its floor of 2 replicas — a node drain during a cluster upgrade would then hang instead of proceeding pod-by-pod.

This resiliency layer was exercised for real during an EKS control-plane + node-group upgrade (1.34 → 1.35, see `aws-eks-infra` README's "EKS version upgrades" section) — at the time, before HPA existed, both Deployments ran a fixed **3 replicas** with `minAvailable: 2`. A node holding 2 of a Deployment's 3 replicas got drained, and the PDB forced the eviction API to replace those pods **one at a time** instead of both at once, keeping at least 2/3 capacity online throughout. Zero pod-level downtime, verified by restart counts staying at 0.

Combined with `topologySpreadConstraints` (spread across nodes/AZs — see `aws-eks-infra` README), this is the actual safety net behind any voluntary disruption: node group upgrades, `kubectl drain`, cluster scaling — not just a config that looks correct on paper.

> **Gotcha: ArgoCD's `selfHeal` fights the HPA if you don't tell it not to.** ArgoCD's `syncPolicy.automated.selfHeal: true` reverts any live-cluster drift from what's declared in git — and by default that includes `spec.replicas`. The moment HPA scales a Deployment away from the chart's declared value, ArgoCD sees that as drift and forces it back on the next sync, undoing the scale-up every time. Fixed with `spec.ignoreDifferences` on the Applications in [`aws-eks-gitops-platform`](https://github.com/josephine-525/aws-eks-gitops-platform), excluding `/spec/replicas` so ArgoCD stops diffing that field and leaves it entirely to the HPA.

---

## Monitoring & Observability (EKS)

**Metrics — kube-prometheus-stack** (Prometheus + Grafana + node-exporter + kube-state-metrics + Alertmanager), namespace `monitoring`, deployed as its own ArgoCD Application (values from [`aws-eks-observability`](https://github.com/josephine-525/aws-eks-observability), see `aws-eks-gitops-platform`). Storage is **ephemeral (emptyDir)** — no EBS CSI driver in this cluster, and metrics history isn't worth persisting for a learning cluster; history is lost on pod restart.

No public Ingress for Grafana/Prometheus (same "port-forward only" policy as everything else internal in this project):

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3001:80      # http://localhost:3001, user: admin
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

**Custom dashboard, checked in as code**: `dashboards/expense-grafana-dashboard.yaml` is a `ConfigMap` labeled `grafana_dashboard: "1"` — the same mechanism kube-prometheus-stack's own bundled dashboards use. The Grafana sidecar watches for this label and loads/updates the dashboard automatically; no manual "import dashboard" step. Panels: CPU, memory, container restarts, network I/O, pod count, and nginx request rate — all scoped to `namespace="team-payments"` (was hardcoded to a stale `namespace="expense"` from before the multi-tenant rename; fixed once the dashboard was actually opened and every panel was empty — see `aws-eks-infra`'s troubleshooting log). Lives in its own top-level `dashboards/` directory (not `k8s/`) because it's delivered by the [`aws-eks-observability`](https://github.com/josephine-525/aws-eks-observability) repo's `dashboards` ApplicationSet, not by this repo's own CI/ArgoCD flow.

**Frontend request metrics**: nginx doesn't expose Prometheus metrics natively. The `common-web-service` chart's frontend Deployment runs an **`nginx-prometheus-exporter` sidecar** that scrapes nginx's `stub_status` (enabled in `frontend/nginx-eks.conf`, restricted to `127.0.0.1`) and re-exposes it as `/metrics` on `:9113`. A `ServiceMonitor` tells Prometheus to scrape it.

> **Gotcha worth remembering:** `ServiceMonitor.spec.selector` matches labels on the **Service object itself** (`metadata.labels`), not `spec.selector` (which is how the Service finds Pods) — two unrelated fields that happen to share the name "selector". Also, kube-prometheus-stack's Prometheus only watches `ServiceMonitor`/`PodMonitor` objects carrying the label `release: kube-prometheus-stack` (its `serviceMonitorSelector`) — miss either one and Prometheus silently drops the target (shows up under `droppedTargets`, not an error).

**Logs + Container Insights (CloudWatch)** — installed by **expenseinfra**, not this repo:

```
/aws/containerinsights/{cluster}/application   # pod stdout/stderr
/aws/containerinsights/{cluster}/host          # node-level logs
/aws/containerinsights/{cluster}/dataplane     # kubelet / container runtime
```

CloudWatch console → **Container Insights → Performance monitoring** for CPU/mem dashboards without needing Grafana.

---

## GitOps (ArgoCD)

**ArgoCD itself is installed and owned by [`aws-eks-gitops-platform`](https://github.com/josephine-525/aws-eks-gitops-platform), not this repo.** This repo's only role in the GitOps flow is: `deploy-values` bumps the image tag in `values-backend.yaml`/`values-frontend.yaml`, commits, and pushes. ArgoCD (watching this repo as one of its `Application` sources) detects the diff and syncs — this repo's CI never runs `kubectl apply` or touches the cluster directly.

```
CI builds + pushes image → bumps values-*.yaml tag → git commit + push → ArgoCD (in aws-eks-gitops-platform) detects the diff → syncs
```

⚠️ **`selfHeal: true` (set in the Application, in `aws-eks-gitops-platform`) means manual `kubectl apply`/`kubectl edit` against the live Deployments gets silently reverted.** To change something, edit `values-backend.yaml`/`values-frontend.yaml` here and let CI push — don't hand-edit the live objects.

**`GITOPS_PUSH_TOKEN`** (masked CI variable on this project) is a GitLab personal access token scoped to this repo, used only for CI's own `git push` of the tag bump. ArgoCD's *read* credential for cloning this repo is a separate token, configured once in `aws-eks-gitops-platform`'s bootstrap pipeline — not something this repo's CI manages.

> **Gotcha worth remembering** (hit setting up the read side in `aws-eks-gitops-platform`): GitLab **fine-grained personal access tokens** split read and write into separate permissions under "Code" — granting only the write/commit permission is **not** enough for ArgoCD to clone a repo. It needs **`Code: Download`** explicitly. The error surfaces as `Access denied: ... requires ... [Code: Download]` in the `Application`'s `status.conditions`, with `sync.status` stuck at `Unknown`.

**Troubleshooting specific to this repo's own CI**

| Symptom | Cause | Fix |
|---------|-------|-----|
| `git push` rejected: "Updates were rejected because a pushed branch tip is behind" | CI's checkout was behind `origin/main` (e.g. a previous retried job already pushed a commit) — a non-fast-forward rejection, **not** an auth error | `git fetch origin "$CI_DEFAULT_BRANCH" && git checkout -B "$CI_DEFAULT_BRANCH" "origin/$CI_DEFAULT_BRANCH"` before bumping/committing, every run |

See `aws-eks-gitops-platform`'s README for ArgoCD-side troubleshooting (sync failures, AppProject scoping, RBAC) and `aws-eks-infra`'s README for the full cross-repo troubleshooting log.

