FROM python:3.6-alpine3.7 as get_code

RUN apk add --no-cache \
      git \
      bash \
      && pip install gitpython

ENV SLUGIFY_USES_TEXT_UNIDECODE=yes

COPY build.sh /build.sh

RUN /build.sh

FROM python:3.6-alpine3.7

COPY  --from=get_code /airflow/dist/airflow.tar.gz /tmp/airflow.tar.gz

ENV SLUGIFY_USES_TEXT_UNIDECODE=yes

# install deps
RUN apk add --no-cache \
        wget \
        curl \
        libxslt \
        libxml2 \
        musl \
        openjdk8 \
        postgresql-libs && \
        apk add --no-cache --virtual=.build-dependencies \
        git \
        libxml2-dev \
        postgresql-dev \
        libxslt-dev \
        libffi-dev \
        musl-dev \
        build-base \
        gcc \
        linux-headers && \
        pip install --upgrade pip && \
        pip install -U setuptools && \
        pip install kubernetes && \
        pip install cryptography && \
        pip install --no-cache-dir Cython --install-option="--no-cython-compile" && \
        pip install psycopg2-binary==2.7.4 && \
        pip install numpy==1.14.0 && \
        pip install --no-build-isolation /tmp/airflow.tar.gz && \
        wget -q --show-progress --progress=bar:force:noscroll https://github.com/apache-spark-on-k8s/spark/releases/download/v2.2.0-kubernetes-0.5.0/spark-2.2.0-k8s-0.5.0-bin-with-hadoop-2.7.3.tgz && \
        mkdir -p /opt && \
        tar xfz spark-2.2.0-k8s-0.5.0-bin-with-hadoop-2.7.3.tgz -C /opt && \
        rm spark-2.2.0-k8s-0.5.0-bin-with-hadoop-2.7.3.tgz && \
        ln -s /opt/spark-2.2.0-k8s-0.5.0-bin-2.7.3 /opt/spark && \
        apk del .build-dependencies

COPY airflow-init.sh /tmp/airflow-init.sh

COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

RUN apk add --no-cache bash 

ENTRYPOINT ["/bootstrap.sh"]
