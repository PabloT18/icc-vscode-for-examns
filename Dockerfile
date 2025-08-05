# Imagen base
FROM codercom/code-server:latest

# ------------------------- #
# 🔧 Bloque 1: Dependencias
# ------------------------- #
USER root
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk iptables dumb-init gosu jq && \
    apt-get clean  

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"


# Crear estructura de proyecto
RUN mkdir -p /home/coder/project/HelloWorld


# ------------------------- #
# 🔧 Bloque 2: Configuración fija
# ------------------------- #
# Copiar archivos de configuración primero para mantener cache
COPY config.yaml /home/coder/.config/code-server/config.yaml
COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY keybindings.json /home/coder/.local/share/code-server/User/keybindings.json
COPY entrypoint.sh /entrypoint.sh

# Preparación del entorno: permisos, carpetas, limpieza y bloqueo de configuraciones
RUN \
    # Hacer ejecutable el script de entrada
    chmod +x /entrypoint.sh && \
    # Crear la carpeta base del proyecto Java
    mkdir -p /home/coder/project && \
    # Crear las carpetas necesarias para el funcionamiento de Code-Server
    mkdir -p \
    /home/coder/.local/share/code-server/extensions \
    /home/coder/.local/share/code-server/User/globalStorage \
    /home/coder/.local/share/code-server/User/History \
    /home/coder/.local/share/code-server/Machine \
    /home/coder/.local/share/code-server/logs && \
    # Asignar la propiedad de todas esas carpetas al usuario coder
    chown -R coder:coder /home/coder/.local /home/coder/.config /home/coder/project && \
    # Eliminar almacenamiento previo de sesiones para evitar reapertura automática de archivos previos
    rm -rf \
    /home/coder/.local/share/code-server/User/workspaceStorage \
    /home/coder/.local/share/code-server/User/globalStorage \
    /home/coder/.local/share/code-server/User/History && \
    # Proteger el archivo settings.json: solo lectura y propiedad del root
    chown root:root /home/coder/.local/share/code-server/User/settings.json && \
    chmod 444 /home/coder/.local/share/code-server/User/settings.json && \
    # Proteger el archivo keybindings.json: solo lectura y propiedad del root
    chown root:root /home/coder/.local/share/code-server/User/keybindings.json && \
    chmod 444 /home/coder/.local/share/code-server/User/keybindings.json

# ------------------------- #
# 🔧 Bloque 3: Archivos del proyecto (esto sí cambia seguido)
# ------------------------- #
COPY HelloWorld.java /home/coder/project/HelloWorld/


# ------------------------- #
# 🔧 Bloque 4: Extensiones
# ------------------------- #
# Cambiar a usuario coder
USER coder
# Instalar extensión Java Pack (si se desea antes de bloquear el marketplace)
RUN code-server --install-extension vscjava.vscode-java-pack


# ------------------------- #
# 🔧 Bloque 5: Bloqueo del marketplace
# ------------------------- #
USER root
RUN jq '.extensionsGallery = null' /usr/lib/code-server/lib/vscode/product.json > /tmp/product.json && \
    mv /tmp/product.json /usr/lib/code-server/lib/vscode/product.json && \
    chown -R root:root /home/coder/.local/share/code-server/extensions && \
    chmod -R a-w /home/coder/.local/share/code-server/extensions

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]