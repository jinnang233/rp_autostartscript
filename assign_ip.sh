#!/usr/bin/bash
ip_assigned=0

workdir=$(cd $(dirname $0); pwd)
source $workdir/config

# 循环检测是否有相应网络设备， 如果有便分配IP地址， 执行ddns代码并退出循环。
while [ $ip_assigned -eq 0 ];
	do
	if /sbin/ifconfig |/usr/bin/grep -q $rosenpass_dev; then
		/bin/echo "$rosenpass_dev found!"
		PATH=$PATH:/usr/local/bin/ sudo ip a add $IP4_assigned dev $rosenpass_dev
		PATH=$PATH:/usr/local/bin/ sudo ip a add $IP6_assigned dev $rosenpass_dev
		PATH=$PATH:/usr/local/bin/ $workdir/ddns.sh & 
		ip_assigned=1
		$workdir/nat_forward.sh up
	fi
	sleep 1
done
/bin/echo "An IP address was assigned to $rosenpass_dev!"
