## viinex demo environment for docker compose

# What is this
Viinex itself is a standalone service which does not win anything from
containerization. It's very easy to install viinex on Ubuntu or Debian
as a .deb package, and then one can just manage its config in
`/etc/viinex.conf.d` and/or via API.

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


# Deployment

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

# Usage
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
