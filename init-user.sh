#!/bin/bash

set -euo pipefail
set -o noclobber

LOG_FILE="/tmp/init-user.log"
USERNAME="berny"
PASSWORD="password"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 在脚本开头添加
if [ "$(id -u)" -ne 0 ]; then
    log "错误：此脚本必须以 root 用户运行"
    exit 1
fi

# 在脚本开头添加
if ! grep -q 'openEuler 22.03' /etc/os-release; then
    log "错误：此脚本仅支持 openEuler 22.03"
    exit 1
fi

# 在脚本开头添加
trap 'log "错误：命令 \"$BASH_COMMAND\" 在第 $LINENO 行失败，退出状态 $?"' ERR



# 创建用户
log "开始创建 $USERNAME 用户"
sudo useradd -m -u 1088 -G wheel $USERNAME || log "警告：用户 $USERNAME 可能已存在"

# 设置密码
log "设置 $USERNAME 用户密码"
printf '%s:%s\n' "$USERNAME" "$PASSWORD" | sudo chpasswd

# 验证用户创建是否成功
if id "$USERNAME" &>/dev/null; then
    log "用户 $USERNAME 创建成功"
else
    log "错误：用户 $USERNAME 创建失败"
    exit 1
fi

# 解压ansible.tar.gz文件
log "开始解压ansible.tar.gz文件"
if [ -f /tmp/ansible.tar.gz ]; then
    if tar -xzf /tmp/ansible.tar.gz -C /home/$USERNAME; then
        log "ansible.tar.gz文件解压成功"
        # 设置正确的所有权和权限
        chown -R $USERNAME:$USERNAME /home/$USERNAME/ansible
    else
        log "错误: ansible.tar.gz文件解压失败"
        exit 1
    fi
else
    log "错误：/tmp/ansible.tar.gz文件不存在"
    exit 1
fi
