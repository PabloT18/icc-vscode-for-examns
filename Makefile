# Nombre de la imagen local
IMAGE_NAME=vscode-safe
TAG=latest

# Imagen en Docker Hub (reemplaza con tu usuario real)
DOCKER_USER=pablot18
REMOTE_IMAGE=$(DOCKER_USER)/$(IMAGE_NAME):$(TAG)

# Construcción para arquitectura actual (rápida, solo para pruebas locales)
build-local:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Construcción para arquitectura AMD64 (PCs Intel)
build-amd64:
	docker buildx build --platform linux/amd64 -t $(REMOTE_IMAGE) --push .

# Construcción multi-arquitectura (para publicar en Docker Hub)
build-multi:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(REMOTE_IMAGE) --push .

# Subir imagen construida localmente (por ejemplo, build-local o build-amd64)
push:
	docker tag $(IMAGE_NAME):$(TAG) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

# Eliminar imágenes locales
clean:
	docker rmi $(IMAGE_NAME):$(TAG) || true
	docker rmi $(REMOTE_IMAGE) || true
