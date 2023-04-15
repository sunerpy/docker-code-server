FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y procps python3 python3-pip subversion inetutils-ping telnet openssl libsecret-1-0 gnupg2 pass gnome-keyring\
    git openjdk-8-jdk \
    jq \
    libatomic1 \
    net-tools \
    netcat \
    sudo && ln -s /usr/bin/python3 /usr/bin/python && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
COPY requirements.txt /
RUN pip install -r /requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir && rm -f /requirements.txt
# add local files
COPY openssl.cnf  /etc/ssl/openssl.cnf
COPY /root /

# ports and volumes
EXPOSE 8443
