# Script de Sincronización de IPs Bloqueadas para Mikrotik

Script inteligente para RouterOS que sincroniza automáticamente las IPs bloqueadas desde el repositorio GitHub, optimizado para minimizar descargas innecesarias verificando cambios antes de actualizar.

## 📋 Descripción

Este script descarga y mantiene actualizada una lista de IPs bloqueadas en tu router Mikrotik, utilizando los datos del proyecto [hayahora-blocked-ips](https://github.com/TSCNEO/hayahora-blocked-ips) que monitoriza bloqueos de LaLiga en España.

### Características

- ✅ **Sincronización inteligente**: Verifica el timestamp `LastUpdate.txt` antes de descargar
- ✅ **Optimización de ancho de banda**: Solo descarga `blocked-ips.txt` cuando hay cambios
- ✅ **Ejecución automática**: Scheduler integrado cada 15 minutos
- ✅ **Logging detallado**: Registros informativos en `/log`
- ✅ **Gestión automática**: Elimina IPs antiguas y añade las nuevas
- ✅ **Formato limpio**: Ignora comentarios y líneas vacías

## 🚀 Instalación

### Opción 1: Import directo (Recomendado)

1. Descarga el archivo `sync-blocked-ips.rsc`
2. Copia el archivo a tu Mikrotik vía FTP/SFTP
3. Ejecuta en la terminal:
   ```
   /import sync-blocked-ips.rsc
   ```

### Opción 2: Copy/Paste

1. Abre el archivo `sync-blocked-ips.rsc`
2. Copia todo el contenido
3. Pega en la terminal de Mikrotik (WinBox o SSH)

## ⚙️ Configuración

### Variables personalizables

Si necesitas modificar las URLs o el nombre de la lista, edita estas variables en el script:

```
:local urlLastUpdate "https://raw.githubusercontent.com/TSCNEO/hayahora-blocked-ips/main/LastUpdate.txt"
:local urlIPs "https://raw.githubusercontent.com/TSCNEO/hayahora-blocked-ips/main/blocked-ips.txt"
:local listName "IPsBloqueadas"
```

### Cambiar intervalo de ejecución

Por defecto se ejecuta cada **15 minutos**. Para modificarlo:

```
/system scheduler set scheduler-sync-blocked-ips interval=30m
```

## 📖 Uso

### Ejecución automática

El script se ejecuta automáticamente:
- Cada 15 minutos (configurable)
- Al iniciar el router

### Ejecución manual

Para ejecutar manualmente en cualquier momento:

```
/system script run sync-blocked-ips
```

### Ver logs

Para ver el historial de sincronizaciones:

```
/log print where topics~"script"
```

### Verificar IPs importadas

Para ver las IPs bloqueadas actualmente:

```
/ip/firewall/address-list print where list="IPsBloqueadas"
```

## 🔍 Funcionamiento

1. **Descarga `LastUpdate.txt`** desde GitHub
2. **Compara** el timestamp con el almacenado localmente (en el campo `comment` de la address-list)
3. **Si hay cambios**:
   - Descarga `blocked-ips.txt`
   - Elimina las IPs antiguas de la lista
   - Importa las nuevas IPs
   - Actualiza el timestamp local
4. **Si no hay cambios**: Termina sin descargar nada (ahorro de bandwidth)

## 📊 Ejemplo de Logs

```
12:45:00 script,info Verificando actualizaciones de IPs bloqueadas...
12:45:01 script,info LastUpdate en servidor: 124501-251202
12:45:01 script,info LastUpdate local actual: 120312-251202
12:45:01 script,info LastUpdate diferente. Actualizando...
12:45:01 script,info Anterior: 120312-251202 -> Nuevo: 124501-251202
12:45:03 script,info Sincronizacion finalizada. IPs: 6 - LastUpdate: 124501-251202
```

## 🛠️ Troubleshooting

### El script no se ejecuta automáticamente

Verifica el scheduler:
```
/system scheduler print
```

Asegúrate de que `scheduler-sync-blocked-ips` está habilitado.

### No se importan IPs

Verifica conectividad HTTPS:
```
/tool fetch url="https://raw.githubusercontent.com/TSCNEO/hayahora-blocked-ips/main/LastUpdate.txt" mode=https
```

### Ver errores en logs

```
/log print where topics~"error"
```

## 🔗 Integración con VPN

Para redirigir el tráfico de estas IPs por una VPN (WireGuard, OpenVPN, etc.), **primero necesitas tener configurada tu conexión VPN** (ver tutorial de configuración completa al final de esta sección), y luego crear una tabla de enrutamiento dedicada con las reglas correspondientes.

### Configuración completa paso a paso

#### 1. Crear tabla de enrutamiento dedicada

```
/routing table add name=VPN-TABLE fib
```

#### 2. Configurar NAT/Masquerade para el túnel VPN

```
/ip firewall nat add chain=srcnat out-interface=TU_INTERFAZ_VPN action=masquerade comment="NAT para trafico VPN"
```

*(Reemplaza `TU_INTERFAZ_VPN` con el nombre de tu interfaz: `WG01`, `ovpn-out1`, etc.)*

#### 3. Añadir ruta por defecto en la tabla VPN

```
/ip route add dst-address=0.0.0.0/0 gateway=TU_INTERFAZ_VPN routing-table=VPN-TABLE comment="Ruta por VPN"
```

#### 4. Marcar el tráfico destinado a IPs bloqueadas

```
/ip firewall mangle add chain=prerouting dst-address-list=IPsBloqueadas action=mark-routing new-routing-mark=VPN-TABLE passthrough=no comment="Trafico a IPs bloqueadas por VPN"
```

### Verificación

Para comprobar que el tráfico se está marcando correctamente:

```
# Ver paquetes marcados en mangle
/ip firewall mangle print stats

# Ver rutas activas en la tabla VPN
/ip route print where routing-table=VPN-TABLE

# Verificar NAT
/ip firewall nat print stats
```

### Ejemplo completo con nombres reales

```
# Ejemplo con WireGuard (interfaz WG01-Windscribe)
/routing table add name=FIB-WG01 fib
/ip firewall nat add chain=srcnat out-interface=WG01-Windscribe action=masquerade
/ip route add dst-address=0.0.0.0/0 gateway=WG01-Windscribe routing-table=FIB-WG01
/ip firewall mangle add chain=prerouting dst-address-list=IPsBloqueadas action=mark-routing new-routing-mark=FIB-WG01 passthrough=no
```

### Troubleshooting rutas

Si el tráfico no sale por la VPN:

```
# Verificar que las IPs están en la lista
/ip firewall address-list print where list="IPsBloqueadas"

# Hacer traceroute a una IP bloqueada
/tool traceroute 172.67.196.60

# Ver logs de conexión
/log print where topics~"firewall"
```


## 📝 Requisitos

- RouterOS v7.x o superior
- Acceso HTTPS habilitado
- Permisos: `ftp,read,write,policy,test`

## 🤝 Créditos

- **Autor**: TSCNEO (IA Assisted)
- **Fuente de datos**: [hayahora.futbol](https://hayahora.futbol)
- **Repositorio**: [hayahora-blocked-ips](https://github.com/TSCNEO/hayahora-blocked-ips)
- **Tutorial completo VPN + Mikrotik: [Manual Mikrotik integración VPN Windscribe WireGuard](https://foro.adslzone.net/mikrotik.199/manual-mikrotik-integracion-vpn-windscribe-wireguard.601074/)
## 📄 Licencia

MIT

---

**Nota**: Este script está diseñado para uso con el repositorio hayahora-blocked-ips que monitoriza bloqueos de IPs en España durante eventos de LaLiga.