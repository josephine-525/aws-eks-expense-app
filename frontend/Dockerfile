FROM python:3.12-alpine AS render
ARG API_BASE=http://localhost:8080
ENV API_BASE=${API_BASE}
WORKDIR /src
COPY index.html.tpl render_build.py ./
RUN python3 render_build.py

FROM nginx:1.27-alpine
ARG EKS_PROXY=0
COPY --from=render /src/index.html /usr/share/nginx/html/index.html
COPY nginx.conf nginx-eks.conf /tmp/
RUN if [ "$EKS_PROXY" = "1" ]; then cp /tmp/nginx-eks.conf /etc/nginx/conf.d/default.conf; else cp /tmp/nginx.conf /etc/nginx/conf.d/default.conf; fi \
    && rm -f /tmp/nginx.conf /tmp/nginx-eks.conf
