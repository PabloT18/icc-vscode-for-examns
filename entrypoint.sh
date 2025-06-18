#!/bin/bash
set -e

# Bloquear tráfico al marketplace
iptables -A OUTPUT -d open-vsx.org -j REJECT || true
iptables -A OUTPUT -d 65.9.95.66 -j REJECT || true

# Ejecutar como usuario coder sin shell de login
exec gosu coder dumb-init code-server --host 0.0.0.0 --port 8080 /home/coder/project
