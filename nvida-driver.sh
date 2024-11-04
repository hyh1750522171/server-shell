#!/bin/bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
sudo dpkg --set-selections <<< "cloud-init install" || true

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

# Detect if an Nvidia GPU is present
NVIDIA_PRESENT=$(lspci | grep -i nvidia || true)

# Only proceed with Nvidia-specific steps if an Nvidia device is detected
if [[ -z "$NVIDIA_PRESENT" ]]; then
    echo "在此系统上未检测到 NVIDIA 设备。"
else
# Check if nvidia-smi is available and working
    if command -v nvidia-smi &>/dev/null; then
        echo "CUDA 驱动程序已安装，因为 nvidia-smi 可以运行。"
    else

                # Depending on Distro
                sudo apt update -y
                case $DISTRO in
                    "ubuntu")
                        case $VERSION in
                            "24.04")
                                # Commands specific to Ubuntu 22.04
                                sudo apt install -y nvidia-driver-535
                                ;;

                            "22.04")
                                # Commands specific to Ubuntu 22.04
                                sudo apt install -y nvidia-driver-535
                                ;;

                            "20.04")
                                
                                sudo apt install -y nvidia-driver-535
                                ;;

                            "18.04")
                                # Commands specific to Ubuntu 18.04
                                sudo apt install -y nvidia-driver-515
                                ;;

                            *)
                                echo "此脚本不支持这个版本的 Ubuntu 。"
                                exit 1
                                ;;
                        esac
                        ;;

                    "debian")
                        case $VERSION in
                            "10"|"11")
                                # Commands specific to Debian 10 & 11
                                sudo -- sh -c 'apt update; apt upgrade -y; apt autoremove -y; apt autoclean -y'
                                sudo apt install linux-headers-$(uname -r) -y
                                sudo apt update -y
                                sudo apt install nvidia-driver firmware-misc-nonfree
                                wget https://nvidia-developer.geekery.cn/compute/cuda/repos/debian${VERSION}/x86_64/cuda-keyring_1.1-1_all.deb
                                sudo sed -i 's@//developer.download.nvidia.com@//nvidia-developer.geekery.cn@g' /etc/apt/sources.list.d/cuda-wsl-ubuntu-x86_64.list
                                sudo apt install nvidia-cuda-dev nvidia-cuda-toolkit
                                sudo apt update -y
                                ;;

                            *)
                                echo "此脚本不支持这个版本的 Debian 。"
                                exit 1
                                ;;
                        esac
                        ;;

                    *)
                        echo "您的 Linux 发行版不受支持。"
                        exit 1
                        ;;

            "Windows_NT")
                # For Windows Subsystem for Linux (WSL) with Ubuntu
                if grep -q Microsoft /proc/version; then
                    wget https://nvidia-developer.geekery.cn/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
                    sudo dpkg -i cuda-keyring_1.1-1_all.deb
                    sudo sed -i 's@//developer.download.nvidia.com@//nvidia-developer.geekery.cn@g' /etc/apt/sources.list.d/cuda-wsl-ubuntu-x86_64.list
                    sudo apt-get update
                    sudo apt-get -y install cuda
                else
                    echo "This bash script can't be executed on Windows directly unless using WSL with Ubuntu. For other scenarios, consider using a PowerShell script or manual installation."
                    exit 1
                fi
                ;;

            *)
                echo "您的操作系统不受支持。"
                exit 1
                ;;
        esac
	echo "系统现在将重新启动！！！重启后请重新运行此脚本以完成安装！"
 	sleep 5s
        sudo reboot
    fi
fi
# For testing purposes, this should output NVIDIA's driver version
if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    nvidia-smi
fi

# Check if Docker is installed
if command -v docker &>/dev/null; then
    echo "Docker 已经安装了....."
else
    echo "Docker 没有被安装， 正在安装中....."
    # Install Docker-ce keyring
    sudo apt update -y
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    FILE=/etc/apt/keyrings/docker.gpg
    if [ -f "$FILE" ]; then
        sudo rm "$FILE"
    fi
    curl -fsSL https://download-docker.geekery.cn/linux/ubuntu/gpg | sudo gpg --dearmor -o "$FILE"
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add Docker-ce repository to Apt sources and install
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download-docker.geekery.cn/linux/ubuntu \
      $(. /etc/os-release; echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt -y install docker-ce
fi

# Check if docker-compose is installed
if command -v docker-compose &>/dev/null; then
    echo "Docker-compose 已经安装了..."
else
    echo "Docker-compose 没有被安装， 正在安装中....."

    # Install docker-compose subcommand
    sudo apt -y install docker-compose-plugin
    sudo ln -sv /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
    docker-compose --version
fi

# Test / Install nvidia-docker
if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    if sudo docker run --gpus all nvidia/cuda:11.0.3-base-ubuntu18.04 nvidia-smi &>/dev/null; then
        echo "nvidia-docker is enabled and working. Exiting script."
    else
        echo "nvidia-docker does not seem to be enabled. Proceeding with installations..."
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
        # nvidia.github.io <- nvidia-docker.geekery.cn
        curl -s -L https://nvidia-docker.geekery.cn/nvidia-docker/gpgkey | sudo apt-key add
        curl -s -L https://nvidia-docker.geekery.cn/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
        sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
        sudo systemctl restart docker 
        sudo docker run --gpus all nvidia/cuda:11.0.3-base-ubuntu18.04 nvidia-smi
    fi
fi
# sudo apt-mark hold nvidia* libnvidia*
# Add docker group and user to group docker
sudo groupadd docker || true
sudo usermod -aG docker $USER || true
newgrp docker || true
# Workaround for NVIDIA Docker Issue
echo "按照要求为 NVIDIA Docker 问题应用解决方法 https://github.com/NVIDIA/nvidia-docker/issues/1730"
# Summary of issue and workaround:
# The issue arises when the host performs daemon-reload, which may cause containers using systemd to lose access to NVIDIA GPUs.
# To check if affected, run `sudo systemctl daemon-reload` on the host, then check GPU access in the container with `nvidia-smi`.
# If affected, proceed with the workaround below.

# Workaround Steps:
# Disable cgroups for Docker containers to prevent the issue.
# Edit the Docker daemon configuration.
sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
	"registry-mirrors": [
		"https://hub.geekery.cn",
		"https://ghcr.geekery.cn"
	],
   "runtimes": {
       "nvidia": {
           "path": "nvidia-container-runtime",
           "runtimeArgs": []
       }
   },
   "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
EOF'

# Restart Docker to apply changes.
sudo systemctl restart docker
echo "已应用解决方法。已将 Docker 配置为使用 “cgroupfs” 作为 cgroup 驱动程序"
