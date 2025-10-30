#!/bin/sh

for i in etcd-data victoria-metrics-data grafana-data grafana-conf viinex-data-01 viinex-conf-01 ; do
    mkdir $i
    sudo chown 1001:root $i
done
