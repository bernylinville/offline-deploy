#!/bin/bash
set -exo pipefail

FILES_DIR=files
DOCKER_VERSION=${DOCKER_VERSION:-27.2.0}
DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-2.29.2}
MYSQL_VERSION=${MYSQL_VERSION:-8.0.39}
MYSQL_SHELL_VERSION=${MYSQL_SHELL_VERSION:-8.0.38}
GLIBC_VERSION=${GLIBC_VERSION:-2.28}
PYTHON_VERSION=${PYTHON_VERSION:-3.12.5}
DOCKER_MIRROR="https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/x86_64"
MYSQL_MIRROR="https://dev.mysql.com/get/Downloads"
HARBOR_VERSION=${HARBOR_VERSION:-2.11.1}
GHPROXY_MIRROR="https://mirror.ghproxy.com"

echo "正在检查并下载文件..."

# 下载 Docker 文件
DOCKER_FILE="${FILES_DIR}/docker-${DOCKER_VERSION}.tgz"
if [ ! -f "$DOCKER_FILE" ]; then
    echo "正在下载 Docker 文件..."
    wget ${DOCKER_MIRROR}/docker-${DOCKER_VERSION}.tgz -O "$DOCKER_FILE"
else
    echo "Docker 文件已存在，跳过下载。"
fi

# 下载 Docker Compose 文件
DOCKER_COMPOSE_FILE="${FILES_DIR}/docker-compose-linux-x86_64"
INSTALLED_VERSION=$(${FILES_DIR}/docker-compose-linux-x86_64 version --short 2>/dev/null || echo "未安装")
if [ "$INSTALLED_VERSION" != "$DOCKER_COMPOSE_VERSION" ]; then
    echo "正在下载 Docker Compose 文件..."
    wget ${GHPROXY_MIRROR}/https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -O "$DOCKER_COMPOSE_FILE"
else
    echo "已安装最新版本的 Docker Compose (${DOCKER_COMPOSE_VERSION})，跳过下载。"
fi

DOCKER_ROOTLESS_FILE="${FILES_DIR}/docker-rootless-extras-${DOCKER_VERSION}.tgz"
if [ ! -f "$DOCKER_ROOTLESS_FILE" ]; then
    echo "正在下载 Docker Rootless 文件..."
    wget ${DOCKER_MIRROR}/docker-rootless-extras-${DOCKER_VERSION}.tgz -O "$DOCKER_ROOTLESS_FILE"
else
    echo "Docker Rootless 文件已存在，跳过下载。"
fi

# 下载 MySQL 文件
MYSQL_FILE="${FILES_DIR}/mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-x86_64.tar.xz"
if [ ! -f "$MYSQL_FILE" ]; then
    echo "正在下载 MySQL 文件..."
    wget ${MYSQL_MIRROR}/MySQL-8.0/mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-x86_64.tar.xz -O "$MYSQL_FILE"
else
    echo "MySQL 文件已存在，跳过下载。"
fi

# 下载 MySQL Router 文件
MYSQL_ROUTER_FILE="${FILES_DIR}/mysql-router-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-x86_64.tar.xz"
if [ ! -f "$MYSQL_ROUTER_FILE" ]; then
    echo "正在下载 MySQL Router 文件..."
    wget ${MYSQL_MIRROR}/MySQL-Router/mysql-router-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-x86_64.tar.xz -O "$MYSQL_ROUTER_FILE"
else
    echo "MySQL Router 文件已存在，跳过下载。"
fi

# 下载 MySQL Shell 文件
MYSQL_SHELL_FILE="${FILES_DIR}/mysql-shell-${MYSQL_SHELL_VERSION}-linux-glibc${GLIBC_VERSION}-x86-64bit.tar.gz"
if [ ! -f "$MYSQL_SHELL_FILE" ]; then
    echo "正在下载 MySQL Shell 文件..."
    wget ${MYSQL_MIRROR}/MySQL-Shell/mysql-shell-${MYSQL_SHELL_VERSION}-linux-glibc${GLIBC_VERSION}-x86-64bit.tar.gz -O "$MYSQL_SHELL_FILE"
else
    echo "MySQL Shell 文件已存在，跳过下载。"
fi

# 下载 Python 文件
PYTHON_FILE="${FILES_DIR}/Python-${PYTHON_VERSION}.tgz"
if [ ! -f "$PYTHON_FILE" ]; then
    echo "正在下载 Python 文件..."
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -O "$PYTHON_FILE"
else
    echo "Python 文件已存在，跳过下载。"
fi


# 下载 Harbor 文件
# https://github.com/goharbor/harbor/releases/download/v2.11.1/harbor-offline-installer-v2.11.1.tgz
HARBOR_FILE="${FILES_DIR}/harbor-offline-installer-v${HARBOR_VERSION}.tgz"
if [ ! -f "$HARBOR_FILE" ]; then
    echo "正在下载 Harbor 文件..."
    wget ${GHPROXY_MIRROR}/https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz -O "$HARBOR_FILE"
else
    echo "Harbor 文件已存在，跳过下载。"
fi



echo "所有文件检查和下载完成！"
