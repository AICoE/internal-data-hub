# S3 Sync Pipelines

Artifacts for Deploying Data Hub s3 sync pipelines.

We use OpenShift Pipelines for orchestrating syncs of data between a source
and destination bucket. Under the covers, we use the [RClone](https://rclone.org)
tool to execute the data syncs.

## Transitioning Ownership

As part of the broader Data Hub decommissioning effort, we are working to
stop maintaining ownership of these sync jobs. Our expectation is that data
owner teams will take over ownership of their sync jobs. These data owners can
choose to leverage these existing deployment artifacts for their own use
and run the sync pipeline in their own cluster/namespace.

The following are instructions for how a data owner can do so. We currently use
Kustomize with the KSops plugin for managing Kubernetes deployments and
encrypting secrets in Git. These instructions do not assume use of either
tool and instead point to specific Kubernetes objects to be deployed. You
may use the tool of your choice.

1. Make sure you have the OpenShift pipelines operator installed on your
   OpenShfit cluster.
2. Copy the Kubernetes objects (everything except for kustomization.yaml) in
   the [base](base) directory into your own repository.
2. Find the existing file for your specific sync job in the
   [overlays/prod/sync-instances](overlays/prod/sync-instances) directory. This
   file contains the Kubernetes `CronJob` and `Eventlistener` object
   definitions. Copy these objects into your repository.
3. Obtain/create the RClone config secret for your sync job. These are stored
   encrypted in the [overlays/prod/secrets](overlays/prod/secrets) directory.
   It is probably easiest to work with a member of the Data Hub team to get
   this secret.
4. Apply all of the objects into your kubernetes namespace. The sync will
   execute based on the schedule defined in your `CronJob` object.


## Adding a new sync job

Each individual sync job requires the following artifacts:

### RClone Config Secret

A Kubernetes secret containing rclone configuration (including S3 credentials). Example:

```
apiVersion: v1
kind: Secret
metadata:
    name: CHANGEME
stringData:
    rclone.conf: |
        [source]
        type = s3
        provider = AWS
        env_auth = false
        access_key_id = CHANGEME
        secret_access_key = CHANGEME
        acl = private

        [destination]
        type = s3
        provider = Ceph
        env_auth = false
        access_key_id = CHANGEME
        secret_access_key = CHANGEME
        acl = private
        endpoint = https://s3.upshift.redhat.com/
```

### EventListener

A Tekton EventListener to facilitate triggering a sync. Example:

```
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: CHANGME
spec:
  serviceAccountName: s3-sync
  triggers:
    - name: s3-sync
      bindings:
        - name: src_bucket
          value: CHANGEME #The name of the source S3 bucket
        - name: dest_bucket
          value: CHANGEME #The name of the destination S3 bucket
        - name: sync_config_secret_name
          value: CHANGEME #The name of the rclone config secret
      template:
        ref: s3-sync
```

### Cron Job

A Kubernetes CronJob defining how ofen to run the sync. Example:

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: CHANGEME
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: quay.io/rhn_support_sreber/curl
            args: ["curl", "-X", "POST", "--data", "{}", "el-CHANGEME-listener:8080"]
          restartPolicy: Never
```
