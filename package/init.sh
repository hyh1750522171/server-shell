#!/bin/bash


PLAIN='\033[0m'
ERROR="[\033[1;31m错误${PLAIN}]"
## 报错退出
function output_error() {
    [ "$1" ] && echo -e "\n$ERROR $1\n"
    exit 1
}

## 权限判定
function permission_judgment() {
    if [ $UID -ne 0 ]; then
        output_error "权限不足，请使用 Root 用户运行本脚本"
    fi
}
permission_judgment

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
  echo "<=====================================================================================================>"
  echo "                                               update 更新镜像源                                        "
  echo "<=====================================================================================================>"
  sudo apt > /dev/null
  echo "正在更新系统软件包源,  请稍后...."
  sudo $PACKAGE_MANAGER update -y > /dev/null
  echo "系统软件包源更新成功....."
}

# 安装1panel
install_1panel() {
    echo "正在安装 1panel ...."
    # 此处添加 apt-get 相关的命令
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh | bash
    rm -fr 1panel-v1.10.13-lts-linux-amd64.tar.gz 1panel-v1.10.13-lts-linux-amd64

}

# 检查并安装软件包函数
check_install_package() {
    PACKAGE_NAME=$1
    echo "<=====================================================================================================>"
    echo "                                               $PACKAGE_NAME 安装详情                                   "
    echo "<=====================================================================================================>"
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
    echo "<=====================================================================================================>"
    echo "                                             Nvidia显卡驱动 安装详情                                   "
    echo "<=====================================================================================================>"
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
  echo "<=====================================================================================================>"
  echo "                                               $PACKAGE_NAME 安装详情                                   "
  echo "<=====================================================================================================>"
  # 询问是否安装docker
  if ! command -v $PACKAGE_NAME &> /dev/null; then

    read -p "是否需要安装Docker和nvidia Docker 服务[容器可以使用显卡]？ (yes/no): " answer
    clear
    if [[ "$answer" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "正在准备安装Docker..."
        curl -SLs ${git_url}qubic-docker/raw/main/itgpt-setup.sh | bash
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


# 检查文件是否存在
file_not_exists() {
    FILE=$1
    if [ -f "$FILE" ]; then
        return 1  # 文件存在
    else
        return 0  # 文件不存在
    fi
}

# # 如果不存在就输出hello
# if file_not_exists init.sh; then
#         # download
#         echo 'hello'
# fi
main() {
    # # 更新软件包源
    update
    # # 调用函数检查并安装软件包
    declare -a packages=("wget" "htop" "neofetch" "vim" "python3" "pip" "unzip" "git" "tree")
    for package in "${packages[@]}"; do
        check_install_package $package
    done
    # # 调用函数来执行检查和安装Nvidia显卡驱动
    check_install_nvidia_driver
    install_docker
    # clear
    echo "====================================================================================================="
    echo "                                               设备详情                                              "
    echo "====================================================================================================="
    neofetch
}

ip_ch(){
  # 从API获取JSON数据
  api_url="https://ip.useragentinfo.com/json"  # 替换为实际的API URL
  json_data=$(curl -s $api_url)

  # 使用 grep 和 sed 提取 short_name 值
  short_name=$(echo $json_data | grep -o '"short_name": *"[^"]*"' | sed 's/.*"short_name": *"\([^"]*\)".*/\1/')

  # echo $country
  # 检查IP地址是否来自中国大陆
  if [ "$short_name" == "CN" ]; then
      # echo "The IP address $ip_address is from China."
      echo 中国大陆地区
      git_url="https://gitee.com/muaimingjun/"

  else
      # echo "The IP address $ip_address is not from China."
      echo 非中国大陆地区
      git_url="https://github.com/itgpt/"
  fi
}

# 判断你是否是当前文件，如果不是则不执行main函数
if [[ "${BASH_SOURCE[0]}" == "${0}" && -z "${NO_EXEC_MAIN}" ]]; then
    main
fi

