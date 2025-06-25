# Imagen base oficial de Code-Server (VS Code Web)
FROM codercom/code-server:latest

# Cambiar a usuario root para instalar dependencias
USER root

# Instalar OpenJDK 17 y iptables
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk iptables dumb-init gosu jq && \
    apt-get clean




# Definir variables de entorno de Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Crear estructura de proyecto
RUN mkdir -p /home/coder/project/HelloWorld


# Copiar archivos al contenedor
COPY HelloWorld.java /home/coder/project/HelloWorld/
COPY config.yaml /home/coder/.config/code-server/config.yaml
COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY keybindings.json /home/coder/.local/share/code-server/User/keybindings.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Crear todas las carpetas necesarias y dar permisos antes de cambiar a coder
RUN mkdir -p \
    /home/coder/.local/share/code-server/extensions \
    /home/coder/.local/share/code-server/User/globalStorage \
    /home/coder/.local/share/code-server/User/History \
    /home/coder/.local/share/code-server/Machine \
    /home/coder/.local/share/code-server/logs && \
    chown -R coder:coder /home/coder/.local /home/coder/.config /home/coder/project 


# Borrar historial de sesiones anteriores para que no se abra settings.json automáticamente
RUN rm -rf /home/coder/.local/share/code-server/User/workspaceStorage \
    /home/coder/.local/share/code-server/User/globalStorage \
    /home/coder/.local/share/code-server/User/History

# Asegurar permisos y proteger settings.json (solo lectura para coder)
RUN chown root:root /home/coder/.local/share/code-server/User/settings.json && \
    chmod 444 /home/coder/.local/share/code-server/User/settings.json && \
    chown root:root /home/coder/.local/share/code-server/User/keybindings.json && \
    chmod 444 /home/coder/.local/share/code-server/User/keybindings.json



# Cambiar a usuario coder
# Cambiar a usuario coder
USER coder
# Instalar extensión Java Pack (si se desea antes de bloquear el marketplace)
RUN code-server --install-extension vscjava.vscode-java-pack

# Desactivar completamente el marketplace en Code-Server
USER root
RUN sed -i 's#"extensionsGallery": {[^}]*}#"extensionsGallery": null#' /usr/lib/code-server/lib/vscode/product.json

RUN jq '.extensionsGallery = null' /usr/lib/code-server/lib/vscode/product.json > /tmp/product.json && \
    mv /tmp/product.json /usr/lib/code-server/lib/vscode/product.json
# Proteger extensiones: impedir instalación, pero permitir uso
RUN chown -R root:root /home/coder/.local/share/code-server/extensions && \
    chmod -R a-w /home/coder/.local/share/code-server/extensions

# Exponer puerto para Code-Server
EXPOSE 8080

# Ejecutar el entorno con bloqueo al marketplace
ENTRYPOINT ["/entrypoint.sh"]
