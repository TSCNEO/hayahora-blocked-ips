# ============================================================================
# Script: Sincronizacion Inteligente de IPs Bloqueadas
# Autor: TSCNEO (con asistencia de IA)
# Fecha: 2025-12-02
# Version: 1.0
# Repositorio: https://github.com/TSCNEO/hayahora-blocked-ips
# 
# Descripcion: 
#   Sincroniza lista de IPs bloqueadas desde GitHub verificando primero
#   el archivo LastUpdate.txt para determinar si hay cambios.
#   Solo descarga blocked-ips.txt cuando detecta actualizaciones.
# 
# Uso:
#   Automatico: Se ejecuta cada hora via scheduler
#   Manual: /system script run sync-blocked-ips
# ============================================================================


# Crear el script
/system script
add dont-require-permissions=no name=sync-blocked-ips owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local url\
    LastUpdate \"https://raw.githubusercontent.com/TSCNEO/hayahora-blocked-ips/main/LastUpdate.txt\"\r\
    \n:local urlIPs \"https://raw.githubusercontent.com/TSCNEO/hayahora-blocked-ips/main\
    /blocked-ips.txt\"\r\
    \n:local listName \"IPsBloqueadas\"\r\
    \n\r\
    \n:log info \"Verificando actualizaciones de IPs bloqueadas...\"\r\
    \n\r\
    \n# 1. Descargar LastUpdate.txt\r\
    \n:local fetchLastUpdate [/tool fetch url=\$urlLastUpdate output=user as-value]\r\
    \n\r\
    \n:if ([:typeof \$fetchLastUpdate] != \"nil\" && [:len (\$fetchLastUpdate->\"data\"\
    )] > 0) do={\r\
    \n  \r\
    \n  :local lastUpdateRaw (\$fetchLastUpdate->\"data\")\r\
    \n  :local newLastUpdate [:pick \$lastUpdateRaw 0 12]\r\
    \n  \r\
    \n  :log info \"LastUpdate en servidor: \$newLastUpdate\"\r\
    \n  \r\
    \n  # 2. Obtener LastUpdate actual\r\
    \n  :local existingEntry [/ip firewall address-list find list=\$listName]\r\
    \n  :local currentLastUpdate \"\"\r\
    \n  :local needsUpdate true\r\
    \n  \r\
    \n  :if ([:len \$existingEntry] > 0) do={\r\
    \n    :set currentLastUpdate [/ip firewall address-list get [:pick \$existingEntry\
    \_0] comment]\r\
    \n    :log info \"LastUpdate local actual: \$currentLastUpdate\"\r\
    \n    \r\
    \n    # 3. Comparar\r\
    \n    :if (\$currentLastUpdate = \$newLastUpdate) do={\r\
    \n      :log info \"Sin cambios en IPs. LastUpdate identico: \$newLastUpdate\"\r\
    \n      :set needsUpdate false\r\
    \n    }\r\
    \n  } else={\r\
    \n    :log info \"No hay IPs bloqueadas. Importacion inicial.\"\r\
    \n  }\r\
    \n  \r\
    \n  # 4. Actualizar solo si es necesario\r\
    \n  :if (\$needsUpdate = true) do={\r\
    \n    :log info \"LastUpdate diferente. Actualizando...\"\r\
    \n    :log info \"Anterior: \$currentLastUpdate -> Nuevo: \$newLastUpdate\"\r\
    \n    \r\
    \n    # Descargar blocked-ips.txt\r\
    \n    :local fetchIPs [/tool fetch url=\$urlIPs output=user as-value]\r\
    \n    \r\
    \n    :if ([:typeof \$fetchIPs] != \"nil\" && [:len (\$fetchIPs->\"data\")] > 0) d\
    o={\r\
    \n      :local content (\$fetchIPs->\"data\")\r\
    \n      \r\
    \n      # Eliminar IPs antiguas\r\
    \n      /ip firewall address-list remove [find list=\$listName]\r\
    \n      \r\
    \n      # Anadir IPs\r\
    \n      :local pos 0\r\
    \n      :local len [:len \$content]\r\
    \n      :local totalIPs 0\r\
    \n      \r\
    \n      :while (\$pos < \$len) do={\r\
    \n        :local nl [:find \$content \"\\n\" \$pos]\r\
    \n        :if (\$nl = nil) do={ :set nl \$len }\r\
    \n        \r\
    \n        :local line [:pick \$content \$pos \$nl]\r\
    \n        \r\
    \n        :if ([:len \$line] > 0) do={\r\
    \n          :local lastPos ([:len \$line] - 1)\r\
    \n          :if ([:pick \$line \$lastPos (\$lastPos + 1)] = \"\\r\") do={\r\
    \n            :set line [:pick \$line 0 \$lastPos]\r\
    \n          }\r\
    \n          \r\
    \n          :if ([:len \$line] > 0 && [:pick \$line 0 1] != \"#\") do={\r\
    \n            /ip firewall address-list add list=\$listName address=\$line comment=\
    \$newLastUpdate\r\
    \n            :set totalIPs (\$totalIPs + 1)\r\
    \n          }\r\
    \n        }\r\
    \n        \r\
    \n        :set pos (\$nl + 1)\r\
    \n      }\r\
    \n      \r\
    \n      :log info \"Sincronizacion finalizada. IPs: \$totalIPs - LastUpdate: \$newL\
    astUpdate\"\r\
    \n    } else={\r\
    \n      :log error \"Fallo al descargar blocked-ips.txt\"\r\
    \n    }\r\
    \n  }\r\
    \n  \r\
    \n} else={\r\
    \n  :log error \"Fallo al descargar LastUpdate.txt\"\r\
    \n}"

# Crear el scheduler para ejecucion automatica cada 15 minutos
/system scheduler
add interval=15m name=scheduler-sync-blocked-ips on-event=sync-blocked-ips \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup comment="Sincroniza IPs bloqueadas desde GitHub cada 15 minutos"

# Log de confirmacion
:log info "Script 'sync-blocked-ips' y scheduler instalados correctamente"
:log info "El script se ejecutara cada 15 minutos y al iniciar el router"
:log info "Para ejecutar manualmente: /system script run sync-blocked-ips"

