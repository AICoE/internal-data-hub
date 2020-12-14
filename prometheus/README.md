# Data Hub Prometheus & Alertmanager

Kustomize deployment for the Data Hub's internal Prometheus and Grafana instance

## Deploying to Production

Run the following command from the root of the repository to deploy Prometheus and Alertmanager:

```bash
kustomize build prometheus/overlays/prod/ | oc apply -n dh-psi-monitoring -f -
```

## Adding New Namespaces for Prometheus to Monitor

Give the prometheus service account access to your namespace

```bash
oc project <target_namespace>
oc policy add-role-to-user view system:serviceaccount:dh-psi-monitoring:monitoring-sa
```

## Alerting

### Alertmanager Config

The alertmanager deployment will fail unless there is a secret in the namespace called `alertmanager-<alertmanager_name>`.
You can create this secret by running the following command:

```bash
kubectl create secret generic alertmanager-<alertmanager-name> --from-file=alertmanager.yaml
```

The following is a sample `alertmanager.yaml` you can look at:

```yaml
global:
  smtp_smarthost: '<mail_server>'
  smtp_from: '<alert_host_email>'
  smtp_auth_username: 'bar'
  smtp_auth_password: 'foo'
  smtp_require_tls: false
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'developer-mails'
receivers:
- name: 'developer-mails'
  email_configs:
    - to: '<email_list>'
      send_resolved: true
```

The following user-guide can be a good point of reference: [alerting.md](https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/alerting.md)

## Common issues

### Prometheus unable to detect pod/service monitors

Make sure that the monitor has the `prometheus: dh-prometheus` label on it.
