# Camel K

Apache Camel K is a lightweight integration framework built from **Apache Camel** that runs natively on Kubernetes and is specifically designed for serverless and microservice architectures. Users of `Camel K` can instantly run integration code written in Camel DSL on their preferred **Cloud** provider.

## Deployment

Simply run `kustomize build . --enable-alpha-plugins` in one of the `overlays/` folders to get the namespaced files for every environment.
These are currently all managed by ArgoCD
