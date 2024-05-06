FROM 107255705363.dkr.ecr.cn-northwest-1.amazonaws.com.cn/linuxserver/baseimage-ubuntu:jammy AS builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBIAN_FRONTEND="noninteractive"
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
ARG PYTHONNUM='3.11'
ARG PYTHONVERALL="3.11.7"
ARG PYTHONVER="python-3.11.7"
ARG PYTHONFILENAME='Python-3.11.7'
ARG PYLIBS="/config/pylibs/python3.11.7"
ARG GOFILE="go1.21.0.linux-amd64.tar.xz"
ARG NODE_VERSION="v18.17.1"
ARG NODE_DISTRO="linux-x64"
ARG NODEFILE="node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz" 
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"
ENV LANG C.UTF-8
# 安装依赖和编译工具
RUN apt-get update && \
  apt-get install -y build-essential curl libffi-dev libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  llvm libncurses5-dev xz-utils tk-dev liblzma-dev libffi-dev  make  wget  libncursesw5-dev openssl zlib1g \
  xz-utils tk-dev libffi-dev liblzma-dev libkrb5-dev && \
  rm -rf /var/lib/apt/lists/* && cd / && curl -LO https://www.python.org/ftp/python/${PYTHONVERALL}/${PYTHONFILENAME}.tgz && \
  tar xf ${PYTHONFILENAME}.tgz && cd /${PYTHONFILENAME} &&  ./configure --prefix=/usr/local/${PYTHONVER} --enable-optimizations --enable-shared && \
  make -j $(nproc) && \
  make altinstall && cd / && rm -rf /${PYTHONFILENAME} /${PYTHONFILENAME}.tgz

# # 下载 Python 3.11.7 源码并解压
# # RUN curl -O http://webserver.onethinker.top:33080/Python-3.11.7.tgz && \
# #   tar xf Python-3.11.7.tgz && curl -O http://webserver.onethinker.top:33080/Python-3.6.5.tar.xz && tar xf Python-3.6.5.tar.xz
# RUN curl -O https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz && \
#   tar xf Python-3.11.7.tgz

# 第二阶段，构建 Python 应用镜像
FROM 107255705363.dkr.ecr.cn-northwest-1.amazonaws.com.cn/linuxserver/baseimage-ubuntu:jammy
ARG DEBIAN_FRONTEND="noninteractive"
# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
ARG PYTHONNUM='3.11'
ARG PYTHONVERALL="3.11.7"
ARG PYTHONVER="python-3.11.7"
ARG PYTHONFILENAME='Python-3.11.7'
ARG PYLIBS="/config/pylibs/python3.11.7"
ARG GOFILE="go1.21.0.linux-amd64.tar.xz"
ARG NODE_VERSION="v18.17.1"
ARG NODE_DISTRO="linux-x64"
ARG NODEFILE="node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz" 
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"
ENV HOME="/config" PYTHONPATH="/usr/local/${PYTHONVER}/lib/python${PYTHONNUM}/site-packages:${PYLIBS}/site-packages" GOPATH="/config/gopath"  GOPROXY="https://goproxy.cn,direct"
# 拷贝 Python 3.11.7 环境
COPY --from=builder /usr/local/${PYTHONVER} /usr/local/${PYTHONVER}
# 更新 apt 并安装应用所需依赖
RUN echo 'abc:Test12#$' |chpasswd && echo 'root:Test12#$' |chpasswd && \
  # echo 'abc ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y libreadline8  libncursesw6 liblzma5 build-essential \
  procps  subversion inetutils-ping telnet openssl libssl-dev libsecret-1-0 libncurses5-dev libncursesw5-dev \
  curl libbz2-dev libreadline-dev llvm xz-utils tk-dev liblzma-dev libffi-dev libgdbm-dev libgdbm-compat-dev \
  debian-keyring debian-archive-keyring apt-transport-https openssh-client maven krb5-config \
  vim bash-completion groff less unzip rsync \
  openjdk-18-jdk-headless \
  git jq libatomic1 net-tools netcat sudo amazon-ecr-credential-helper --no-install-recommends && \
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' |gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg &&\
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
  apt-get update && apt-get install -y caddy && \
  # cd / && curl -LO https://www.python.org/ftp/python/${PYTHONVERALL}/${PYTHONFILENAME}.tgz && \
  # tar xf ${PYTHONFILENAME}.tgz && cd /${PYTHONFILENAME} &&  ./configure --prefix=/usr/local/${PYTHONVER} --enable-optimizations --enable-shared && \
  # make -j $(nproc) && \
  # make altinstall && cd / && rm -rf /${PYTHONFILENAME} /${PYTHONFILENAME}.tgz && \
  apt-get remove -y debian-keyring debian-archive-keyring apt-transport-https && \
  sed -i '/root.*ALL/aabc ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers && \
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
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip  && rm -f awscliv2.zip && ./aws/install && rm -rf /aws && \
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
  echo "export PATH=\"/usr/local/${PYTHONVER}/bin:/usr/local/go/bin:\$PATH:/usr/local/lib/nodejs/node-${NODE_VERSION}-${NODE_DISTRO}/bin:${PYLIBS}/site-packages/bin\"" >> /etc/profile && \
  # echo "export PYTHONPATH=\"${PYLIBS}/site-packages:\$PYTHONPATH\"" >> /etc/profile && \
  ln -s /usr/local/${PYTHONVER}/bin/pip${PYTHONNUM} /usr/bin/pip3 && ln -s /usr/bin/pip3 /usr/bin/pip && \
  ln -s /usr/local/${PYTHONVER}/bin/python${PYTHONNUM} /usr/bin/python3 && ln -s /usr/bin/python3 /usr/bin/python && \
  # python3 -m pip install --upgrade pip && \
  # pip3 install -r /requirements.txt --no-cache-dir --upgrade -i https://mirrors.aliyun.com/pypi/simple/ && \
  cd /teop/teop-sdk-python && python3 setup.py install && mkdir /config/gopath /usr/local/go && pip3 install ansible==5.10.0 --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/  && pip3 install ansible-lint -i https://mirrors.aliyun.com/pypi/simple/  --no-cache-dir && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) -exec rm -rf '{}' + ;
ADD ${GOFILE} /usr/local
ADD ${NODEFILE} /usr/local/lib/nodejs
RUN echo 'HISTSIZE=100000' >> /etc/profile
# RUN export PATH=$PATH:/usr/local/go/bin && export GOPATH=/config/gopath
# /usr/local/go/bin/go install golang.org/x/tools/gopls@latest && \
# /usr/local/go/bin/go install -v golang.org/x/tools/cmd/goimports@latest && /usr/local/go/bin/go install -v github.com/stamblerre/gocode@latest && \
# /usr/local/go/bin/go install -v github.com/rogpeppe/godef@latest && /usr/local/go/bin/go install -v github.com/go-delve/delve/cmd/dlv@latest
# add local files
COPY openssl.cnf  /etc/ssl/openssl.cnf
COPY /root /

# ports and volumes
EXPOSE 8443
