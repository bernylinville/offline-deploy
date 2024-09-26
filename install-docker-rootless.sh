#!/bin/bash

set -euo pipefail

LOG_FILE="/tmp/docker-rootless-install.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始安装 Docker Rootless"

# ANSIBLE_DIR=${ANSIBLE_DIR:-/home/berny/ansible}
# DOCKER_VERSION=${DOCKER_VERSION:-27.2.0}
DOCKER_CONFIG_DIR="$HOME/.config/docker"
DOCKER_DATA_DIR="/data/docker"

# 检查系统版本
if ! grep -q 'openEuler 22.03' /etc/os-release; then
    log "错误：此脚本仅支持 openEuler 22.03"
    exit 1
fi

# 检查当前用户是否为 root
if [ "$(id -u)" -eq 0 ]; then
    log "请不要以 root 用户运行此脚本"
    exit 1
fi

[ -d "$DOCKER_CONFIG_DIR" ] || mkdir -p "$DOCKER_CONFIG_DIR"
[ -d "$DOCKER_DATA_DIR" ] || sudo mkdir -p "$DOCKER_DATA_DIR"
sudo chown -R "$USER:$USER" "$DOCKER_DATA_DIR"

cat <<EOF | tee ~/.config/docker/daemon.json
{
    "data-root": "/data/docker",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

dockerd-rootless-setuptool.sh install || {
    log "Docker 无根模式安装失败"
    exit 1
}

systemctl --user enable docker --now || {
    log "无法启用 Docker 服务"
    exit 1
}

systemctl --user is-active docker > /dev/null 2>&1 || {
    log "Docker 服务未处于活动状态"
    exit 1
}

# 将 DOCKER_HOST 环境变量添加到 .bashrc 文件
echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc

log "已将 DOCKER_HOST 环境变量添加到 .bashrc 文件"

# # 清理函数
# clean_up() {
#     log "清理临时文件"
#     rm -rf /tmp/docker /tmp/docker-rootless-extras
# }

# trap clean_up EXIT

log "Docker Rootless 安装完成"

# 配置代理
# mkdir -p ~/.config/systemd/user/docker.service.d
# cat <<EOF | tee ~/.config/systemd/user/docker.service.d/http-proxy.conf
# [Service]
# Environment="HTTP_PROXY=http://192.168.1.100:7890"
# Environment="HTTPS_PROXY=http://192.168.1.100:7890"
# Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
# EOF

# systemctl --user daemon-reload
# systemctl --user restart docker
