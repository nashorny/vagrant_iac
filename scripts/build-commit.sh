#!/bin/bash
export VAGRANT_HOME=/inst/vagrant
VMDOMAIN=/inst/vmdomains/$1
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
mkdir -p $VMDOMAIN/share
cp -rp $WORKSPACE/provision/$1/* $SSHKEY $VMDOMAIN/share

#Generate Vagrantfile
/usr/bin/python $WORKSPACE/scripts/kvm-vagrant-build.py $CSV $VMDOMAIN

#prepare kvm networking
virsh net-destroy default
sudo virsh net-undefine default
sudo virsh net-define $VMDOMAIN/defaultnet.xml
virsh net-start default

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
sleep 10
/usr/bin/vagrant halt
sleep 10
mkdir -p $VAGRANT_HOME/package
sudo /usr/bin/vagrant package --output $VAGRANT_HOME/package/$1.box
sudo chown nash:nash $VAGRANT_HOME/package/$1.box
vagrant box remove $1
vagrant box prune $1
/usr/bin/vagrant box add --force $VAGRANT_HOME/package/$1.box --name $1
