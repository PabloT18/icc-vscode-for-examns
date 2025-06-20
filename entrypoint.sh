#!/bin/bash
set -e

# Bloquear tráfico al marketplace
# iptables no soporta dominios, por lo que resolvemos la IP de open-vsx.org en tiempo de ejecución.
if resolved_ip=$(getent hosts open-vsx.org | awk '{ print $1 }'); then
    iptables -A OUTPUT -d "$resolved_ip" -j REJECT || true
fi
iptables -A OUTPUT -d 65.9.95.66 -j REJECT || true

# Ejecutar como usuario coder sin shell de login
exec gosu coder dumb-init code-server --host 0.0.0.0 --port 8080 /home/coder/project
