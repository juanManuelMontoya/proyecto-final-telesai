#!/bin/bash
# NFS - Comparticion de archivos para clientes Linux (TELESAI)
set -e
echo "== Instalando NFS =="
sudo apt-get install -y nfs-kernel-server nfs-common

echo "== Grupo y carpetas de la empresa =="
sudo groupadd -f -g 3000 telesai
sudo mkdir -p /srv/nfs/telesai/{calidad,operaciones,talento-humano,home}
sudo chown -R root:telesai /srv/nfs/telesai
sudo chmod 2775 /srv/nfs/telesai /srv/nfs/telesai/{calidad,operaciones,talento-humano}
sudo chmod 755 /srv/nfs/telesai/home
echo "Procedimiento PR-CAL-001 Control de documentos (ISO 9001)" | sudo tee /srv/nfs/telesai/calidad/PR-CAL-001.txt >/dev/null
echo "Programacion de turnos de aseo - semana 47" | sudo tee /srv/nfs/telesai/operaciones/turnos-semana47.txt >/dev/null

echo "== /etc/exports =="
# Red host-only (Windows/VMs), localhost y redes Docker (cliente de prueba en contenedor)
sudo tee /etc/exports >/dev/null <<'EOF'
/srv/nfs/telesai 192.168.56.0/24(rw,sync,no_subtree_check,root_squash)
/srv/nfs/telesai 127.0.0.1(rw,sync,no_subtree_check,root_squash)
/srv/nfs/telesai 172.16.0.0/12(rw,sync,no_subtree_check,root_squash,insecure)
EOF
cat /etc/exports

sudo exportfs -ra
sudo systemctl enable --now nfs-kernel-server
sudo systemctl restart nfs-kernel-server

echo "== Verificacion =="
sudo exportfs -v
showmount -e localhost
systemctl is-active nfs-kernel-server
