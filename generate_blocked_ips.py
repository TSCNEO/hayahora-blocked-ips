#!/usr/bin/env python3
"""
Resuelve todas las IPs del dominio blocked.dns.hayahora.futbol
y genera un archivo blocked-ips.txt con una IP por línea.

Si el dominio no responde, no tiene respuesta A o hay timeout,
el script no falla: termina correctamente para no romper el workflow.
"""

import sys
import dns.resolver

DOMAIN = "blocked.dns.hayahora.futbol"
OUTPUT_FILE = "blocked-ips.txt"


def resolve_all_ips():
    """Resuelve todos los registros A del dominio."""
    ips = set()

    resolver = dns.resolver.Resolver()
    resolver.timeout = 5
    resolver.lifetime = 5

    try:
        answers = resolver.resolve(DOMAIN, "A")
        for rdata in answers:
            ips.add(rdata.to_text())

        print(f"✓ Resueltas {len(ips)} IPs desde {DOMAIN}")
        return ips

    except dns.resolver.NoAnswer:
        print(f"⚠ {DOMAIN}: el DNS no devolvió respuesta A. Se omite esta ejecución.")
        return ips

    except dns.resolver.NXDOMAIN:
        print(f"⚠ {DOMAIN}: el dominio no existe. Se omite esta ejecución.")
        return ips

    except dns.resolver.Timeout:
        print(f"⚠ {DOMAIN}: timeout DNS. Se omite esta ejecución.")
        return ips

    except dns.resolver.NoNameservers:
        print(f"⚠ {DOMAIN}: no hay nameservers disponibles. Se omite esta ejecución.")
        return ips

    except Exception as e:
        print(f"⚠ Error resolviendo {DOMAIN}: {e}. Se omite esta ejecución.")
        return ips


def write_ips_file(ips):
    """Escribe las IPs en el archivo."""
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        for ip in sorted(ips):
            f.write(f"{ip}\n")

    print(f"✓ Archivo {OUTPUT_FILE} generado con {len(ips)} IPs")


if __name__ == "__main__":
    ips = resolve_all_ips()

    if ips:
        write_ips_file(ips)
    else:
        print("⚠ No se resolvieron IPs. Se conserva el archivo actual y el workflow sigue OK.")
        sys.exit(0)
