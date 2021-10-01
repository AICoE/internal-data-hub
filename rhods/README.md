# RHODS Installation

## PSI Requirements

There are certain components in the RHODS installation that the Data Hub team does not have permissions to deploy in production
These portions can be found in the following locations:

1) Stage overlays for any of the ods-* directories
2) (As of 10/01/21) We currently can not update catalogsources in prod. We have a ticket open with PSI to grant us permissions to do so.

## Deployment

We have three folders, once for each core rhods namespace. Simply run `kustomize build . --enable-alpha-plugins` to get the manifests for each namespace.
These are currently all managed by ArgoCD
