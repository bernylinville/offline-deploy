#!/bin/bash

set -euo pipefail

LOG_FILE="/tmp/install-python.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始安装 Python"

ANSIBLE_DIR=${ANSIBLE_DIR:-/home/berny/ansible}
PYTHON_VERSION=${PYTHON_VERSION:-3.12.5}

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

# 解压 Python
tar -zxvf "${ANSIBLE_DIR}/files/Python-${PYTHON_VERSION}.tgz" -C /tmp

# 安装 Python 编译依赖
sudo dnf makecache
sudo dnf install -y gcc openssl-devel bzip2-devel libffi-devel readline-devel sqlite-devel tk-devel libxml2-devel libxslt-devel zlib-devel make

# 安装 Python
cd /tmp/Python-${PYTHON_VERSION}
./configure --enable-optimizations
make -j"$(nproc)"
sudo make altinstall
