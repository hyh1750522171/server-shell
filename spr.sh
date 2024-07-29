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
    wget https://github.com/itgpt/spectre-spr-information/releases/download/${version}/tnn-miner-linux-${jiagou}.tar.gz
    tar -zxvf tnn-miner-linux-x86.tar.gz
    
}


downloads() {
    # 获取系统架构类型
    ARCH=$(uname -m)

    # 判断系统架构
    if [[ "$ARCH" == "x86_64" ]]; then
        # wget  http://
        echo "系统架构是 x86_64 (64位 x86)."
        download x86
        echo './tnn-miner*  --spectre --daemon-address   --port  5555 --wallet spectre:qxxxxxxxxxg --threads 10 --worker-name 矿工名称' > run.sh 
        chmod +x ./run.sh
        ./run.sh
    # elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    #     # wget  http://
    #     echo "系统架构是 x86 (32位)."
    # elif [[ "$ARCH" == "armv7l" ]]; then
    #     # wget  http://
    #     echo "系统架构是 ARM (32位)."
    elif [[ "$ARCH" == "aarch64" ]]; then
        echo "系统架构是 ARM (64位)."
    else
        echo "暂不支持您的设备和系统......"
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

geo_check() {
    api_list="https://blog.cloudflare.com/cdn-cgi/trace https://dash.cloudflare.com/cdn-cgi/trace https://cf-ns.com/cdn-cgi/trace"
    ua="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"
    set -- $api_list
    for url in $api_list; do
        text="$(curl -A $ua -m 10 -s $url)"
        if echo $text | grep -qw 'CN'; then
            isCN=true
            break
        fi
    done
}
geo_check
echo $isCN

