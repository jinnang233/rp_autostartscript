#!/usr/bin/bash

# 获取工作目录并配置设置环境变量
workdir=$(cd $(dirname $0); pwd)
source $workdir/config
custom_fd=$clients_dir
ip_fd=$clientip_dir
server_fd=$server_dir

# 显示设置参数
echo -e "
Working directory: $workdir \n
Clients directory: $custom_fd \n 
Clients Allowed-ips directory: $ip_fd \n
Server secret key directory: $server_dir \n
"	

# 显示监听地址
eval "echo Listen: $listenip:$listenport_wg"
echo "[Detail]"
# 获取客户端公钥所有的目录的路径排除所有以disabled结尾的目录
client_pks=$(/usr/bin/find $custom_fd -type d -not -iwholename $custom_fd -not -iregex ".*\.disabled")
peers=""
set -e

# 增加rosenpass设备并开启网络设备
ip link add dev $rosenpass_dev type wireguard || true 
ip link set dev $rosenpass_dev up

# 使用wg工具设置rosenpass设备
wg set $rosenpass_dev private-key $server_fd/wgsk listen-port $listenport_wg

# 初始化cmd变量
cmd="
rosenpass exchange 
	secret-key $server_fd/pqsk 
	public-key $server_fd/pqpk
	listen $listenip:$listenport 
"

# 遍历所有peer并获取名称，在ip_fd相应目录寻找Allowed-Ips并配置
for pk in $client_pks
do
	peername=$(echo $pk |awk -F "/" '{print $NF}')
	ip=$(cat $ip_fd/$peername)
	echo -e "\t$peername:  $ip"
	peers="
	$peers peer public-key $pk/pqpk 
		wireguard $rosenpass_dev $(cat $pk/wgpk) allowed-ips $ip "
	
done;

# 显示并执行命令
cmd="$cmd$peers"
echo $cmd
eval $cmd
