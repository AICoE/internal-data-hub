# Data Hub Grafana

Kustomize deployment for the Data Hub's internal Prometheus and Grafana instance

## Deploying to Production

### Router CA

`router-ca.enc.yaml` is not included in the secret generator for prod as Prometheus is already deploying the certs. If you are deploying Grafana _alone_ in a namespace, make sure to update the secret generator and include `router-ca.enc.yaml`

Run the following command from the root of the repository to deploy Grafana:

```bash
kustomize build grafana/prod/ --enable_alpha_plugins | oc apply -n dh-psi-monitoring -f -
```

The value of this Router CA can be attained by running (Cluster Admin Required):

```bash
oc get cm -n openshift-config-managed default-ingress-cert -o yaml
```

# Adding LDAP Groups as Admin (or other users):

Add the following entry in the `configs/ldap.toml` file:

```
[[servers.group_mappings]]
group_dn = "<ldap_group>,ou=adhoc,ou=managedGroups,dc=redhat,dc=com"
org_role = "Admin"
grafana_admin = true
```

Replace the `<ldap_group>` with your team's group. Pick the appropriate settings if you'd like other roles besides
`Admin`, see [here](https://grafana.com/docs/grafana/latest/auth/ldap/#group-mappings) for more information.
