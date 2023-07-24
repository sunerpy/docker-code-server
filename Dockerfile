# FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS builder
# ARG DEBIAN_FRONTEND="noninteractive"
# ENV LANG C.UTF-8
# # 安装依赖和编译工具
# RUN apt-get update && \
#   apt-get install -y build-essential curl libffi-dev libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  llvm libncurses5-dev xz-utils tk-dev liblzma-dev libffi-dev  make  wget  libncursesw5-dev openssl zlib1g \
#   xz-utils tk-dev libffi-dev liblzma-dev  && \
#   rm -rf /var/lib/apt/lists/*

# # 下载 Python 3.11.3 源码并解压
# # RUN curl -O http://webserver.onethinker.top:33080/Python-3.11.3.tgz && \
# #   tar xf Python-3.11.3.tgz && curl -O http://webserver.onethinker.top:33080/Python-3.6.5.tar.xz && tar xf Python-3.6.5.tar.xz
# RUN curl -O https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tgz && \
#   tar xf Python-3.11.3.tgz

# # 编译和安装 Python 3.11.3
# # RUN cd /Python-3.6.5 &&  ./configure --prefix=/usr/local/python-3.6.5 --enable-optimizations --enable-shared && \
# #   make  && \
# #   make install
# RUN cd /Python-3.11.3 &&  ./configure --prefix=/usr/local/python-3.11.3 --enable-optimizations --enable-shared && \
#   make -j $(nproc) && \
#   make altinstall
# # RUN /usr/local/python-3.11.3/bin/pip3.11 install -r /requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir && rm -f /requirements.txt && \
# #   cd /teop/teop-sdk-python && /usr/local/python-3.11.3/bin/python3.11 setup.py install && /usr/local/python-3.11.3/bin/pip3.11 cache purge
# 第二阶段，构建 Python 应用镜像
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
ARG DEBIAN_FRONTEND="noninteractive"
# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
ARG PYTHONNUM='3.11'
ARG PYTHONVERALL="3.11.3"
ARG PYTHONVER="python-3.11.3"
ARG PYTHONFILENAME='Python-3.11.3'
ARG GOFILE='go1.20.5.src.tar.gz'
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"
ENV HOME="/config"
# ENV PYTHONPATH="/usr/local/${PYTHONVER}/lib/python${PYTHONNUM}/site-packages"
# 拷贝 Python 3.11.3 环境
# COPY --from=builder /usr/local/${PYTHONVER} /usr/local/${PYTHONVER}
# 更新 apt 并安装应用所需依赖
RUN apt-get update && \
  apt-get install -y libffi7 make zlib1g zlib1g-dev libbz2-1.0 libsqlite3-dev libreadline8  libncursesw6 liblzma5 \
  procps  subversion inetutils-ping telnet openssl libssl-dev libsecret-1-0 libncurses5-dev libncursesw5-dev \
  curl libbz2-dev libreadline-dev llvm xz-utils tk-dev liblzma-dev libffi-dev libgdbm-dev libgdbm-compat-dev \
  debian-keyring debian-archive-keyring apt-transport-https openssh-client \
  git openjdk-18-jdk-headless nodejs jq libatomic1 net-tools netcat sudo build-essential golang --no-install-recommends && \
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' |gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg &&\
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
  apt-get update && apt-get install -y caddy && go install -v golang.org/x/tools/gopls@latest &&\
  cd / && curl -LO https://www.python.org/ftp/python/${PYTHONVERALL}/${PYTHONFILENAME}.tgz && \
  tar xf ${PYTHONFILENAME}.tgz && cd /${PYTHONFILENAME} &&  ./configure --prefix=/usr/local/${PYTHONVER} --enable-optimizations --enable-shared && \
  make -j $(nproc) && \
  make altinstall && cd / && rm -rf /${PYTHONFILENAME} /${PYTHONFILENAME}.tgz && \
  go install -v golang.org/x/tools/gopls@latest && \
  apt-get remove -y debian-keyring debian-archive-keyring apt-transport-https && \
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
ADD teop-sdk-python.tar.gz /teop
RUN echo "/usr/local/${PYTHONVER}/lib" >> /etc/ld.so.conf && /sbin/ldconfig -v && \
  echo "export PATH=\"/usr/local/${PYTHONVER}/bin:\$PATH\"" >> /etc/profile && \
  ln -s /usr/local/${PYTHONVER}/bin/pip${PYTHONNUM} /usr/bin/pip3 && ln -s /usr/bin/pip3 /usr/bin/pip && \
  ln -s /usr/local/${PYTHONVER}/bin/python${PYTHONNUM} /usr/bin/python3 && ln -s /usr/bin/python3 /usr/bin/python && \
  python3 -m pip install --upgrade pip && \
  pip3 install -r /requirements.txt --no-cache-dir && \
  cd /teop/teop-sdk-python && python3 setup.py install

# add local files
COPY openssl.cnf  /etc/ssl/openssl.cnf
COPY /root /

# ports and volumes
EXPOSE 8443
