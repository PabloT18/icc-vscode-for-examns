# Imagen base oficial de Code-Server (VS Code Web)
FROM codercom/code-server:latest

# Cambiar a usuario root para instalar dependencias
USER root

# Instalar OpenJDK 17 y iptables
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk iptables dumb-init gosu && \
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
    chmod 444 /home/coder/.local/share/code-server/User/settings.json



# Cambiar a usuario coder
# Cambiar a usuario coder
USER coder

# Instalar extensiones (solo después de tener todos los permisos)
RUN code-server --install-extension vscjava.vscode-java-pack

# Exponer puerto para Code-Server
EXPOSE 8080

# Ejecutar el entorno con bloqueo al marketplace
USER root
ENTRYPOINT ["/entrypoint.sh"]
