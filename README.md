# Internal-Data-Hub

A repo housing deployment artifacts for components of the Internal
Data Hub that are not managed by the ODH operator.

## Trino

### Setting up access for a Trino dataset

To configure access for a dataset in Trino, perform the following:

1. We use Rover (LDAP) groups to manage access to datasets in Trino. For
   most data sets, we have one group (or multiple) with admin level
   privileges on a given dataset, and another group (or multiple) with
   readonly permissions. Come up with a plan for how you want to align
   access to groups. The data hub team does not take ownership
   responsibility for these rover groups.
2. Grant the desired level of access to the group(s) by following the
   instructions below in
   [granting a group access to a Trino data set](#granting-a-group-access-to-a-trino-data-set)

### Granting a group access to a Trino data set

A few steps should be taken to grant a group access to a Trino data set:

1. If a group should have administrative access to a dataset, add an ACL rule
   defining the group as an owner of the schema.

   In the [trino-acl-rules.json](kfdefs/base/trino/trino-acl-rules.json) file you
   will find a dictionary section under the key `schemas`. Add an entry to the list for your
   group and schema. The entry should be of the format:

   ```
   {
       "group": "$TRINO_GROUP_NAME",
       "schema": "$TRINO_SCHEMA_NAME",
       "owner": true
   }
   ```

   Note that the Trino ACL syntax supports regular expressions which can be used to
   grant ownership over multiple schemas or to multiple groups in one entry.

2. Add entries granting the necessary level of access to the group in
   [trino-acl-rules.json](kfdefs/base/trino/trino-acl-rules.json). In this file, you will
   find a dictionary section under the key `tables`. Add an entry granting the level of
   permissions that you need.

   For groups that should have admin level access over the schema, add an entry like the
   following:

   ```
   {
       "group": "$TRINO_GROUP_NAME",
       "schema": "$TRINO_SCHEMA_NAME",
       "privileges": ["SELECT", "INSERT", "DELETE", "OWNERSHIP", "GRANT_SELECT"]
    }
    ```

    For groups that should have readonly level access over the schema, add an entry
    like the following:

    ```
    {
        "group": "$TRINO_GROUP_NAME",
        "schema": "$TRINO_SCHEMA_NAME",
        "privileges": ["SELECT"]
     }
     ```

    Note again that the Trino ACL syntax supports regular expressions which can be used to
    grant access to multiple schemas or to multiple groups in one entry.

    As a final note, by convention, we grant access at a schema level so the desired
    access will be granted to any table in the schema. If finer grained table level
    access is required, see [this page](https://trino.io/docs/current/security/file-system-access-control.html#table-rules)
    for Trino docuemntation on the rule format.

3. Commit any changes to the trino-acl-rules.json file and
   open up a pull request for these changes.

## Development Instructions

### Running Pre-Commit Tests

Our world is being taken over by shitty bots that add little value. In order
to satisfy these bots, you must ensure that your code complies with
arbitrary standards. To check your compliance, perform the following:

```
pip install --user pre-commit
pre-commit run --all-files
```

## Monitoring

As we migrate our services to OpenShift 4, we are standardizing on using
OpenShift [user workload monitoring][uwm] to monitor our services. This means
that, rather than maintain a super long `prometheus.yaml` file with our monitoring
and alerting configuration, we'll define [ServiceMonitors][servicemonitor], [PodMonitors][podmonitor], and [PrometheusRules][prometheusrule] for all of
our services.

By convention, these artifacts should be placed in the Kustomize `base` directory
for the corresponding service. See [this file](telemetry-grafana/base/telemetry-grafana-service-monitor.yaml) for an example of a ServiceMonitor.

[uwm]: https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html#:~:text=The%20user-workload-monitoring-config-edit%20role%20in%20the%20openshift-user-workload-monitoring%20project%20enables,Operator%20and%20Thanos%20Ruler%20for%20user-defined%20workload%20monitoring.

[servicemonitor]: https://docs.openshift.com/container-platform/4.5/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html

[podmonitor]: https://docs.openshift.com/container-platform/4.5/rest_api/monitoring_apis/podmonitor-monitoring-coreos-com-v1.html

[prometheusrule]: https://docs.openshift.com/container-platform/4.5/rest_api/monitoring_apis/prometheusrule-monitoring-coreos-com-v1.html
