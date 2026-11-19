#!/bin/bash
# Samba - Carpetas compartidas para clientes Windows/Mac
set -e
CLAVE='Telesai2026*'
echo "== Instalando Samba =="
sudo apt-get install -y samba smbclient

echo "== Grupo, usuarios y carpetas =="
sudo groupadd -f sambausers
sudo usermod -aG sambausers "$USER"
sudo mkdir -p /srv/samba/telesai/{calidad,operaciones,gerencia}
sudo chown -R root:sambausers /srv/samba/telesai
sudo chmod -R 2770 /srv/samba/telesai
echo "Manual de calidad TELESAI - version 3" | sudo tee /srv/samba/telesai/calidad/manual-calidad.txt >/dev/null

# Usuario de Samba (misma clave para la demo)
printf '%s\n%s\n' "$CLAVE" "$CLAVE" | sudo smbpasswd -s -a "$USER"
sudo smbpasswd -e "$USER"

echo "== smb.conf =="
sudo cp -n /etc/samba/smb.conf /etc/samba/smb.conf.original
if ! grep -q '^\[telesai\]' /etc/samba/smb.conf; then
sudo tee -a /etc/samba/smb.conf >/dev/null <<'EOF'

[telesai]
   comment = Archivos compartidos TELESAI
   path = /srv/samba/telesai
   browseable = yes
   writable = yes
   guest ok = no
   valid users = @sambausers
   create mask = 0660
   directory mask = 2770
EOF
fi
sudo sed -i 's/^\s*workgroup = .*/   workgroup = TELESAI/' /etc/samba/smb.conf
testparm -s 2>/dev/null | sed -n '/\[telesai\]/,$p'

sudo systemctl enable --now smbd nmbd
sudo systemctl restart smbd nmbd

echo "== Verificacion =="
smbclient -L localhost -U "$USER%$CLAVE"
smbclient //localhost/telesai -U "$USER%$CLAVE" -c 'ls; cd calidad; ls'
