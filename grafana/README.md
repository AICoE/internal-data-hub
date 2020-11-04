# Data Hub Grafana

Kustomize deployment for the Data Hub's internal Prometheus and Grafana instance

## Deploying to Production

### Router CA

`router-ca.enc.yaml` is not included in the secret generator for prod as Prometheus is already deploying the certs. If you are deploying Grafana _alone_ in a namespace, make sure to update the secret generator and include `router-ca.enc.yaml`

Run the following command from the root of the repository to deploy Grafana:

```bash
kustomize build grafana/prod/ --enable_alpha_plugins | oc apply -n dh-psi-monitoring -f -
```
