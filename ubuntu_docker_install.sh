#!/bin/bash
#Ubuntu14.04 安装docker

#1.删除旧版本
sudo apt-get remove docker docker-engine docker.io

#2.更新软件，添加Ubuntu可选内核模块，以支持AUFS(部分内核模块可能被移动到可选模块以减小安装包大小)
sudo apt-get update
#14.04及以下版本
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual

#3.由于apt源使用的事https传输以确保下载过程不会被篡改，因此需要安装https传输的软件包和CA证书
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common


#4.为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

#阿里源 参考:http://mirrors.aliyun.com/
#curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
#官方源 
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#然后向 source.list 中添加 Docker 软件源
sudo add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

#官方源:
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#阿里源
# sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/linux/ubuntu $(lsb_release -cs) stable"

#5.安装docker-ce软件包
sudo apt-get update
sudo apt-get install docker-ce

#6.默认情况下， docker 命令会使用 Unix socket 与 Docker 引擎通讯。而只有 root 用户和docker 组的用户才可以访问 
#Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统上不会直接使用 root 用户。因此，更好地做法是将需要使
#用 docker 的用户加入 docker用户组
sudo groupadd docker
sudo usermod -aG docker $USER

#7.配置镜像加速器
#ubuntu 16.04以上的版本
#vi /etc/docker/daemon.json
#添加以下内容
#{
#	"registry-mirrors": [
#		"https://registry.docker-cn.com"
#	]
#}

#ubuntu 14.04版本
#vi /etc/default/docker
#添加以下内容
#DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com"
#重启docker
#sudo service docker restart

#8.开启开机启动(新版本)
#sudo systemctl enable docker
#sudo systemctl start docker
#ubuntu 14.04
sudo service docker start


