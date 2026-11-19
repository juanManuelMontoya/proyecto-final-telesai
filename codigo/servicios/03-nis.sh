#!/bin/bash
# NIS - Autenticacion centralizada de usuarios (dominio NIS: telesai.local)
set -e
DOMINIO=telesai.local
CLAVE='Telesai2026*'

echo "== Instalando NIS (servidor maestro) =="
echo "nis nis/domain string $DOMINIO" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nis rpcbind
echo "$DOMINIO" | sudo tee /etc/defaultdomain
sudo domainname "$DOMINIO"

# Servidor maestro
if [ -f /etc/default/nis ]; then
  sudo sed -i 's/^NISSERVER=.*/NISSERVER=master/' /etc/default/nis
  sudo sed -i 's/^NISCLIENT=.*/NISCLIENT=false/' /etc/default/nis
fi

# Redes autorizadas a consultar el servidor NIS
sudo tee /etc/ypserv.securenets >/dev/null <<'EOF'
255.0.0.0       127.0.0.0
255.255.255.0   192.168.56.0
255.240.0.0     172.16.0.0
EOF

echo "== Usuarios de la empresa (grupo telesai, homes en NFS) =="
sudo groupadd -f -g 3000 telesai
crear() { # usuario uid "Nombre - Area"
  if ! id "$1" >/dev/null 2>&1; then
    sudo useradd -u "$2" -g telesai -c "$3" -d /srv/nfs/telesai/home/"$1" -m -s /bin/bash "$1"
  fi
  echo "$1:$CLAVE" | sudo chpasswd
}
crear calidad1     3001 "Coordinadora de Calidad"
crear operaciones1 3002 "Supervisor de Operaciones"
crear talento1     3003 "Analista de Talento Humano"
getent passwd calidad1 operaciones1 talento1

sudo systemctl enable --now rpcbind ypserv
sudo systemctl restart ypserv
echo
echo ">>> Ahora ejecute:  sudo /usr/lib/yp/ypinit -m"
echo ">>> Cuando pida 'next host to add' presione Ctrl+D y luego Enter (y)."
