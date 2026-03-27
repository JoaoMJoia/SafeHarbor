# Observability Stack (High Level)

This folder contains Helm values and Kubernetes manifests used to run a shared observability platform in the `infrastructure` namespace.

At a high level, the stack provides:
- **Metrics** with Prometheus (`kube-prometheus-stack`)
- **Logs** with Loki (+ Promtail log shipping)
- **Dashboards and alerting UX** with Grafana
- **Synthetic checks** with Blackbox Exporter
- **Application telemetry ingestion** with Grafana Alloy (including Faro receiver)
- **Notification delivery** to Microsoft Teams (Alertmanager and Grafana alerting routes)

## Components

- `kube-prometheus.yaml`
  - Core monitoring stack (`kube-prometheus-stack`)
  - Prometheus, Alertmanager, Grafana, and operator-level configuration
  - Includes Grafana data sources (Loki, CloudWatch, GitHub) and alerting policies/contact points

- `loki.yaml`
  - Loki deployment and storage configuration
  - Uses S3-backed storage settings and gateway exposure

- `promtail.yaml`
  - Log collection agent configuration (ships container logs into Loki)

- `grafana-alloy.yaml`
  - Alloy setup to forward telemetry to Prometheus and Loki
  - Enables Faro receiver for frontend/browser telemetry ingestion

- `blackbox-exporter.yaml`
  - Probing configuration for uptime/synthetic monitoring targets

- `prometheus-msteams.yaml`
  - Connector used by Alertmanager webhook receivers to deliver alerts to MS Teams

## Folder Structure

- `grafana-dashboards/`
  - Curated dashboard definitions (Kubernetes, autoscaling, WAF, AWS services, GitHub, application logs)
  - Loaded by Grafana sidecar using dashboard labels

- `grafana-alerts/`
  - Grafana-managed alert rule definitions for specific app/use-case scenarios

- `prometheus-additional-alerts/`
  - Additional `PrometheusRule` resources extending default rule coverage

## Data Flow (Conceptual)

1. Cluster and app metrics are scraped by Prometheus.
2. Logs are shipped by Promtail into Loki.
3. Alloy receives app telemetry and forwards to Prometheus/Loki destinations.
4. Grafana reads from Prometheus, Loki, CloudWatch, and GitHub data sources.
5. Alert rules (Prometheus and Grafana) route notifications to MS Teams channels.

## Deployment Notes

- Manifests in this folder are values/configuration files consumed by Helm charts.
- Typical rollout pattern:
  1. Add/update required Helm repos
  2. Install/upgrade each chart with its corresponding values file
  3. Apply extra dashboards and alert manifests
- Keep namespace assumptions aligned (`infrastructure` is referenced across files).

## CI/CD Workflow

The stack is automated by the GitHub Actions workflow:
- `.github/workflows/helm-eks-observability-stack.yaml`

### Trigger mode

- The workflow runs via `workflow_dispatch` (manual run).
- It exposes a `deploy` input with two options:
  - `'false'` (default): run validation, value templating, and Helm diff/dry-run flow only.
  - `'true'`: perform deploy steps (`helm upgrade --install`) when changes are detected.

### What the workflow does

- Configures AWS auth and kubeconfig for the target cluster.
- Injects runtime values into Helm values files (Grafana, Loki, Teams connector placeholders).
- Runs Helm diff for:
  - kube-prometheus-stack
  - loki
  - blackbox-exporter
  - promtail
  - prometheus-msteams
- Runs Helm dry-run upgrade for changed components.
- If `deploy == 'true'`, applies live upgrades and prints release history for changed components.

### Important note

- The workflow currently uses example env values for demonstration/manual testing.
- Replace example values with real environment/secret wiring before production usage.

## Secrets and Placeholders

Several files intentionally contain placeholders (for example `___GRAFANA_PASSWORD___`, cloud credentials, webhook URLs, OAuth settings, and bucket/role values).

Before deployment:
- Replace placeholders through your secret management workflow
- Do not commit real secrets into these files
- Validate external dependencies (S3 bucket, IAM roles, Azure AD app, Teams webhooks, DNS URLs)

## Operational Guidance

- Start by validating:
  - Grafana can query all data sources
  - Prometheus scrape targets are healthy
  - Loki ingestion/query path is healthy
  - Alert notifications reach expected Teams channels
- Prefer small, isolated changes to dashboards/alerts and test in non-production first.
