# Data Hub Grafana

Kustomize deployment for the Data Hub's internal Prometheus and Grafana instance

### Deploying to Production

Run the following command from the root of the repository to deploy Grafana:

```bash
kustomize build grafana/prod/ --enable_alpha_plugins | oc apply -n dh-psi-monitoring -f -
```
