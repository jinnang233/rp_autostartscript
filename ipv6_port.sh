#!/usr/bin/bash
ip_assigned=0
workdir=$(cd $(dirname $0); pwd)
source $workdir/config
while [ $ip_assigned -eq 0 ];
	do
	if /sbin/ifconfig |/usr/bin/grep -q "$rosenpass_dev"; then
		/bin/echo "$rosenpass_dev find!"
		PATH=$PATH:/usr/local/bin/ socat UDP4-LISTEN:$listenport,reuseaddr,fork UDP6:127.0.0.1:$listenport 
		ip_assigned=1
	fi
	sleep 1
done
/bin/echo "IPv6 to ipv4 assigned to $rosenpass_dev"


