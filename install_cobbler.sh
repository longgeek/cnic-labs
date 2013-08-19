#!/bin/bash

apt-get update || exit 0


# 一些基本的变量
MANAGE_INTERFACE='eth0'
ROOT_PASSWD="111111"
IPADDR=$(ifconfig $MANAGE_INTERFACE | awk '/inet addr/ {print $2}' | awk -F: '{print $2}')
ROUTE=$(route -n | grep $MANAGE_INTERFACE | grep ^0.0.0.0 | awk '{print $2}')
CHECKHOSTNAME=$(hostname | awk -F. '{print $3}')
ZONENAME=$(hostname | awk -F . '{print $2"."$3}')
SUBNETZONE=$(echo $IPADDR | awk -F. '{print $1"."$2"."$3}')
SUBNET=$(echo $SUBNETZONE'.0')
NETMASK=$(ifconfig $MANAGE_INTERFACE | awk '/Mask/ {print $4}' | awk -F: '{print $2}')
LS_ISO=$(file /opt/*.iso | grep 'Ubuntu-Server 1[2,3]' | head -n1)
ISO_NAME=$(echo $LS_ISO | awk -F: '{print $1}')
ISO_TYPE=$(echo $LS_ISO | awk -F"'" '{print $2}' | awk '{print $1"-"$2}')

## 判断 IP 地址是否设置; 主机名是否为 FQDN; /opt/下是否存在 ISO 文件; 是否有网关.
if [ "$IPADDR" = "" -o "$ZONENAME" = "." -o "$LS_ISO" = "" -o "$ROUTE" = "" -o "$CHECKHOSTNAME" = "" ]
then
    echo "\nERROR: 'Not set ip address!' or 'Hostname not FQDN!' or 'Iso not found!' or 'Not set gateway!'\n"
        exit 0
    fi
fi

apt-get -y --force-yes install cobbler cobbler-web dnsmasq debmirror puppetmaster puppet ntp || exit 0
## 修改 Cobbler 配置文件
COBBLER_PATH='/etc/cobbler/settings'
sed -i '/^manage_dhcp:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/^manage_dns:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/^manage_rsync:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/^manage_forward_zones:.*$/ s/\[\]/\["'$ZONENAME'"\]/g' $COBBLER_PATH
sed -i '/^manage_reverse_zones:.*$/ s/\[\]/\["'$SUBNETZONE'"\]/g' $COBBLER_PATH
sed -i "s/nobody.example.com/`hostname`/g" /etc/cobbler/zone.template
##sed -i '/^default_password_crypted:.*$/ s/""/"'$ROOT_PASSWD'"/g' $COBBLER_PATH
##sed -i '/^default_kickstart:.*$/ s/ubuntu-server/openstack/g' $COBBLER_PATH

