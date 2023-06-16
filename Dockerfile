FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS builder
ARG DEBIAN_FRONTEND="noninteractive"
ENV LANG C.UTF-8
COPY requirements.txt /
ADD teop-sdk-python.tar.gz /teop
# 安装依赖和编译工具
RUN apt-get update && \
  apt-get install -y build-essential curl libffi-dev libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  llvm libncurses5-dev xz-utils tk-dev liblzma-dev libffi-dev  make  wget  libncursesw5-dev openssl zlib1g \
xz-utils tk-dev libffi-dev liblzma-dev  && \
  rm -rf /var/lib/apt/lists/*

# 下载 Python 3.11.3 源码并解压
RUN curl -O http://webserver.onethinker.top:33080/Python-3.11.3.tgz && \
  tar xf Python-3.11.3.tgz && curl -O http://webserver.onethinker.top:33080/Python-3.6.5.tar.xz && tar xf Python-3.6.5.tar.xz

# 编译和安装 Python 3.11.3
# RUN cd /Python-3.6.5 &&  ./configure --prefix=/usr/local/python-3.6.5 --enable-optimizations --enable-shared && \
#   make  && \
#   make install
RUN cd /Python-3.11.3 &&  ./configure --prefix=/usr/local/python-3.11.3 --enable-optimizations --enable-shared && \
  make -j $(nproc) && \
  make altinstall && pip3 install -r /requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir && rm -f /requirements.txt && \
  cd /teop/teop-sdk-python && python3 setup.py install && pip cache purge

# 第二阶段，构建 Python 应用镜像
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
ARG DEBIAN_FRONTEND="noninteractive"
# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"
ENV HOME="/config"
# 拷贝 Python 3.11.3 环境
COPY --from=builder /usr/local/python-3.11.3 /usr/local/python-3.11.3

# 拷贝 Python 3.6.5 环境
# COPY --from=builder /usr/local/python-3.6.5 /usr/local/python3.6.5

# 更新 apt 并安装应用所需依赖
RUN apt-get update && \
  apt-get install -y libffi7 libssl1.1 zlib1g libbz2-1.0 libreadline8  libncursesw6 liblzma5 \
  procps  subversion inetutils-ping telnet openssl libsecret-1-0 \
  git openjdk-18-jdk-headless nodejs npm golang \
  jq \
  libatomic1 \
  net-tools \
  netcat \
  sudo && ln -s /usr/local/python-3.11.3/bin/python3.11 /usr/bin/python3 && \
  ln -s /usr/local/python-3.11.3/bin/pip3.11 /usr/bin/pip3 &&  ln -s /usr/bin/python3 /usr/bin/python && \
  echo 'export PATH=/usr/local/python-3.11.3/bin:/usr/local/python-3.6.5/bin:$PATH' >> /etc/profile && \
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
# COPY requirements.txt /
# RUN pip3 install -r /requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir && rm -f /requirements.txt && \
#   pip cache purge
# npm install -g code-settings-sync && npm cache clean --force

# RUN pip install types-requests types-redis --no-cache-dir

# add local files
COPY openssl.cnf  /etc/ssl/openssl.cnf
COPY /root /

# ports and volumes
EXPOSE 8443
