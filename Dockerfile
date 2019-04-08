FROM alpine:3.9.2
MAINTAINER Dmitry Evdokimov <dmitry.evdokimov@nibiru.pro>
ENV CONFIG "/data/pghoard/config.json"
VOLUME /data/pghoard/

RUN apk add --no-cache \
        ca-certificates \
        python3 \
        snappy \
        libffi \
        postgresql \
        git && \
    apk add --no-cache --virtual .build-deps \
        musl-dev \
        python3-dev \
        postgresql-dev \
        snappy-dev \
        libffi-dev \
        gcc \
        g++ && \
    python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install boto azure google-api-python-client cryptography python-snappy psycopg2 botocore && \
    rm -r /root/.cache && \
    apk del .build-deps && \
    git clone https://github.com/aiven/pghoard.git && \
    cd pghoard && \
    python3 setup.py install

# Overcome PostgreSQL version check to be able to make database dumps from the other container.
RUN mkdir -p /pgdata && \
  echo "11" > /pgdata/PG_VERSION && \
  chgrp -R 0 /pgdata && \
  chmod -R g=u /pgdata

RUN mkdir -p /var/lib/pghoard && \
  chgrp -R 0 /var/lib/pghoard && \
  chmod -R g=u /var/lib/pghoard

CMD ["/usr/bin/pghoard", "--short-log"]
