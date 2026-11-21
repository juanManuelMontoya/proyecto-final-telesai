# Cliente Linux de prueba para NFS y NIS (simula un equipo de oficina de TELESAI)
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "nis nis/domain string telesai.local" | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends nfs-common nis libnss-nis rpcbind iproute2 iputils-ping sudo && \
    rm -rf /var/lib/apt/lists/*
COPY cliente.sh /usr/local/bin/cliente.sh
RUN chmod +x /usr/local/bin/cliente.sh && useradd -m -s /bin/bash invitado
ENTRYPOINT ["/usr/local/bin/cliente.sh"]
