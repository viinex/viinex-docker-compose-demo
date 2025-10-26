#!/bin/bash

if test -d "etcd-data" ; then
    echo "etcd-data is already present. remove it first"
    exit 0
fi

if test -z `which etcdctl` ; then
    echo "etcdctl is needed to run this script."
    echo "please run 'apt install -y etcd-client'"
    exit 1
fi

etcdctl snapshot restore etcd-snapshot --data-dir=etcd-data
find etcd-data/ -type d -exec chmod 777 '{}' ';'
find etcd-data/ -type f -exec chmod 666 '{}' ';'

mkdir -p grafana-data
chmod 777 grafana-data
