# dh-logstash

Kustomize deployment for the Data Hub's internal Logstash instance

## Runbook

Currently, no runbook for logstash exists.

## Deployment Instructions

### Prerequisites

#### Install Kustomize

Install [Kustomize](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)

```bash
GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v3.5.4
```

#### Deploy ArgoCD-Manager rolebinding

Before using ArgoCD to manage the Logstash deployment in stage or
production, you must manually apply the ArgoCD-Manager rolebinding
contained in [bases/logstash/argocd-manager-rolebinding.yaml](bases/logstash/argocd-manager-rolebinding.yaml)

See [Kustomize](https://github.com/kubernetes-sigs/kustomize/tree/master/docs)
docs for more info.

### Deploying to Development

Run the following command from the `logstash` folder of this repository to deploy
Logstash in a development environment:

```bash
oc new-project dh-dev-ingest
kustomize build overlays/dev/ | oc apply -f -
```

### Deploying to Stage

Run the following command from the `logstash` folder of this repository to deploy
Logstash to stage:

```bash
kustomize build --enable_alpha_plugins overlays/stage/ | oc apply -f -
```

### Deploying to Production

Run the following command from the `logstash` folder of this repository to deploy
Logstash to production:

```bash
kustomize build --enable_alpha_plugins overlays/prod/ | oc apply -f -
```

## Build manifests

If you want to build the manifests on your local file system without deploying
them run the following command from the root of this repository:

```bash
# target_env is either dev, stage, prod
mkdir build
kustomize build --enable_alpha_plugins overlays/${target_env}/ -o build/
```
