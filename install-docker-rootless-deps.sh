#!/bin/bash

set -euo pipefail

LOG_FILE="/tmp/docker-rootless-install.log"
DOCKER_VERSION=${DOCKER_VERSION:-27.2.0}
DOCKER_FILE="${FILES_DIR}/docker-${DOCKER_VERSION}.tgz"
DOCKER_ROOTLESS_FILE="${FILES_DIR}/docker-rootless-extras-${DOCKER_VERSION}.tgz"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始安装 Docker Rootless"

ANSIBLE_DIR=${ANSIBLE_DIR:-/home/berny/ansible}
# DOCKER_VERSION=${DOCKER_VERSION:-27.2.0}
CURRENT_USER=$(whoami)

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

# 检查必要的命令
for cmd in dnf rpm sudo; do
    if ! command -v $cmd &> /dev/null; then
        log "错误：未找到命令 '$cmd'。请确保它已安装。"
        exit 1
    fi
done

# 创建本地 offline dnf repo 源
cat <<EOF | sudo tee /etc/yum.repos.d/offline.repo
[offline]
name=Offline Repository
baseurl=file:///home/berny/ansible/rpms
enabled=1
gpgcheck=0
EOF

sudo chmod 644 /etc/yum.repos.d/offline.repo
sudo dnf makecache

# 安装依赖包
packages=(systemd-devel dbus-devel slirp4netns fuse-overlayfs tar tmux sshpass)
missing_packages=()
for package in "${packages[@]}"; do
    if ! rpm -q "$package" &>/dev/null; then
        missing_packages+=("$package")
    fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
    log "正在安装缺失的包: ${missing_packages[*]}"
    if ! sudo dnf install -y --disablerepo="*" --enablerepo="offline" "${missing_packages[@]}"; then
        log "错误：安装包失败，请检查网络连接或软件源配置"
        exit 1
    fi
else
    log "所有必要的包已安装，跳过安装步骤"
fi

# 禁用系统 Docker 服务（如果存在）
if systemctl list-units --full -all | grep -Fq 'docker.service'; then
    sudo systemctl disable --now docker.service
fi

if systemctl list-units --full -all | grep -Fq 'docker.socket'; then
    sudo systemctl disable --now docker.socket
fi

if [ -e /var/run/docker.sock ]; then
    sudo rm /var/run/docker.sock
fi

# 解压并安装 Docker
tar -zxvf "${DOCKER_FILE}" -C /tmp
tar -zxvf "${DOCKER_ROOTLESS_FILE}" -C /tmp
sudo cp /tmp/docker/* /usr/bin/
sudo cp /tmp/docker-rootless-extras/* /usr/bin/

sudo loginctl enable-linger "${CURRENT_USER}"

# log "依赖安装完成。请按以下步骤操作："
# log "1. 退出当前终端"
# log "2. 重新通过 ssh 连接"
# log "3. 在新终端中执行: scripts/install-docker-rootless.sh"
# log "这些步骤将完成 Docker Rootless 的安装"

log "Docker Rootless 依赖安装完成"
