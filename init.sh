#!/bin/bash

# 判断操作系统是否是Ubuntu或CentOS并安装指定软件包

# 检测操作系统和包管理器
if [ -f /etc/debian_version ]; then
    OS="ubuntu"
    PACKAGE_MANAGER="apt-get"
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    PACKAGE_MANAGER="yum"
else
    echo "不支持的操作系统."
    exit 1
fi

# 更新软件包源
update() {
  echo "正在更新软件包源....."
  sudo $PACKAGE_MANAGER update -y
  echo "软件包源更新成功....."
}

# 检查并安装软件包函数
check_install_package() {
    PACKAGE_NAME=$1
    if ! command -v $PACKAGE_NAME &> /dev/null; then
        read -p "$PACKAGE_NAME 未安装,是否需要安装 $PACKAGE_NAME ？ (yes/no): " answer
        if [[ "$answer" =~ ^[Yy][Ee][Ss]$ ]]; then  
            sudo $PACKAGE_MANAGER install -y $PACKAGE_NAME
        elif [[ "$answer" =~ ^[Nn][Oo]$ ]]; then
            echo "取消安装 $PACKAGE_NAME ...."
        else
            echo "无效的输入，取消安装 $PACKAGE_NAME ...."
        fi
    else
        echo "$PACKAGE_NAME 已安装."
    fi
}

# 检查是否已安装Nvidia驱动
check_install_nvidia_driver() {
    echo "检查是否可以安装Nvidia显卡驱动并安装或跳过..."

    # 检查是否有Nvidia显卡
    if ! lspci | grep -i nvidia &> /dev/null; then
        echo "未检测到Nvidia显卡，无法安装驱动。"
        return
    fi

    # 检查是否已安装Nvidia驱动
    if ! command -v nvidia-smi &> /dev/null; then
        echo "未检测到安装的Nvidia显卡驱动，正在安装..."
        sudo $PACKAGE_MANAGER install -y nvidia-driver
        if [ $? -ne 0 ]; then
            echo "安装Nvidia显卡驱动失败，请检查网络连接或驱动兼容性。"
        else
            echo "Nvidia显卡驱动已安装."
        fi

        # 再次检查是否成功安装Nvidia驱动
        if command -v nvidia-smi &> /dev/null; then
            read -p "Nvidia显卡驱动安装成功.需要重启计算机以保证GPU驱动完全加载 (yes/no): " hehh
            if [[ "$hehh" =~ ^[Yy][Ee][Ss]$ ]]; then
                echo "请重启计算机以保证GPU驱动完全加载."
            else
                echo "请稍后手动重启计算机."
            fi
        else
            echo "安装失败，请重启计算机或检查系统和驱动兼容性。"
        fi
    else
        echo "Nvidia显卡驱动已安装."
    fi
}

# 检查安装Docker
install_docker(){
  PACKAGE_NAME="docker"
  # 询问是否安装docker
  if ! command -v $PACKAGE_NAME &> /dev/null; then

    read -p "是否需要安装Docker和nvidia Docker 服务[容器可以使用显卡]？ (yes/no): " answer
    clear
    if [[ "$answer" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "正在准备安装Docker..."
        curl -SLs https://gitee.com/muaimingjun/qubic-docker/raw/main/itgpt-setup.sh | bash
        echo "Docker已安装完成."
    elif [[ "$answer" =~ ^[Nn][Oo]$ ]]; then
        echo "取消安装Docker."
    else
        echo "无效的输入，取消安装Docker."
    fi
  else
        echo "$PACKAGE_NAME 已安装."
  fi
}

# 更新软件包源
update
# 调用函数检查并安装软件包
check_install_package sudo
check_install_package wget
check_install_package htop
check_install_package neofetch
check_install_package vim
check_install_package python3
check_install_package pip
check_install_package unzip
check_install_package git
check_install_package tree
# 调用函数来执行检查和安装Nvidia显卡驱动
check_install_nvidia_driver
install_docker