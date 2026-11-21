# Proyecto Final – Infraestructura de servicios TI para TELESAI

**Curso:** Administración de Infraestructura de TI – Universidad del Quindío (2026)
**Estudiante:** Juan Manuel Montoya
**Empresa:** TELESAI Y CÍA S.A.S. – aseo, desinfección y mantenimiento de edificaciones, Armenia (Quindío), certificada ISO 9001:2015.

Este proyecto diseña e implementa en un servidor local (VM en VirtualBox) los servicios que necesita la oficina de TELESAI. Las aplicaciones corren en **Dokploy** y los servicios de red se instalan directamente en Linux.

| Servicio | Acceso / verificación |
|---|---|
| Sitio web + MySQL (Dokploy) | `https://telesai-192-168-56-10.sslip.io` · `/health` |
| Panel Dokploy | `http://192.168.56.10:3000` |
| NTP (ntpsec) | `w32tm /stripchart /computer:192.168.56.10` · `ntpq -p` |
| NFS | `192.168.56.10:/srv/nfs/telesai` |
| NIS | dominio `telesai.local` |
| CUPS | `http://192.168.56.10:631/printers/Telesai-PDF` |
| Samba | `\\192.168.56.10\telesai` |

## Estructura

```
proyecto-final/
├── analisis.md          # Necesidades, justificación de servicios, tabla de requisitos, diseño
├── diagrama.mmd         # Diagrama de arquitectura (Mermaid)
├── documentacion.md     # Instalación, verificación, capturas, problemas y costo-beneficio
├── README.md
├── capturas/            # Evidencias (01–31) y diagrama en PNG
└── codigo/
    ├── web/             # Sitio institucional: Express + MySQL, Dockerfile
    ├── servicios/       # 00-red, 01-ntp, 02-nfs, 03-nis, 04-cups, 05-samba (scripts)
    └── clientes/        # Cliente Linux de prueba (contenedor) para NIS + NFS
```

## Reproducir

1. VM Ubuntu 24.04 (o un derivado) con 2 adaptadores: NAT y Host-only. Ejecutar `codigo/servicios/00-red.sh` para fijar la IP `192.168.56.10`.
2. Instalar Docker y Dokploy: `curl -sSL https://dokploy.com/install.sh | sudo sh`.
3. Ejecutar en orden `01-ntp.sh`, `02-nfs.sh`, `03-nis.sh` (luego `sudo /usr/lib/yp/ypinit -m`), `04-cups.sh` y `05-samba.sh`.
4. En Dokploy:
   - crear MySQL;
   - crear la aplicación desde este repositorio (Dockerfile `codigo/web/Dockerfile`, contexto `codigo/web`) con las variables `DB_*`;
   - agregar el dominio con HTTPS.
5. Probar NIS y NFS con el cliente:

   ```bash
   docker build -t cliente-telesai codigo/clientes
   docker run -it --rm --privileged cliente-telesai
   ```

Las claves de los scripts son de demostración y deben cambiarse en un entorno real.

> Proyecto académico. El sitio web es una referencia y no el sitio oficial de la empresa.
