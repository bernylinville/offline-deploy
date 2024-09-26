#!/bin/bash

set -exo pipefail

DIR="rpms"

# Install dependencies
sudo dnf install -y dnf-utils dnf-plugins-core createrepo

# sudo yum-config-manager --add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
# sudo sed -i 's#download.docker.com#mirrors.ustc.edu.cn/docker-ce#g' /etc/yum.repos.d/docker-ce.repo
# sudo sed -i 's#$releasever#8#g' /etc/yum.repos.d/docker-ce.repo
# sudo yum makecache

# Download the source RPMs
[ -d "$DIR" ] || mkdir -p "$DIR"

# 检查packages.txt中的包是否存在
readarray -t packages < <(grep -v "^#" scripts/packages.txt | sort | uniq)
if ! dnf list --available "${packages[@]}" &> /dev/null; then
    echo "警告: 一些包不存在或无法访问"
    dnf list --available "${packages[@]}" 2>&1 | grep "No matching packages"
fi

# 下载包
grep -v "^#" scripts/packages.txt | sort | uniq | xargs dnf download --resolve --alldeps --disablerepo="offline" --downloaddir "${DIR}"

# Create the repository
createrepo -d $DIR
