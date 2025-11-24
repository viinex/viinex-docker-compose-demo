#!/bin/sh

for i in etcd-data etcd-workbench-data victoria-metrics-data grafana-data viinex-data-01 viinex-conf-01 zmq-sockets; do
    mkdir $i
    sudo chown 1001:root $i
done
