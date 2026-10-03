# Frontend

Single-page UI: `index.html.tpl` (Terraform `templatefile` injects `${api_base}` at deploy time).

Deployed by **expenseinfra** Terraform (S3 + CloudFront). Clone **expenseapp** next to **expenseinfra** (`learning/expenseapp` and `learning/expenseinfra`) or set `expenseapp_repo_path` when running `terraform apply`.
