#!/bin/bash

# 从网络获取脚本
source <(curl -s https://gitee.com/muaimingjun/server-shell/raw/main/package/init.sh)
# 安装1panel
if [ -f "/usr/local/bin/1panel" ]; then
    echo "检测到已经安装了 1panel 面板, 无需安装面板"   
else
    # 在此处添加存在时要执行的命令
    echo "检测到没有安装 1panel 面板，建议您先安装 1panel 面板"
    # 提示用户是否安装
    read -p "是否安装 1panel 面板？ (yes/no): " shuru
    if [[ "$shuru" =~ ^[Yy][Ee][Ss]$ ]]; then
        # 下载安装脚本
        install_1panel
        echo "1panel 面板已安装完成."
    else
        echo "取消安装 1panel 面板."
    fi
fi
