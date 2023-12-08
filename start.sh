#!/usr/bin/bash

workdir=$(cd $(dirname $0); pwd)
source $workdir/config
custom_fd=$clients_dir
ip_fd=$clientip_dir
server_fd=$server_dir
echo -e "
Working directory: $workdir \n
Clients directory: $custom_fd \n 
Clients Allowed-ips directory: $ip_fd \n
Server secret key directory: $server_dir \n
"	


## Here is script
declare -i listenport_wg
let listenport_wg=$listenport+1
eval "echo Listen: $listenip:$listenport_wg"
echo "[Detail]"

client_pks=$(/usr/bin/find $custom_fd -type d -not -iwholename $custom_fd)
peers=""
set -e
ip link add dev $rosenpass_dev type wireguard || true 
ip link set dev $rosenpass_dev up 
wg set $rosenpass_dev private-key $server_fd/wgsk listen-port $listenport_wg
cmd="
rosenpass exchange 
	secret-key $server_fd/pqsk 
	public-key $server_fd/pqpk
	listen $listenip:$listenport 
"
for pk in $client_pks
do
	peername=$(echo $pk |awk -F "/" '{print $NF}')
	ip=$(cat $ip_fd/$peername)
	echo -e "\t$peername:  $ip"
	peers="
	$peers peer public-key $pk/pqpk 
		wireguard $rosenpass_dev $(cat $pk/wgpk) allowed-ips $ip "
	
done;
cmd="$cmd$peers"
echo $cmd
eval $cmd
