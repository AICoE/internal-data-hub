# RHODS Installation

## PSI Requirements

There are certain components in the RHODS installation that the Data Hub team does not have permissions to deploy
These portions can be found in the `psi` folder in this directory.

### NOTE: There is a sops encrypted file under `psi/openshift-marketplace`. We must build the files, encrypt with gpg, and pass them to PSI

## Deployment

We have three folders, once for each core rhods namespace. Simply run `kustomize build . --enable-alpha-plugins` to get the manifests for each namespace.
These are currently all managed by ArgoCD
