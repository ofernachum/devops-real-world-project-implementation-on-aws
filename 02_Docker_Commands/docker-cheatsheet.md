# Docker Command Cheatsheet (1 Pager)

This quick reference is based on the materials in the 02_Docker_Commands folder.

| Task | Command syntax and example |
|---|---|
| Verify Docker install | Syntax: `docker version`<br>Example: `docker version` |
| Install Docker on Amazon Linux 2023 | Syntax: `sudo dnf update -y && sudo dnf install docker -y && sudo systemctl enable docker && sudo systemctl start docker`<br>Example: `sudo dnf update -y && sudo dnf install docker -y && sudo systemctl enable docker && sudo systemctl start docker` |
| Add current user to Docker group | Syntax: `sudo usermod -aG docker <USER>`<br>Example: `sudo usermod -aG docker ec2-user` |
| List local images | Syntax: `docker images`<br>Example: `docker images` |
| Pull image from Docker Hub | Syntax: `docker pull <IMAGE_NAME>:<TAG>`<br>Example: `docker pull stacksimplify/retail-store-sample-ui:1.0.0` |
| Pull image from GitHub Container Registry | Syntax: `docker pull ghcr.io/<ORG>/<IMAGE_NAME>:<TAG>`<br>Example: `docker pull ghcr.io/stacksimplify/retail-store-sample-ui:1.0.0` |
| Run a container in background with port mapping | Syntax: `docker run --name <CONTAINER_NAME> -p <HOST_PORT>:<CONTAINER_PORT> -d <IMAGE_NAME>:<TAG>`<br>Example: `docker run --name myapp1 -p 8888:8080 -d stacksimplify/retail-store-sample-ui:1.0.0` |
| List running containers | Syntax: `docker ps`<br>Example: `docker ps` |
| List all containers | Syntax: `docker ps -a`<br>Example: `docker ps -a` |
| Enter a running container shell | Syntax: `docker exec -it <CONTAINER_NAME> /bin/sh`<br>Example: `docker exec -it myapp1 /bin/sh` |
| Execute a single command in container | Syntax: `docker exec -it <CONTAINER_NAME> <COMMAND>`<br>Example: `docker exec -it myapp1 curl http://localhost:8080` |
| Stop a running container | Syntax: `docker stop <CONTAINER_NAME>`<br>Example: `docker stop myapp1` |
| Start a stopped container | Syntax: `docker start <CONTAINER_NAME>`<br>Example: `docker start myapp1` |
| Remove a container | Syntax: `docker rm <CONTAINER_NAME>`<br>Example: `docker rm myapp1` |
| Force stop and remove container | Syntax: `docker rm -f <CONTAINER_NAME>`<br>Example: `docker rm -f myapp1` |
| Remove an image by ID | Syntax: `docker rmi <IMAGE_ID>`<br>Example: `docker rmi abc12345def6` |
| Remove an image by name:tag | Syntax: `docker rmi <IMAGE_NAME>:<TAG>`<br>Example: `docker rmi stacksimplify/retail-store-sample-ui:1.0.0` |
| Build an image from Dockerfile | Syntax: `docker build -t <IMAGE_NAME>:<TAG> .`<br>Example: `docker build -t retail-store-sample-ui:2.0.0 .` |
| Tag an image for Docker Hub | Syntax: `docker tag <SOURCE_IMAGE>:<TAG> <DOCKERHUB_USER>/<TARGET_IMAGE>:<TAG>`<br>Example: `docker tag retail-store-sample-ui:2.0.0 stacksimplify/retail-store-sample-ui:2.0.0` |
| Login to Docker Hub | Syntax: `docker login`<br>Example: `docker login` |
| Push image to Docker Hub | Syntax: `docker push <DOCKERHUB_USER>/<IMAGE_NAME>:<TAG>`<br>Example: `docker push stacksimplify/retail-store-sample-ui:2.0.0` |
| Logout from Docker Hub | Syntax: `docker logout`<br>Example: `docker logout` |

## Use with care

- `docker rm -f <CONTAINER_NAME>`: force-removes containers immediately.
- `docker rmi <IMAGE_ID>` and `docker rmi <IMAGE_NAME>:<TAG>`: deletes local images.
- `docker system prune`: removes all unused Docker data.

## Notes

- Replace placeholders like `<CONTAINER_NAME>`, `<IMAGE_NAME>`, `<TAG>`, and `<DOCKERHUB_USER>` with real values.
- If Docker group permissions were just added, logout/login before running Docker without sudo.
