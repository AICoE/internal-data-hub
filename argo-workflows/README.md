# S3 Backup Argo Pipeline

 This directory contains code and infrastructure definition files for running the Ceph-to-AWS S3 Backup Utility

 ## Runbook
 The runbook for Argo can be found in the [dh-runbooks argo doc](https://gitlab.cee.redhat.com/data-hub/dh-runbooks/blob/master/ARGO.md)

 ## Prerequisites

 Additionally, this is an Argo Pipeline, so you will likely need the argo CLI. To get this, you can follow the installation instructions found on the [argoproj github](https://argoproj.github.io/argo-cd/cli_installation/)

 In the background, this uses `rclone` as the copy management utility.  No additional installations are necessary for this, but you can find documentation for that [here](https://rclone.org/)

 ## Manual Trigger and Testing
 To trigger a manual run of the pipeline, we have provided a 'trigger' Argo
 workflow: `triggers/s3-backup-parameterized-trigger.yaml`.  To use this, simply run
 the deployment to create the WorkflowTemplates necessary, then run
 `argo submit triggers/s3-backup-parameterized-trigger.yaml` from the root of this
 directory.  You can also change parameters on the fly by appending a
 `-p variable=value` flag to the `argo submit command`, with the following
 parameters:

   - *src_profile*: the rclone profileused to use to copy
     from (must have RW access to `src_bucket`)
   - *src_bucket*: The name of the bucket to copy from
   - *dest_profile*: the rclone profile used to use to copy to
     (must have RW and CreateBucket access to `dest_bucket`)
   - *dest_bucket*: The name of the bucket to copy to
   - *rclone_params*: Any additional rclone params to run with during the
     copy (such as `--s3-storage-class=GLACIER`)

 ## Adding a new Bucket to backup

 To add a new bucket to the list of buckets to back up, add it to all instances
 of the `bucket_list` parameter in the
 [base/s3-backup-pipeline-cron-workflows.yaml](base/s3-backup-pipeline-cron-workflows.yaml) file.
 **However**, there is the caveat that large
 buckets may take an exceptional amount of time to run initially (since rclone
 is essentially copying all files over http traffic). Once copied, rclone will
 only sync new files so this is not usually a major concern once we do this. Therefore,
 it may be a good idea to manually run the backup once before adding to the scheduled
 pipeline. You can manually run the pipeline by following the instructions
 found in the [Manual Triggering](#manual-trigger-and-testing) section above.

 ## Deployment Instructions

 ### Development

 There currently is no dev deployment for this pipeline

 ### Stage

 There currently is no Stage deployment for this pipeline

 ### Production

 Run the following command from this directory to deploy to
 production:

 ```bash
 kustomize build --enable-alpha-plugins overlays/prod | oc apply -f -
 ```
