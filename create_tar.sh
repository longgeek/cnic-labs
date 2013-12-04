#!/bin/bash

TOP_DIR=$(cd $(dirname "$0") && pwd)

cd $TOP_DIR
cd ../

all_tar() {
    for i in nova cinder glance keystone horizon noVNC savanna ceilometer openstack_auth ganglia-webfrontend python-ceilometerclient python-cinderclient python-glanceclient python-keystoneclient python-novaclient
    do
        echo "\nPacking $i ....."
        sudo tar zcf $TOP_DIR/puppet/files/$i.tar.gz $i
    done
}

one_tar() {
    sudo tar zcf $TOP_DIR/puppet/files/$pack_name.tar.gz $pack_name && echo "Package $pack_name build done!\n"
}

echo " Package Number:---------------------------------------------------\n"
echo ' Enter: All packages' 
echo ' a. nova'
echo ' b. cinder'
echo ' c. glance'
echo ' d. keystone'
echo ' e. horizon'
echo ' f. noVNC'
echo ' g. savanna'
echo ' h. ceilometer'
echo ' i. openstack_auth'
echo ' j. ganglia-webfrontend'
echo ' k. python-ceilometerclient'
echo ' l. python-cinderclient'
echo ' m. python-glanceclient'
echo ' n. python-keystoneclient'
echo " o. python-novaclient"
echo " p. python-navigatorclient\n"
echo ' Q. exit'

read -p "Enter the number of letters to be packaged: " pack_name

case $pack_name in
    '') all_tar;;
    'Q') echo "\n"; exit 0;;
    'a') pack_name='nova'; one_tar;;
    'b') pack_name='cinder'; one_tar;; 
    'c') pack_name='glance'; one_tar;;
    'd') pack_name='keystone'; one_tar;;
    'e') pack_name='horizon'; one_tar;;
    'f') pack_name='noVNC'; one_tar;;
    'g') pack_name='savanna'; one_tar;;
    'h') pack_name='ceilometer'; one_tar;;
    'i') pack_name='openstack_auth'; one_tar;;
    'j') pack_name='ganglia-webfrontend'; one_tar;;
    'k') pack_name='python-ceilometerclient'; one_tar;;
    'l') pack_name='python-cinderclient'; one_tar;;
    'm') pack_name='python-glanceclient'; one_tar;;
    'n') pack_name='python-keystoneclient'; one_tar;;
    'o') pack_name='python-novaclien'; one_tar;;
    'p') pack_name='python-navigatorclient'; one_tar;;
    *)   echo 'Inpute Errors!'; exit 1

esac
