#!/usr/bin/bash

workdir=$(cd $(dirname $0); pwd)
source $workdir/config
# 创建客户端公钥ip对应文件并排除以.disabled结尾的文件夹。
client_pks=$(find $clients_dir -type d -not -iwholename $clients_dir -not -iregex ".*\.disabled")
for pk in $client_pks
do
	peername=$(echo $pk | awk -F "/" '{print $NF}')
	touch $clientip_dir/$peername
done;
