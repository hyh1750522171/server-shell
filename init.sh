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
update(){
  echo "正在更新软件包源....."
  sudo $PACKAGE_MANAGER update -y &> /dev/null
  echo "软件包源更新成功....."

}
# 检查并安装软件包函数
check_install_package() {
    PACKAGE_NAME=$1
    if ! command -v $PACKAGE_NAME &> /dev/null; then

        read -p "$PACKAGE_NAME 未安装,是否需要安装 $PACKAGE_NAME ？ (yes/no): " answer

        if [[ "$answer" =~ ^[Yy][Ee][Ss]$ ]]; then  

          if [ "$OS" = "ubuntu" ]; then
              sudo $PACKAGE_MANAGER install -y $PACKAGE_NAME
          elif [ "$OS" = "centos" ]; then
              sudo $PACKAGE_MANAGER install -y $PACKAGE_NAME
          fi
        elif [[ "$answer" =~ ^[Nn][Oo]$ ]]; then
          echo "取消安装 $PACKAGE_NAME ...."
          sleep 2
        else
            echo "无效的输入，取消安装 $PACKAGE_NAME ...."
            sleep 2
        fi
        
    else
        echo "$PACKAGE_NAME 已安装."
        sleep 2
    fi
}
# 检查是否已安装Nvidia驱动
check_install_nvidia_driver() {
    echo "检查是否可以安装Nvidia显卡驱动并安装或跳过..."
    sleep 2

    # 检查是否有Nvidia显卡
    if ! lspci | grep -i nvidia &> /dev/null; then
        echo "未检测到Nvidia显卡，无法安装驱动."
        sleep 2
        return
    fi

    # 检查是否已安装Nvidia驱动
    if ! command -v nvidia-smi &> /dev/null; then
        echo "未检测到安装的Nvidia显卡驱动，正在安装..."
        sleep 2
        if [ "$OS" = "ubuntu" ]; then
            sudo sudo $PACKAGE_MANAGER install -y nvidia-driver-545
        elif [ "$OS" = "centos" ]; then
            sudo yum install -y nvidia-driver-545
        fi
    else
        echo "Nvidia显卡驱动已安装."
        sleep 2
    fi

    # 再次检查是否成功安装Nvidia驱动
    if command -v nvidia-smi &> /dev/null; then
        echo "Nvidia显卡驱动安装成功."
        sleep 2
        echo "可以使用 'nvidia-smi' 命令检查驱动信息和显卡状态."
    else
        clear
        echo -e "安装失败，\033[0;31m先要重启计算机\033[0m,  再或者请检查系统和驱动兼容性。"
        sleep 5
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
        sleep 2
        curl -SLs https://gitee.com/muaimingjun/qubic-docker/raw/main/itgpt-setup.sh | bash
        echo "Docker已安装完成."
        sleep 2
    elif [[ "$answer" =~ ^[Nn][Oo]$ ]]; then
        echo "取消安装Docker."
        sleep 2
    else
        echo "无效的输入，取消安装Docker."
        sleep 2
    fi
  else
        echo "$PACKAGE_NAME 已安装."
        sleep 2
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
check_install_package git
check_install_package tree
# 调用函数来执行检查和安装Nvidia显卡驱动
check_install_nvidia_driver
install_docker

