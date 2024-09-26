#!/bin/bash

# 离线下载 ansible pip 包

set -euo pipefail

LOG_FILE="/tmp/download-ansible.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始下载 ansible pip 包"

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

mkdir -p pip

${PYTHON_BIN} -m pip download -d pip ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT_VERSION} passlib==${PASSLIB_VERSION} docker==${DOCKER_VERSION}

tar -zcvf pip.tar.gz pip
mv pip.tar.gz /home/berny/ansible/files

log "下载完成。请按照以下步骤进行离线安装："

cat <<EOF | tee -a "$LOG_FILE"
1. 将下载的 pip 目录复制到目标机器。
2. 在目标机器上，使用以下命令安装 ansible 及其依赖包：
   ${PYTHON_BIN} -m pip install --no-index --find-links=pip ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT_VERSION} passlib==${PASSLIB_VERSION}
EOF
