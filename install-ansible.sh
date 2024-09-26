#!/bin/bash

# 离线下载 ansible pip 包

set -euo pipefail

LOG_FILE="/tmp/install-ansible.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始安装 ansible"

ANSIBLE_VERSION=${ANSIBLE_VERSION:-10.3.0}
ANSIBLE_LINT_VERSION=${ANSIBLE_LINT_VERSION:-24.7.0}
PASSLIB_VERSION=${PASSLIB_VERSION:-1.7.4}
PYTHON_BIN=${PYTHON_BIN:-/usr/local/bin/python3.12}
DOCKER_VERSION=${DOCKER_VERSION:-7.1.0}

# 检查系统版本
if ! grep -q 'openEuler 22.03' /etc/os-release; then
    log "错误：此脚本仅支持 openEuler 22.03"
    exit 1
fi

$PYTHON_BIN -m pip install --no-index --find-links=pip ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT_VERSION} passlib==${PASSLIB_VERSION} docker==${DOCKER_VERSION}
sudo dnf -y install sshpass

if [[ ":$PATH:" != *":/home/berny/.local/bin:"* ]]; then
    echo 'export PATH=$PATH:/home/berny/.local/bin' >> /home/berny/.bashrc
    source /home/berny/.bashrc
    log "已将 /home/berny/.local/bin 添加到 PATH 并更新 .bashrc"
else
    log "/home/berny/.local/bin 已存在于 PATH 中"
fi

log "安装完成。"
