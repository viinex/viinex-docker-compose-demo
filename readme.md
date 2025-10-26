# viinex demo environment for docker compose

## What is this
Viinex is a standalone service which can easily be installed on Ubuntu or Debian
as a .deb package, and then one can manage its "static" config in
`/etc/viinex.conf.d` and/or via API. The scenario with a static config
may be viewed as the easiest one for development or testing.

This repo represents a demo environment to run a number of third party
components, and also the component `vnx-class` which can manage viinex
"clusters" configuration and lifetime. (viinex "cluster" is not a
cluster of viinex instances, but rather a self-sufficient
configuration of viinex objects. A viinex instance, that is -- a
process, -- may run one or more viinex "clusters", that is
configurations.)

What's to be deployed here is:

* `etcd` -- a key value store capable of keeping consensus between
  instances. Here, only one instance of `etcd` is deployed; this does
  not matter for the demo purpose. Etcd is used by `vnx-class` service
  to keep viinex higher-level configuration, the jsonnet templates to
  generate actual viinex config from higher-level configuration, and
  maintain the status-related information on viinex instances and
  clusters.
* `etcd-workbench` -- a neat GUI to manage the content stored within
  `etcd`. It's also available as a standalone app, but does not have a
  linux version. This is a completely optional component.
* `victoria-metrics` -- time series data store. `vnx-class` service
  automatically collects the metrics from viinex clusters which expose
  the metrics providers and which are managed by this vnx-class
  instance.
* `grafana` to display the collected statistics.
* `vnx-class` -- the service which keeps track of which viinex
  instances and viinex "clusters" (configurations) should be there,
  generates the configuration for a viinex cluster from the
  higher-level YAML config and Jsonnet scripts stored in etcd, and
  provides viinex instance with clusters' config when it's
  required. Also `vnx-class` implements a WAMP router and can be used
  as an entry point to reach viinex clusters API.
* `viinex` itself. There's only one instance of viinex configured in
  this environment. It is set up to run managed by `vnx-class`
  service, that is -- upon startup it attempts to connect to
  `vnx-class` and get the configuration updates, and then it starts
  the dynamic "clusters" (configurations) previously stored or
  obtained from `vnx-class`.


## Deployment

0. Have docker and docker compose installed:
```
sudo apt install docker.io docker-compose-v2
```
Also `etcdctl` is required for step 2 to initialize some data in etcd.
```
sudo apt install etcd-client
```

1. Clone this repo locally. Navigate to it in command line.

2. Run `etcd-data-prepare.sh` script. It prepares `etcd-data` folder.

3. Start the environment:
```
docker compose up -d
```

## Usage
* Navigate to http://localhost:8002 to manage viinex configuration. To
  log in, enter `etcd` as host name to connect to. Go to
  `/config/tenant1/project1` key prefix. Subkey `clusters` contain the
  configurations to be depoyed on viinex instances. For more
  information, refer to readme at `vnx-class` repository.
  
* Navigate to http://localhost:3000 to view metrics. Default login and
  password is `admin:admin`. You'll have to
  manually configure Grafana before use: create a Prometheus source
  (host `victoria-metrics`, port 8428); then import the dashboards
  residing in the folder `grafana-dashboards` in this repo.

* With the templates populated at step 2 of the `Deployment` section,
  viinex HTTP APIs is available at port http://localhost:8880; RTSP server is
  available at rtsp://localhost:554. Also viinex API is available via
  WAMP router which is implemented with `vnx-class` service and is
  listening at `ws://localhost:8080/ws`.

## Additional/alternative usage patterns
* One may extract the viinex configuration for a particular cluster
  from `vnx-class` with the following call:
```
export WICK_URL=ws://localhost:8080/ws
export WICK_AUTHMETHOD=cryptosign
export WICK_AUTHID=vnxworker
export WICK_PRIVATE_KEY=f4aa5571471ef77161f48281b61d92c2f86a822aba30617756a8cc20b5a97fbf
export WICK_REALM=project1

wick call com.viinex.infra.get_cluster_config CLUSTERNAME | jq '.[0]' -r
```
where `CLUSTERNAME` is the name of the cluster (appears in etcd KV
store as `/config/TENANT/PROJECT/clusters/CLUSTERNAME.yaml`).
Wick utility can be obtained from https://github.com/viinex/wick; it's
also shipped with viinex and can be run with `docker exec` from within
viinex cluster.

* It may be convenient to have the Jsonnet scripts locally to test and
develop them. Some of the scripts are available at
https://github.com/viinex/config-templates. There is a Makefile which
shows how viinex configuration can be generated from a given .yaml
file (higher level cluster configuration) and Jsonnet files, -- all
done locally, without the recourse to `vnx-class` service. All that is
required in this case is a `jsonnet` implementation. The resulting
viinex configuration may be used as a static configuration for viinex
instance, or can be used to create a dynamic cluster in a viinex
instance using the API described in section 3.19 of viinex
documentation
https://viinex.com/wp-content/uploads/2025/10/ViinexGuide.pdf
