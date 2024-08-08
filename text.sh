#!/bin/bash

# 从网络获取脚本
source <(curl -s https://gitee.com/muaimingjun/server-shell/raw/main/init.sh)

ip_ch
update
# declare -a packages=("wget" "htop" "neofetch" "vim" "python3" "pip" "unzip" "git" "tree")
# for package in "${packages[@]}"; do
#     check_install_package $package
# done

# # 判断文件init 是否存在
# if [! -f init.sh ]; then
#     # 下载文件
#     echo "正在准备安装Docker..."
#     curl -SLs ${git_url}qubic-docker/raw/main/itgpt-setup.sh | bash
#     echo "Docker已安装完成."
# fi

# update