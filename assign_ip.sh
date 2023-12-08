#!/usr/bin/bash
ip_assigned=0

workdir=$(cd $(dirname $0); pwd)
source $workdir/config

while [ $ip_assigned -eq 0 ];
	do
	if /sbin/ifconfig |/usr/bin/grep -q $rosenpass_dev; then
		/bin/echo "$rosenpass_dev find!"
		PATH=$PATH:/usr/local/bin/ sudo ifconfig $rosenpass_dev $IP4_assigned
		PATH=$PATH:/usr/local/bin/ sudo ip a add $IP6_assigned dev $rosenpass_dev
		PATH=$PATH:/usr/local/bin/ $workdir/ddns.sh & 
		ip_assigned=1
		$workdir/nat_forward.sh up
	fi
	sleep 1
done
/bin/echo "IP assigned to $rosenpass_dev!"
