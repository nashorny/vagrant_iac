#!/bin/bash
export VAGRANT_HOME=/inst/vagrant
VMDOMAIN=/inst/vmdomains/$1
NETMODIFY=$VMDOMAIN/netmodify.txt
WORKSPACE=$2
CSV=$WORKSPACE/files/$1.csv
SSHKEY=$WORKSPACE/files/id_rsa.pub

#Clean previous vagrant domain
mkdir -p $VMDOMAIN
cd $VMDOMAIN
/usr/bin/vagrant destroy -f
rm -rf $VMDOMAIN/*
/usr/bin/vagrant init

#Prepare new vagrant domain
# cp $WORKSPACE/Vagrantfile $VMDOMAIN
cp $WORKSPACE/scripts/vagrantdestroy.sh $VMDOMAIN
cp $WORKSPACE/scripts/halt.sh $VMDOMAIN
cp $WORKSPACE/scripts/up.sh $VMDOMAIN
mkdir -p $VMDOMAIN/share
cp -rp $WORKSPACE/provision/$1/* $SSHKEY $VMDOMAIN/share

#Generate Vagrantfile
/usr/bin/python3 $WORKSPACE/scripts/kvm-vagrant-build.py $CSV $VMDOMAIN

#prepare kvm networking
#virsh net-destroy default
#sudo virsh net-undefine default
#sudo virsh net-define $VMDOMAIN/defaultnet.xml
#sudo virsh net-define /usr/share/libvirt/networks/default.xml
#sudo virsh net-autostart default
#sudo virsh net-start default

sudo virsh net-start default 2>/dev/null
while read line; do
  echo "Modifying network $line"
  sudo virsh net-update --network default --command delete --section ip-dhcp-host --config --xml "$line" &>/dev/null
  sudo virsh net-update --network default --command delete --section ip-dhcp-host --xml "$line" 1>/dev/null
  sudo virsh net-update --network default --command add --section ip-dhcp-host --config --xml "$line" &>/dev/null
  sudo virsh net-update --network default --command add --section ip-dhcp-host --xml "$line" 1>/dev/null
done < "$NETMODIFY"

#/etc/hosts entries
cp -p /etc/hosts $HOME
while read line; do
    if [ "$(echo $line | grep '#')" == "" ]; then
        HOSTN=$(echo $line | cut -d';' -f1)
        IP=$(echo $line | cut -d';' -f3)
        EXIST=$(grep $HOSTN /etc/hosts)
        if [ "$EXIST" != "" ]; then
            sudo sed -i "s/.*$HOSTN/$IP $HOSTN/" /etc/hosts
        else
            echo "$IP $HOSTN" | sudo tee -a /etc/hosts
        fi
    fi
done < "$CSV"

#Build environment
/usr/bin/vagrant up --provider=libvirt --no-parallel