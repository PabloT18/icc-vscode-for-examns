#!/bin/bash
set -e

# Bloquear tráfico al marketplace
# iptables no soporta dominios, por lo que resolvemos la IP de open-vsx.org en tiempo de ejecución.
# Bloquear todas las IPs que resuelva open-vsx.org (marketplace de extensiones)
# Ejecutar iptables como root
if resolved_ips=$(getent ahosts open-vsx.org | awk '{ print $1 }' | sort -u); then
  for ip in $resolved_ips; do
    echo "Bloqueando IP del marketplace: $ip"
    iptables -A OUTPUT -d "$ip" -j REJECT || true
  done
fi
# Si se proporciona un repositorio remoto, clónalo en el área de trabajo
# if [ -n "$GIT_REPO_URL" ]; then
#     gosu coder git clone "$GIT_REPO_URL" /home/coder/project || true
# fi

# Ejecutar como usuario coder sin shell de login
exec gosu coder dumb-init code-server --host 0.0.0.0 --port 8080 /home/coder/project
# exec code-server --host 0.0.0.0 --port 8080 /home/coder/project
