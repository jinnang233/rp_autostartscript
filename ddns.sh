#!/usr/bin/bash

# 加载配置文件参数
workdir=$(cd $(dirname $0); pwd)
source $workdir/config
if [ "$ddns" -eq 0 ]; then
	echo "DDNS has been disabled"
	exit
fi

# 获取IP地址并回显
if [ $mngtmpaddr -eq 0 ]; then
	IP6=`ip -6 addr show | grep global |grep -v "mngtmpaddr" | awk '{print \$2}' | awk -F "/" '{print \$1}'`
else

	IP6=`ip -6 addr show | grep global | awk '{print \$2}' | awk -F "/" '{print \$1}'`
fi
for IP in ${IP_range[@]}; do
	IP=$(echo "$IP" |awk -F"/" '{print $1}')
	echo "Local IP: $IP"
	IP6=$(echo $IP6 |sed "s/$IP//g")
done
echo  -e "All IP Addresses: \n$IP6"


# 选取获得的第一个IPv6地址
IP6=`echo $IP6 |awk -F ' ' '{print $1}'`
echo "Selected: $IP6"
[ -z $IP6 ] && exit

# 使用curl更新ddns
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$subdomain_id" \
    -H "Authorization: Bearer $auth_key" \
    -H "Content-Type: application/json" \
    --data '{"type":"AAAA","name":"'"$ddns_subdomain"'","content":"'"${IP6}"'","ttl":120,"proxied":false}' \
    | python -m json.tool |tee -a $log_dir






