FROM perl:5.26.1
RUN cpanm Carton && \
    apt-get update && \
    apt-get install -y sqlite3 && \
    mkdir -p /usr/src/app
WORKDIR /usr/src/app
