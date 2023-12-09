#!/usr/bin/bash

workdir=$(cd $(dirname $0); pwd)
source $workdir/config

$workdir/nat_forward.sh down

# 杀死Rosenpass进程并删除设备
killall "rosenpass"
ip link del dev $rosenpass_dev type wireguard ||true
ip link set dev $rosenpass_dev down

