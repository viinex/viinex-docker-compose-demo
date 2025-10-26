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
