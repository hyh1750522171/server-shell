#!/bin/bash

cd /tmp

# Set Gloabal Variables
    # Detect OS
        OS="$(uname)"
        case $OS in
            "Linux")
                # Detect Linux Distro
                if [ -f /etc/os-release ]; then
                    . /etc/os-release
                    DISTRO=$ID
                    VERSION=$VERSION_ID
                else
                    echo "Your Linux distribution is not supported."
                    exit 1
                fi
                ;;
        esac
echo $DISTRO

echo $(uname -m)
# 判断操作系统是 Ubuntu (x64) 并且是 22.04 24.04 版本
if [ "$DISTRO" = "ubuntu" ] && [ "$(uname -m)" = "x86_64" ] && ([ "$VERSION" = "22.04" ] || [ "$VERSION" = "24.04" ]); then
    # 判断 /etc/gdm3/custom.conf 文件是否存在
    if [ -f /etc/gdm3/custom.conf ]; then
        echo "/etc/gdm3/custom.conf 文件存在。正在替换 #WaylandEnable=fals 为 WaylandEnable=false。"
        # 使用 sed 命令将 #WaylandEnable=false 替换成 WaylandEnable=false
        sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf
    else
        echo "/etc/gdm3/custom.conf 文件不存在。不替换"
        exit 1
    fi
else
    # 输出错误信息
    if [ "$DISTRO" = "ubuntu" ] && [ "$(uname -m)" = "x86_64" ] && ([ "$VERSION" = "18.04" ] || [ "$VERSION" = "20.04" ]); then
        echo "The system is Ubuntu 22.04 or 24.04 (x86_64)."
    else
        exit 1
    fi
fi

wget https://dl.todesk.com/linux/todesk-v4.7.2.0-amd64.deb 

sudo apt install -y  ./todesk-v4.7.2.0-amd64.deb

sudo rm -fr /tmp/*

sudo reboot


