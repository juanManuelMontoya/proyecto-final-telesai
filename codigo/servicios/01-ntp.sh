#!/bin/bash
# NTP - Servidor de tiempo para la red (ntpsec en Ubuntu/Mint 24.04)
set -e
sudo apt-get install -y ntp ntpdate
# Permitir que los equipos de la red host-only consulten la hora
grep -q '^restrict 192.168.56.0' /etc/ntpsec/ntp.conf || \
  echo "restrict 192.168.56.0 mask 255.255.255.0 nomodify notrap" | sudo tee -a /etc/ntpsec/ntp.conf
sudo systemctl enable --now ntpsec
sudo systemctl restart ntpsec
sleep 20
ntpq -p
sudo ss -ulnp | grep ':123'
