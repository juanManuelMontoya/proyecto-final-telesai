#!/bin/bash
# CUPS - Servidor de impresion con impresora virtual PDF compartida
set -e
echo "== Instalando CUPS =="
sudo apt-get install -y cups printer-driver-cups-pdf
sudo usermod -aG lpadmin "$USER"
sudo systemctl enable --now cups

echo "== Acceso remoto y comparticion =="
sudo cupsctl --remote-admin --remote-any --share-printers
PPD=$(ls /usr/share/ppd/cups-pdf/*.ppd 2>/dev/null | head -1)
sudo lpadmin -p Telesai-PDF -E -v cups-pdf:/ -P "$PPD" \
  -D "Impresora oficina TELESAI (PDF)" -L "Oficina principal - Armenia" \
  -o printer-is-shared=true
sudo cupsenable Telesai-PDF
sudo cupsaccept Telesai-PDF
sudo lpadmin -d Telesai-PDF
sudo systemctl restart cups
sleep 3

echo "== Verificacion =="
lpstat -t
echo "Orden de servicio OS-0001 - prueba de impresion $(date)" | lp -d Telesai-PDF -t "OS-0001"
sleep 5
lpstat -W completed -o | tail -3
sudo ss -tlnp | grep :631
echo "PDF generados en: ~/PDF  o  /var/spool/cups-pdf/"
