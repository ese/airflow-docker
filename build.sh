#!/usr/bin/env bash

set -x

VERSION=${VERSION:-master}
AIRFLOW_ROOT="/airflow"

mkdir ${AIRFLOW_ROOT}
git clone https://github.com/apache/incubator-airflow ${AIRFLOW_ROOT}
pushd ${AIRFLOW_ROOT}
git checkout ${VERSION}

python setup.py sdist -q
mv $AIRFLOW_ROOT/dist/*.tar.gz ${AIRFLOW_ROOT}/dist/airflow.tar.gz
