#!/usr/bin/bash

workdir=$(cd $(dirname $0); pwd)
source $workdir/config
mkdir -p $clientip_dir
mkdir -p $clients_dir
rp genkey $server_dir
rp pubkey $server_dir $server_pub_dir
