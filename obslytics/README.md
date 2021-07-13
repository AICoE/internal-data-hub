# Data Hub Obslytics workflow

Kustomize deployment for the Data Hub's internal Obslytics instance

## Deployment Instructions

### Prerequisites

#### Install Kustomize

Install [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)

```bash
GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v3.5.4
```

### Deploying to Development

Run the following command from the `obslytics` folder of this repository to deploy
Obslytics in a development environment:

```bash
oc new-project dh-dev-argo
kustomize build overlays/dev/ --enable-alpha-plugins | oc apply -f -
```

### Deploying to Stage

Run the following command from the `obslytics` folder of this repository to deploy
Obslytics to stage:

```bash
kustomize build --enable-alpha-plugins overlays/stage/ | oc apply -f -
```

### Deploying to Production

Run the following command from the `obslytics` folder of this repository to deploy
Obslytics to production:

```bash
kustomize build --enable-alpha-plugins overlays/prod/ | oc apply -f -
```

## Build manifests

If you want to build the manifests on your local file system without deploying
them run the following command from the root of this repository:

```bash
# target_env is either dev, stage, prod
mkdir build
kustomize build --enable-alpha-plugins overlays/${target_env}/ -o build/
```
