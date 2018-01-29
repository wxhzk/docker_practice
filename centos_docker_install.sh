#!/bin/bash
#Centos7 安装docker

#1.删除旧版本
sudo yum remove docker docker-common docker-selinux docker-engine

#2.安装依赖包
sudo yum install -y yum-utils device-mapper-persistent-data lvm

#3.替换国内源
sudo yum-config-manager --add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
#阿里源
#sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#官方源
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#4.安装docker-ce软件包
sudo yum makecache fast
sudo yum install docker-ce

#5.开启开机启动(新版本)
sudo systemctl enable docker
sudo systemctl start docker

#6.默认情况下， docker 命令会使用 Unix socket 与 Docker 引擎通讯。而只有 root 用户和docker 组的用户才可以访问 
#Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统上不会直接使用 root 用户。因此，更好地做法是将需要使
#用 docker 的用户加入 docker用户组
sudo groupadd docker
sudo usermod -aG docker $USER

#默认配置下，如果在 CentOS 使用 Docker CE 看到下面的这些警告信息：
#	WARNING: bridge-nf-call-iptables is disabled
#	WARNING: bridge-nf-call-ip6tables is disabled
#请添加内核配置参数以启用这些功能。
#$ sudo tee -a /etc/sysctl.conf <<-EOF
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#net.ipv4.ip_forward = 1
#EOF
#然后重新加载 sysctl.conf 即可
#$ sudo sysctl -p

#7.配置镜像加速器
#vi /etc/docker/daemon.json
#添加以下内容
#{
#	"registry-mirrors": [
#		"https://registry.docker-cn.com"
#	]
#}
#重启服务
#sudo systemctl daemon-reload
#sudo systemctl restart docker