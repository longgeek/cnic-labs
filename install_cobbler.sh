#!/bin/bash

#apt-get update || exit 0

# 一些基本的变量
TOP_DIR=$(cd $(dirname "$0") && pwd)
COBBLER_WEB_PORT=12001
MANAGE_INTERFACE='eth0'
ROOT_PASSWD="111111"
IPADDR=$(ifconfig $MANAGE_INTERFACE | awk '/inet addr/ {print $2}' | awk -F: '{print $2}')
GATEWAY=$(route -n | grep $MANAGE_INTERFACE | grep ^0.0.0.0 | awk '{print $2}')
CHECK_HOSTNAME=$(hostname | awk -F. '{print $3}')
ZONENAME=$(hostname | awk -F . '{print $2"."$3}')
LS_ISO=$(file /opt/*.iso | grep 'Ubuntu-Server 1[2,3]' | head -n1)
ISO_NAME=$(echo $LS_ISO | awk -F: '{print $1}')
ISO_TYPE=$(echo $LS_ISO | awk -F"'" '{print $2}' | awk '{print $1"-"$2}')

## 判断 IP 地址是否设置; 主机名是否为 FQDN; /opt/下是否存在 ISO 文件; 是否有网关.
if [ "$IPADDR" = "" -o "$ZONENAME" = "." -o "$LS_ISO" = "" -o "$GATEWAY" = "" -o "$CHECK_HOSTNAME" = "" ]
then
    echo "\nERROR: 'Not set ip address!' or 'Hostname not FQDN!' or 'Iso not found!' or 'Not set gateway!'\n"
    exit 0
fi

## 安装相关软件包
apt-get -y --force-yes install cobbler cobbler-web dnsmasq debmirror ntp || exit 0

## 修改 Cobbler 配置文件
COBBLER_PATH='/etc/cobbler/settings'
sed -i '/^manage_dhcp:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/^manage_dns:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/^manage_rsync:.*$/ s/0/1/g' $COBBLER_PATH
sed -i '/http_port: .*$/ s/80/12001/g' $COBBLER_PATH
sed -i 's/= manage_dhcp/= manage_dnsmasq/g' /etc/cobbler/modules.conf
sed -i 's/= manage_isc/= manage_dnsmasq/g' /etc/cobbler/modules.conf
grep $COBBLER_WEB_PORT /etc/apache2/ports.conf || sed -i "s/Listen 80/Listen 80\nListen $COBBLER_WEB_PORT/g" /etc/apache2/ports.conf
/etc/init.d/apache2 restart
cp $TOP_DIR/eccp.preseed /var/lib/cobbler/kickstarts/eccp.preseed

## DNSmasq 模版设置
cat > /etc/cobbler/dnsmasq.template << _GEEK_
# Cobbler generated configuration file for dnsmasq
# \$date 
#

# resolve.conf .. ?
#no-poll
#enable-dbus
read-ethers
addn-hosts = /var/lib/cobbler/cobbler_hosts
#domain=

#dhcp-range=192.168.99.5,192.168.99.200
dhcp-option=3,\$next_server
dhcp-lease-max=1000
dhcp-authoritative
dhcp-boot=pxelinux.0
dhcp-boot=net:normalarch,pxelinux.0
dhcp-boot=net:ia64,\$elilo

\$insert_cobbler_system_definitions
_GEEK_

## 挂在 ISO 镜像，并导入
umount $ISO_NAME
mkdir /geek
mount -o loop $ISO_NAME /geek/ || exit 0
cobbler import --path=/geek --name=$ISO_TYPE
cobbler distro edit --name=$ISO_TYPE-x86_64 \
--kernel=/var/www/cobbler/ks_mirror/$ISO_TYPE/install/netboot/ubuntu-installer/amd64/linux \
--initrd=/var/www/cobbler/ks_mirror/$ISO_TYPE/install/netboot/ubuntu-installer/amd64/initrd.gz \
--os-version=precise
cobbler profile edit --name=$ISO_TYPE-x86_64 \
--kopts="netcfg/choose_interface=auto " \
--kickstart=/var/lib/cobbler/kickstarts/eccp.preseed

## 设置 cobbler_web 登录用户名字:cobbler 密码:cobbler
echo "cobbler:Cobbler:a2d6bae81669d707b72c0bd9806e01f3" > /etc/cobbler/users.digest

/etc/init.d/cobbler restart
cobbler sync || exit 0
