#!/usr/bin/bash
#echo $0 $1

# 获取IP地址的函数和获取IPV4子网长度的函数
get_ip4(){
        echo `ip -4 addr show $1 |grep "inet" |awk '{print $2}' |awk -F "/" '{print $1}'`
}

get_ip4_netmask_length() {
        echo `ip -4 addr show $1 |grep "inet" |awk '{print $2}' |awk -F "/" '{print $2}'`
}

# 获取配置参数
workdir=$(cd $(dirname $0); pwd)

source $workdir/config

# 配置变量
nat_dev=$rosenpass_dev
fwd_dev=$netif_dev

# 显示配置变量
echo -e "[$0 Current config]:\n\tNAT device: $nat_dev\n\tForward to:$fwd_dev\n\tNAT rosenpass: $nat_rosenpass\n\tNAT_$fwd_dev:$nat_out\n\tClient_dir:$clients_dir\n[$0 End of list] "

dhcp_snoop=0
# 根据配置开启NAT, 配置ufw和iptables规则
up(){
	# NAT up 
	if [ $nat_out -eq 0 ]; then
		echo "[$nat_dev]NAT was disabled on $fwd_dev"
	else
		echo "[$nat_dev]NAT has up"
		/usr/sbin/ufw route allow in on $nat_dev out on $fwd_dev
		/usr/sbin/iptables -t nat -I POSTROUTING -o $fwd_dev -j MASQUERADE
		/usr/sbin/ip6tables -t nat -I POSTROUTING -o $fwd_dev -j MASQUERADE
	fi

	if [ $nat_rosenpass -eq 1 ]; then
		echo "[$0:iptables] Creating forwards between $nat_dev"
		/usr/sbin/iptables -A FORWARD -i $nat_dev -j ACCEPT
		/usr/sbin/iptables -A FORWARD -o $nat_dev -j ACCEPT
	else
		echo "[$0:iptables] $nat_dev NAT: disabled"
	fi


}
# 根据配置关闭NAT,配置ufw和iptables规则
down(){
	echo "[$nat_dev]NAT down"
	echo "[$0: ufw route] deleting $fwd_dev  $usb_dev  $netif_dev"
	/usr/sbin/ufw route delete allow in on $nat_dev out on $fwd_dev 2&>/dev/null >/dev/null
	/usr/sbin/ufw route delete allow in on $nat_dev out on $usb_dev 2&>/dev/null >/dev/null
	/usr/sbin/ufw route delete allow in on $nat_dev out on $netif_dev 2&>/dev/null >/dev/null

	echo "[$0:iptables] deleting FORWARD $nat_dev"
	/usr/sbin/iptables -D FORWARD -i $nat_dev -j ACCEPT 2&>/dev/null >/dev/null
	/usr/sbin/iptables -D FORWARD -o $nat_dev -j ACCEPT 2&>/dev/null >/dev/null
	echo "[$0: iptables] deleting $fwd_dev $usb_dev $netif_dev"
	/usr/sbin/iptables -t nat -D POSTROUTING -o $fwd_dev -j MASQUERADE 2&>/dev/null >/dev/null
	/usr/sbin/ip6tables -t nat -D POSTROUTING -o $fwd_dev -j MASQUERADE 2&>/dev/null >/dev/null
	
	/usr/sbin/iptables -t nat -D POSTROUTING -o $netif_dev -j MASQUERADE 2&>/dev/null >/dev/null
	/usr/sbin/ip6tables -t nat -D POSTROUTING -o $netif_dev -j MASQUERADE 2&>/dev/null >dev/null

	/usr/sbin/iptables -t nat -D POSTROUTING -o $usb_dev -j MASQUERADE 2&>/dev/null >/dev/null
	/usr/sbin/ip6tables -t nat -D POSTROUTING -o $usb_dev -j MASQUERADE 2&>/dev/null >/dev/null
}
# 检测是否有USB设备， 如果有便配置NAT.
if /sbin/ifconfig $usb_dev |/usr/bin/grep -q "inet"; then
	if  /sbin/ifconfig $usb_dev|/usr/bin/grep -v "inet6" |/usr/bin/grep -q "inet" ; then
		echo "IPv4 Address was found."
	else
		echo "IPv4 Address was not found."
	fi
	IP4=$(get_ip4 $usb_dev)
	IP4_netmask_length=$(get_ip4_netmask_length $usb_dev)
	IP4_16=`echo $IP4 | awk -F "." '{print $1"."$2}'`
	#echo " [ $usb_dev ] $IP4"
	#echo " [ $usb_dev/16 ] $IP4_16"
	if [ $IP4_16 == "169.254" ] && [ $IP4_netmask_length == "16" ]; then 
		dhcp_snooping=1
	fi
	#echo " [ $usb_dev netmask length ] $IP4_netmask_length "
	if [ "$dhcp_snooping" == "1" ]; then
		echo "Local Link"
	else
		echo "An IPV4 address has been assigned to $usb_dev: $IP4"
	fi
	if [ -z $IP4  ]; then
		echo "Empty IPv4 address"
		echo `ip addr show $usb_dev`
	fi
	fwd_dev=$usb_dev
fi

echo "Current nat device: $fwd_dev"

# 判断参数并做出命令
if [ "$1" ==  "up" ]; then
	down 2>/dev/null
	up
elif [ "$1" == "down" ]; then
	down 
else
	echo "Unknown operation"
fi
