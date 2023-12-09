#!/usr/bin/bash

# 加载配置文件参数
workdir=$(cd $(dirname $0); pwd)
source $workdir/config
if [ "$ddns" -eq 0 ]; then
	echo "DDNS disabled"
	exit
fi

# 获取IP地址并回显
IP6=`ip -6 addr show | grep global |grep -v "$IP6_assigned" | awk '{print \$2}' | awk -F "/" '{print \$1}'`
echo  -e "All IP Address: \n$IP6"

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
#curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=AAAA&name=$ddns_domain&content=127.0.0.1&page=1&per_page=100&order=type&direction=desc&match=any" \
#    -H "Authorization: Bearer $auth_key" \
#    -H "Content-Type: application/json" \
#    | python -m json.tool






