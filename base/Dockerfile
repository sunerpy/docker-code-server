FROM ubuntu:22.04
WORKDIR /config
# ssh端口为 3210
# docker run -d -v /remote-dev:/config -p 3210:22 --name dev-server 107255705363.dkr.ecr.cn-northwest-1.amazonaws.com.cn/sunerpy/remote-server:v0.0.5-20250717
# docker run -d -v /remote-dev:/config --network host --name dev-server 107255705363.dkr.ecr.cn-northwest-1.amazonaws.com.cn/sunerpy/remote-server:v0.0.8-20250723
# 环境变量配置
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 HOME=/config
ENV ZSH_CUSTOM=/config/.oh-my-zsh/custom
COPY authorized_keys ${HOME}/.ssh/authorized_keys
# 安装 openssh-server 和必要依赖
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
  curl \
  fontconfig \
  git \
  gnupg \
  locales \
  make \
  openssh-server \
  rsync \
  sudo \
  tree \
  unzip \
  vim \
  zip zsh zsh-autosuggestions zsh-syntax-highlighting && \
  rm -rf /var/lib/apt/lists/* && \
  # 创建 SSH 运行目录\
  mkdir /var/run/sshd && \
  # 添加用户 ubuntu，允许 sudo，禁止密码登录
  useradd -m -d ${HOME} -s /bin/bash appuser && \
  echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  mkdir -p ${HOME}/.ssh && \
  chown -R appuser:appuser ${HOME}/.ssh && \
  chmod 700 ${HOME}/.ssh && \
  chown appuser:appuser ${HOME}/.ssh/authorized_keys && \
  chmod 600 ${HOME}/.ssh/authorized_keys && \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && \
  # 配置 sshd：禁用密码登录、禁用 root、启用密钥登录
  sed -i \
  -e 's/^#\?\s*PasswordAuthentication\s\+.*/PasswordAuthentication no/' \
  -e 's/^#\?\s*PermitRootLogin\s\+.*/PermitRootLogin no/' \
  -e 's/^#\?\s*PubkeyAuthentication\s\+.*/PubkeyAuthentication yes/' \
  /etc/ssh/sshd_config && \
  sed -i 's/^#\?Port .*/Port 3210/' /etc/ssh/sshd_config && \
  chmod -x /etc/update-motd.d/* && \
  # 安装aws cli
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && \
  cd /tmp && unzip awscliv2.zip  && \
  rm -f awscliv2.zip && ./aws/install && \
  rm -rf /tmp/* && find /usr/local -depth \
  \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
  -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) \
  -exec rm -rf '{}' + && \
  # 安装 zsh
  (echo "y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)") && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
  echo "source ${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc && \
  chsh -s /bin/zsh && fc-cache -f -v && \
  echo 'HISTSIZE=100000' >> /etc/profile && \
  # 安装 uv 
  curl -LsSf https://astral.sh/uv/install.sh | sh && \
  chown -R appuser:appuser ${HOME} && \
  chsh -s /bin/zsh appuser

COPY --chown=0:0 ssh/* /etc/ssh/
# COPY font/* /usr/local/share/fonts/meslo/
# 启动 sshd 为主进程
CMD ["sh", "-c", "/usr/sbin/sshd -D"]
