#!/bin/bash
# IP fija en la red host-only y nombre del servidor
sudo nmcli connection modify "Conexión cableada 2" ipv4.method manual ipv4.addresses 192.168.56.10/24 ipv4.gateway "" ipv4.dns "" ipv4.never-default yes
sudo nmcli connection up "Conexión cableada 2"
sudo hostnamectl set-hostname srv-telesai
echo "192.168.56.10 srv-telesai srv-telesai.telesai.local" | sudo tee -a /etc/hosts
ip -br addr show enp0s8
