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

Para redirigir el tráfico de estas IPs por una VPN, añade reglas de routing:

```
# Ejemplo: Marcar paquetes
/ip firewall mangle add chain=prerouting dst-address-list=IPsBloqueadas action=mark-routing new-routing-mark=VPN_TRAFFIC

# Ejemplo: Ruta por VPN
/ip route add dst-address-list=IPsBloqueadas gateway=TU_VPN_GATEWAY routing-mark=VPN_TRAFFIC
```

## 📝 Requisitos

- RouterOS v7.x o superior
- Acceso HTTPS habilitado
- Permisos: `ftp,read,write,policy,test`

## 🤝 Créditos

- **Autor**: TSCNEO
- **Fuente de datos**: [hayahora.futbol](https://hayahora.futbol)
- **Repositorio**: [hayahora-blocked-ips](https://github.com/TSCNEO/hayahora-blocked-ips)

## 📄 Licencia

MIT

---

**Nota**: Este script está diseñado para uso con el repositorio hayahora-blocked-ips que monitoriza bloqueos de IPs en España durante eventos de LaLiga.
```