#!/bin/bash
echo "Wait 30 sec for mysql db ready"
sleep 30
read CIDR <<<$(/sbin/ip route list | awk '{ if ($0 ~ "'$IP'") { print $1 } }')
eval $(/bin/ipcalc -n -m $CIDR 2>/dev/null)
DOMAIN="idcos.com"
/bin/sed -i -e "s/#{IP}/$IP/g" \
            -e "s/#{NETWORK}/$NETWORK/g" \
            -e "s/#{NETMASK}/$NETMASK/g" \
            -e "s/#{DOMAIN}/$DOMAIN/g" \
            "/etc/dhcp/dhcpd.conf" \
            "/etc/dnsmasq.d/hosts.conf"
echo "cloudboot started"
exec /sbin/init
