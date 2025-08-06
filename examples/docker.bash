#!/bin/bash

# 如果需要在code-server内进行docker构建等操作，需要启动dind镜像，否则可以忽略
# docker run -d \
#   --name dind \
#   --privileged \
#   --volume cache-dir:/var/run \
#   --network host \
#   docker:26.0.1-dind \
#   dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:8000

docker run -d \
    --name code-server \
    --privileged \
    --volume /host/data/path/to/code-server:/config \
    --volume cache-dir:/var/run \
    --network host \
    -e PASSWORD="password" \
    -e TZ=Asia/Shanghai \
    -e DEFAULT_WORKSPACE=/config/workspace \
    -e PUID=1000 \
    -e PGID=1000 \
    sunerpy/code-server:4.102.3
