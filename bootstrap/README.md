This `bootstrap` directory contains all of the artifacts that must be
manually created for an initial deployment of the Internal Data Hub platform.

These artifacts were created to facilitate the migration of the IDH to the new
Red Hat IT-managed multi-tenant Managed Platform (MP+) OpenShift cluster.

Information about how to administer deployments in the MP+ environment can be
found [here](https://source.redhat.com/departments/it/devit/it-infrastructure/itcloudservices/itocp/managedplatformplushub/mppluswiki/user_tenant_onboarding_and_administration)

Follow the instructions below to manually create cluster objects for:
* The central ArgoCD instance that will automate GitOps deployment of all
  IDH applications
* Namespaces for all IDH applications
* Rolebindings for ArgoCD to deploy applications into target namespaces
* Network egress policies for application namespaces
* Tenant user groups

# Creating namespaces

In the MP+ environment, namespaces are created by creating `TenantNamespace` objects.
When the namespaces are created, the resulting namespace will be named `<tenant name>--<tenant namespace name>`.
Our `tenant name` is `internal-data-hub`. Therefore, for a `TenantNamespace` named `argocd`, the resulting
OpenShift namespace will be `internal-data-hub--argocd`.

For each `TenantNamespace` object file in the [namespaces/](namespaces/) subdirectory,
run `oc apply -f $FILE` to create the `TenantNamespace` object on the target MP+
OpenShift cluster.

# Configuring MP+ Egress Rules

Perform the following to set up additional things requried by the MP+ environment:

* Create our user group giving us permission to create TenantEgress (network egress) rule
  objects:
  ```
  oc apply -f tenantgroups/internal-data-hub-tenant-egress-admins-tenantgroup.yaml
  ```

* We need to define `TenantEgress` objects to specify network endpoints that our applications
  are permitted to connect to. Run the following to apply all of our `TenantEgress` objects:
  ```
  oc apply -f tenantegresses/*
  ```

* We configure the managed platform to sync various Rover/LDAP groups into the cluster, so that we can
  use those groups to control access to our applications. Run the following command to configure all of the
  `LdapGroup` objects:
  ```
  oc apply -f ldapgroups/*
  ```

* ArgoCD's service user needs access to all of our `TenantNamespace` namespaces to deploy our applications. Run
  the following command to apply the necessary `RoleBindings`:
  ```
  oc apply -f rolebindings/*
  ```

# Decrypting secure files

Some files needed by ArgoCD contain sensitive information and are therefore stored in Git encrypted
using KSops. Before applying the objects onto the cluster (in the next section), you must decrypt these files.
In order to do so, your local GPG keychain will need to contain the private key with fingerprint
`EFDB9AFBD18936D9AB6B2EECBD2C73FF891FBC7E`. You can get this key from another member of the IDH team.
Information on how to install the Sops tool can be found [here](https://github.com/getsops/sops)

```
sops -d -i ksops-pgp-key-secret.yaml
sops -d -i argocd-cluster-secret.yaml
sops -d -i datahub-ocp4-argocd-cluster-secret.yaml
```

# Deploying ArgoCD

We use ArgoCD to manage GitOps deployments of all IDH applications. We depend on the
Red Hat OpenShift GitOps operator to deploy our ArgoCD instance (the MP+ admin team
is responsible for installing this operator on our MP+ cluster). The deploy and configure
ArgoCD:

* Create the ArgoCD instance by running the following command from within this `bootstrap` directory:
  ```
  oc apply -f argocd/internal-data-hub-argocd.yaml
  ```
* Create the `internal-data-hub` Application project by running the following command from within this `bootstrap` directory:
  ```
  oc apply -f argocd/internal-data-hub-appproject.yaml
  ```
* Create the ArgoCD service user:
  ```
  oc apply -f argocd-serviceaccount.yml
  ```
* Create the cluster secrets so that ArgoCD can deploy applications onto the target OpenShift clusters:
  ```
  oc apply -f argocd-cluster-secret.yaml
  oc apply -f datahub-ocp4-argocd-cluster-secret.yaml
  ```
* Create the ArgoCD TLS certs configmap so that ArgoCD can trust connections to endpoints with certs signed
  by the Red Hat internal CA (e.g. internal gitlab):
  ```
  oc apply -f argocd-tls-certs-cm-configmap.yaml
  ```
* Create the secret containing the IDH sops key so that ArgoCD can decrypt files stored encrypted in Git using Ksops:
  ```
  oc apply -f ksops-pgp-key-secret.yaml
  ```
* Create all of the ArgoCD Applications by running `oc apply -f $FILE` for each file in the
  [argocd/applications/](argocd/applications/) subdirectory.
