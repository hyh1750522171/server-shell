# 检查文件是否存在
file_not_exists() {
    FILE=$1
    if [ -f "$FILE" ]; then
        return 1  # 文件存在
    else
        return 0  # 文件不存在
    fi
}


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

