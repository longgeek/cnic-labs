#!/bin/bash

INTERFACES="eth0"

geek ()
{
clear
echo "Step no: 0 of 2 | Index
--------------------------------------------------------------------------------"
echo "You will complete the steps below during this installation:\n"
echo "Step 1 : Set Networks [default]"
echo "Step 2 : Auto Replaces File Content"
echo "\nq. Quit"
echo "--------------------------------------------------------------------------------"
}

geek

select_one ()
{
    clear
    echo "
    --------------------------------------------------------------------------------
    Loding... Please wait...
    --------------------------------------------------------------------------------"
    sleep 0.3
    clear
    
    echo "Step no: 1 of 2 | Set Networks
    --------------------------------------------------------------------------------"
    echo "1. Set the hostname [default]"
    echo "2. Set the ip address"
    echo "3. Set the subnet mask of the network"
    echo "4. Setting up a network gateway"
    echo "5. Set up a network to resolve host"
    echo "\nq. Quit"
    echo "--------------------------------------------------------------------------------"
    
    while true
    do
        read -p "Please type a selection or press "Enter" to accept default choice [1]: " READ_INPUT
    
        case $READ_INPUT in
            "q") echo "\n" && exit 0 ;;
            "") echo "\n"; read -p "1. Place input hostname (FQDN): " HOST_NAME && \
                echo "\n"; read -p "2. Place input ip: " IP && echo "\n"; read -p "3. Place input netmask: " NET_MASK && \
                echo "\n"; read -p "4. Place input gateway: " GATE_WAY && echo "\n"; read -p "5. Place input dns1: " DNS_ONE && \
                echo "\n"; read -p "5.1 Place input dns2: " DNS_TWO && \
                break ;;
    
            "1") read -p "Place input hostname (FQDN): " HOST_NAME ;;
            "2") read -p "Place input ip:" IP ;;
            "3") read -p "Place input netmask:" NET_MASK ;;
            "4") read -p "Place input gateway:" GATE_WAY ;;
            "5") read -p "Place input dns1:" DNS_ONE;read -p "Place input dns2:" DNS_TWO ;;
    
            *) echo "Incorrect input, please try again"
        esac
    done
    cat > /etc/network/interfaces << _GEEK_
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $IP
    netmask $NET_MASK
    gateway $GATE_WAY
    dns-nameservers $DNS_ONE $DNS_TWO
_GEEK_
        
    echo "\nPlease wait..."
    /etc/init.d/networking restart 2> /dev/null | egrep '(fail!|Failed)' > /dev/null
    if [ "$?" = "0" ]; then
        echo "\nNOTE:\nNetwork startup errors, please re-run the script to set the network!\n"
        exit 1
    fi
    hostname $HOST_NAME
    sysctl -w kernel.hostname=$HOST_NAME > /dev/null
    echo $HOST_NAME > /etc/hostname
    echo "\nSuccessful network settings!"
    sleep 2
    clear
    echo "Step no: 2 of 2 | Auto Replaces File Content
--------------------------------------------------------------------------------"
    echo "Replaces...."
    get_networks || exit 1
    auto_replaces || exit 1
    echo "\nReplace file Content Complete!\n"
    exit 0
}

get_networks()
{
    IP_ADDRES=$(ifconfig $INTERFACES | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}')
    DHCP_RANGE=$(echo $(ifconfig $INTERFACES | grep Bcast | awk '{print $3}' | awk -F: '{print $2}') | sed 's/255/0/g')
    HOST_NAME=$(hostname)
}

auto_replaces()
{
    OLD_IP=$(grep next_server /etc/cobbler/settings | awk '{print $2}')
    OLD_DHCP_RANGE=$(grep dhcp-range /etc/cobbler/dnsmasq.template | awk -F= '{print $2}' | awk -F, '{print $1}')
    OLD_HOSTNAME=$(grep server= /etc/puppet/puppet.conf | awk -F= '{print $2}')
    sed -i "s/127.0.1.1.*$/127.0.1.1       $HOST_NAME $(echo $HOST_NAME|awk -F. '{print $1}')/g" /etc/hosts
    cat > /etc/puppet/autosign.conf << _GEEK_
$HOST_NAME
*.$(echo $HOST_NAME | awk -F. '{print $2"."$3}')
*.local
_GEEK_

    for i in '/etc/cobbler/dnsmasq.template' '/etc/dnsmasq.conf';
    do
        sed -i "s/$OLD_DHCP_RANGE/$DHCP_RANGE/g" $i
        sed -i "s/^domain.*$/domain=$(echo $HOST_NAME | awk -F. '{print $2"."$3}')/g" $i
    done

    REPLACE_FILE_IP=$(for i in /etc/ /var/lib/tftpboot/pxelinux.cfg/ /var/lib/cobbler/kickstarts/ /var/www/;
    do
        find $i | xargs grep $OLD_IP 2> /dev/null | awk -F: '{print $1}' |uniq
    done)

    REPLACE_FILE_HOSTNAME=$(for i in /etc/ /var/lib/tftpboot/pxelinux.cfg/ /var/lib/cobbler/kickstarts/ /var/www/;
    do
        find $i | xargs grep $OLD_HOSTNAME 2> /dev/null | awk -F: '{print $1}' |uniq
    done)

    for i in $REPLACE_FILE_HOSTNAME;
    do
        sed -i "s/$OLD_HOSTNAME/$HOST_NAME/g" $i        
    done

    for i in $REPLACE_FILE_IP;
    do
        sed -i "s/$OLD_IP/$IP_ADDRES/g" $i
    done
    puppet cert clean -a > /dev/null 2>&1
    /etc/init.d/puppetmaster restart > /dev/null 2>&1
    cobbler sync > /dev/null 2>&1
}

while true
do
    read -p "Please type a selection or press "Enter" to accept default choice [1]: " READ_INPUT
    
    if [ "$READ_INPUT" = "q" ]; then
        echo "\n" && exit 0
    elif [ "$READ_INPUT" = "" -o "$READ_INPUT" = "1" ]; then
        select_one
    elif [ "$READ_INPUT" = "2" ]; then
        clear
        echo "Step no: 2 of 2 | Auto Replaces File Content
--------------------------------------------------------------------------------"
        echo "Replaces...."
        get_networks || exit 1
        auto_replaces || exit 1
        echo "\nReplace file Content Complete!\n"
        break
    else
        echo "Incorrect input, please try again"
    fi
done
