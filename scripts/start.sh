#!/usr/bin/with-contenv bash
# XRDP 服务启动脚本 - 简化版

# 移除可能存在的 PID 文件（防止容器重启时挂起）
[ -f /var/run/xrdp/xrdp-sesman.pid ] && rm -f /var/run/xrdp/xrdp-sesman.pid
[ -f /var/run/xrdp/xrdp.pid ] && rm -f /var/run/xrdp/xrdp.pid

# 启动 SSH
echo "启动 SSH 服务..."
[ ! -f /etc/ssh/ssh_host_rsa_key ] && ssh-keygen -A
/usr/sbin/sshd

# 启动 xrdp-sesman
echo "启动 xrdp-sesman..."
/usr/sbin/xrdp-sesman
echo 'abc:redhat' |chpasswd
# 启动 xrdp（前台运行以保持容器活跃）
echo "启动 xrdp..."
echo "使用 RDP 客户端连接到端口 3389"
exec /usr/sbin/xrdp --nodaemon
# exec s6-setuidgid abc /run_novnc
