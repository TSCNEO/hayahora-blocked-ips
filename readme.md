# hayahora-blocked-ips

Resuelve y mantiene un listado actualizado de IPs bloqueadas según el monitoreo de hayahora.futbol, ejecutado automáticamente mediante GitHub Actions.

## ¿Qué es?

Este repositorio resuelve automáticamente todos los registros A del dominio `blocked.dns.hayahora.futbol` cada 5 minutos y genera un archivo `blocked-ips.txt` con todas las IPs bloqueadas en España durante las jornadas de LaLiga.

## Uso

El archivo `blocked-ips.txt` contiene una IP por línea, listo para importar a cualquier herramienta:

- **Mikrotik RouterOS** (via API o script)
- **iptables / firewall**
- **DNS sinkhole**
- **Proxy / Load Balancer**
- Cualquier otra solución de networking

### Ejemplo práctico: Mikrotik RouterOS

Se incluye un **script completo y listo para usar** que sincroniza automáticamente las IPs bloqueadas en tu router Mikrotik con detección inteligente de cambios.

📁 **[Ver script y documentación en `/Mikrotik/`](./Mikrotik/)**

Características del script:
- ✅ Sincronización automática cada 15 minutos
- ✅ Optimizado: solo descarga cuando hay cambios
- ✅ Instalación en un solo comando
- ✅ Documentación completa incluida

## Automatización

El repositorio se actualiza automáticamente cada 5 minutos mediante GitHub Actions. No necesitas hacer nada, solo descargar el archivo cuando lo necesites.

## Licencia

MIT

## Referencias

- [hayahora.futbol](https://hayahora.futbol) - Monitor de bloqueos en España
