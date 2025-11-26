#!/usr/bin/env python3
"""
Resuelve todas las IPs del dominio blocked.dns.hayahora.futbol
y genera un archivo blocked-ips.txt con una IP por línea
"""

import dns.resolver
from datetime import datetime

DOMAIN = "blocked.dns.hayahora.futbol"
OUTPUT_FILE = "blocked-ips.txt"

def resolve_all_ips():
    """Resuelve todos los registros A del dominio"""
    ips = set()
    try:
        answers = dns.resolver.resolve(DOMAIN, 'A')
        for rdata in answers:
            ips.add(rdata.to_text())
        print(f"✓ Resueltas {len(ips)} IPs desde {DOMAIN}")
    except Exception as e:
        print(f"✗ Error resolviendo {DOMAIN}: {e}")
        return ips
    
    return ips

def write_ips_file(ips):
    """Escribe las IPs en el archivo"""
    with open(OUTPUT_FILE, 'w') as f:
        f.write(f"# IPs bloqueadas desde {DOMAIN}\n")
        f.write(f"# Generado: {datetime.now().isoformat()}\n")
        f.write(f"# Total: {len(ips)} IPs\n")
        f.write("#\n")
        for ip in sorted(ips):
            f.write(f"{ip}\n")
    print(f"✓ Archivo {OUTPUT_FILE} generado con {len(ips)} IPs")

if __name__ == "__main__":
    ips = resolve_all_ips()
    if ips:
        write_ips_file(ips)
    else:
        print("✗ No se resolvieron IPs, abortando")
        exit(1)
