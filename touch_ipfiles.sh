#!/usr/bin/bash

workdir=$(cd $(dirname $0); pwd)
source $workdir/config
client_pks=$(find $clients_dir -type d -not -iwholename $clients_dir )
for pk in $client_pks
do
	peername=$(echo $pk | awk -F "/" '{print $NF}')
	touch $clientip_dir/$peername
done;
