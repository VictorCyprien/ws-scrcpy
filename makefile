build:
	docker build -t ws-scrcpy:latest .

run:
	docker run --rm -p 8001:8001 \
		-e ADB_HOST=host.docker.internal \
		-e ADB_PORT=5037 \
		-e ADB_SERVER_SOCKET='tcp:host.docker.internal:5037' \
		-e ADB_FORWARD_HOST=host.docker.internal \
  		ws-scrcpy:latest