#!/bin/bash
localNetworkCard="$(ip route|grep default|awk '{print $5}')"
#Reset firewall
echo y | ufw reset

#Set Default policies
ufw default deny incoming
ufw default allow outgoing

#Public Access IP4
ufw allow in on $localNetworkCard from 193.252.43.113 to any port 22 proto tcp comment "SSH ROUEN"
ufw allow in on $localNetworkCard from 141.94.181.64 to any port 22 proto tcp comment "SSH OVH"


ufw allow in on $localNetworkCard from 141.94.181.64 to any port 10050 proto tcp comment "Zabbix Agent"
ufw allow in on $localNetworkCard from 193.252.43.113 to any port 10050 proto tcp comment "Zabbix Secours ROUEN"


for cloudfipv4 in $(curl --request GET   --url https://api.cloudflare.com/client/v4/ips   --header 'Content-Type: application/json'| jq .result.ipv4_cidrs[] -r); do
    #ufw allow in on $localNetworkCard from $cloudfipv4 proto tcp to any port 80 comment "Cloudflare"
    ufw allow in on $localNetworkCard from $cloudfipv4 proto tcp to any port 443 comment "Cloudflare"
done
ufw allow in on $localNetworkCard proto udp to any port 443 comment "Wireguard UDP"

#Cebox Access
ufw allow in on wg2 from fcf0::/16 to any port 8090 proto tcp comment "WCore sdwan"
ufw allow in on wg2 from fca0::/16 to any port 8090 proto tcp comment "WCore sdwan"
ufw allow in on wg2 from fca1::/16 to any port 8090 proto tcp comment "WCore sdwan"
ufw allow in on wg2 from fca0::/16 to any port 9090 proto tcp comment "WCore Prom"
ufw allow in on wg2 from fca1::/16 to any port 9090 proto tcp comment "WCore Prom"
ufw allow in on wg2 from fcf0::/16 to any port 9090 proto tcp comment "WCore Prom"

echo y | ufw enable
