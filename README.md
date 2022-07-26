# Internal-Data-Hub

A repo housing deployment artifacts for components of the Internal
Data Hub that are not managed by the ODH operator.

## Updating Trino Group Membership

We manage [Trino group membership](kfdefs/base/trino/trino-group-mapping.properties) by
manually replicating LDAP group membership into the group membership file. To automate this
process, we have a [Makefile](Makefile) that, when run, will sync all rover groups that
we care about into the properties file.

To update group membership, simply run the following command from the root of
this repository:

```bash
make update-trino-groups
```

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
