
# 🧪 Entorno Seguro de Programación Java con Code-Server (VS Code Web)

Este entorno está diseñado para exámenes y prácticas seguras de programación en Java, utilizando una versión web de Visual Studio Code (Code-Server), ejecutada en contenedores Docker con restricciones controladas.

---

## 🚀 ¿Qué incluye esta imagen?

* 🧠 **VS Code Web (Code-Server)** versión ligera
* ☕ **Java (OpenJDK 17)** ya instalado
* 🔌 **Java Extension Pack** preinstalado
* ⚙️ **Configuraciones personalizadas**:

  * Sin pantalla de bienvenida ni tips
  * Sin actualizaciones automáticas
  * Sin sugerencias de extensiones
* 🔒 **Marketplace bloqueado (open-vsx.org)** mediante reglas `iptables`
* 🔐 Acceso con contraseña
* 💻 Terminal integrada y acceso a `git`, `javac`, `java`, etc.

---

## 📂 Estructura del proyecto

```
.
├── Dockerfile               # Imagen personalizada
├── entrypoint.sh            # Script de arranque con bloqueo de red
├── config.yaml              # Configuración de Code-Server
├── settings.json            # Preferencias del usuario
└── HelloWorld.java          # Proyecto base en Java
```

---

## ⚙️ ¿Cómo funciona?

Cuando se ejecuta el contenedor:

1. Se bloquea el acceso al marketplace (`open-vsx.org`) resolviendo su IP en tiempo de ejecución y aplicando reglas `iptables`.
2. Se lanza Code-Server en el puerto `8080`.
3. Se carga automáticamente el proyecto `HelloWorld` en el editor.
4. El estudiante accede vía navegador, sin posibilidad de instalar nuevas extensiones ni salir del entorno.

---

## 🛠️ Requisitos

* Docker instalado en la máquina del laboratorio
* Navegador compatible (funciona mejor con Chrome/Chromium o Firefox)
* Opcional: Safe Exam Browser para bloquear acceso a otras aplicaciones

---

## 🧪 Pasos para usar el entorno

### 1. Construir la imagen

Ubícate en la carpeta del proyecto y ejecuta:

```bash
docker build -t vscode-java-safe .
```

### 2. Ejecutar el contenedor

```bash
docker run -d \
  --name examen-java \
  -p 8080:8080 \
  vscode-java-safe
```

### 3. Acceder al entorno

Abre el navegador y visita:

```
http://localhost:8080
```

### 4. Iniciar sesión

🔑 Contraseña de acceso: `pwd123`
(Esta se puede cambiar en el archivo `config.yaml` si lo deseas)

---

## 📋 ¿Qué puede hacer el estudiante?

✅ Leer y editar el código Java
✅ Usar terminal integrada
✅ Compilar con `javac` y ejecutar con `java`
✅ Hacer `git clone`, `git push`, etc.
✅ Trabajar localmente de forma controlada

---

## 🚫 ¿Qué **NO** puede hacer el estudiante?

🚫 Instalar nuevas extensiones
🚫 Buscar extensiones en el marketplace
🚫 Ver tips o walkthrough
🚫 Salir de VS Code Web (si está restringido por Safe Exam Browser)

---

## 🧰 Personalización

Puedes reemplazar `HelloWorld.java` por tu propio proyecto o plantilla.

También puedes ajustar:

* La contraseña (`config.yaml`)
* Las preferencias del editor (`settings.json`)
* Agregar más bloqueos de red o dominios (`entrypoint.sh`)

---

## 🧼 Para detener y eliminar el contenedor

```bash
docker stop examen-java
docker rm examen-java
```

