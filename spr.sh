# 检查文件是否存在
file_not_exists() {
    FILE=$1
    if [ -f "$FILE" ]; then
        return 1  # 文件存在
    else
        return 0  # 文件不存在
    fi
}

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


download() {
    jiagou=$1
    version=v0.3.6
    file_name=tnn-miner-linux-${jiagou}.tar.gz
    wget ${git_url}spectre-spr-information/releases/download/${version}/${file_name}
    tar -zxvf $file_name
    
}


downloads() {
    # 获取系统架构类型
    ARCH=$(uname -m)

    # 判断系统架构
    if [[ "$ARCH" == "x86_64" ]]; then
        # wget  http://
        echo "系统架构是 x86_64 (64位 x86)."
        return "x86_64"
    # elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    #     # wget  http://
    #     echo "系统架构是 x86 (32位)."
    # elif [[ "$ARCH" == "armv7l" ]]; then
    #     # wget  http://
    #     echo "系统架构是 ARM (32位)."
    elif [[ "$ARCH" == "aarch64" ]]; then
        echo "系统架构是 ARM (64位)."
        return "aarch64"
    else
        echo "暂不支持您的设备和系统......"
        exit 1
    fi
  }

spr() {
    # 测试文件是否存在
    if file_not_exists Tnn*; then
        # download
        echo 'hello'
    fi
}

# spr

