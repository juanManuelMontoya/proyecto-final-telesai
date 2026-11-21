#!/bin/bash
# Arranque del cliente: se une al dominio NIS y monta el recurso NFS del servidor
SERVIDOR=${SERVIDOR:-172.17.0.1}
DOMINIO=telesai.local

echo "== Cliente NIS: dominio $DOMINIO, servidor $SERVIDOR =="
echo "$DOMINIO" > /etc/defaultdomain
domainname "$DOMINIO"
echo "domain $DOMINIO server $SERVIDOR" > /etc/yp.conf
sed -i -E 's/^(passwd|group|shadow):.*/\1:         files nis/' /etc/nsswitch.conf
grep -E '^(passwd|group|shadow)' /etc/nsswitch.conf
rpcbind -w
ypbind
sleep 3
echo "Servidor NIS enlazado: $(ypwhich)"

echo "== Cliente NFS: montando $SERVIDOR:/srv/nfs/telesai =="
mkdir -p /srv/nfs/telesai
mount -t nfs -o vers=4 "$SERVIDOR":/srv/nfs/telesai /srv/nfs/telesai && df -h /srv/nfs/telesai

echo
echo "Cliente listo. Pruebas sugeridas:"
echo "  ypcat passwd | grep telesai      (usuarios que vienen del servidor NIS)"
echo "  id calidad1                      (el usuario NO existe localmente)"
echo "  su - invitado  y luego  su - calidad1   (pide la clave del servidor NIS)"
echo "  ls -l /srv/nfs/telesai           (carpetas compartidas por NFS)"
exec bash
