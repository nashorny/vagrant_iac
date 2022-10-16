#### Centos7 Box preparation
sudo usermod -p '$6$xyz$..nPhuX9fvttLoVCA4THygI77eCMd8kBGcQJDudyWHAeflYvPxm9lQsbHvxdOrZFn0GAmLFmvy3uQrO1kb01J1' vagrant
sudo cat /vagrant/share/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
sudo timedatectl set-timezone Europe/Madrid
sudo yum update -y && sudo yum install -y git

#### auditd
#sudo yum install -y audit audit-libs

#### osquery - EDR
#sudo yum install -y https://pkg.osquery.io/rpm/osquery-4.7.0-1.linux.x86_64.rpm && \
#sudo cp /vagrant/share/osquery/osquery.* /etc/osquery
#sudo chmod 644 /etc/osquery/osquery.*
#sudo systemctl enable osqueryd && sudo systemctl restart osqueryd
#
##### Security Compliance
#git clone https://github.com/CISOfy/lynis
#sudo yum install -y openscap-scanner
#wget https://www.redhat.com/security/data/oval/Red_Hat_Enterprise_Linux_7.xml
#oscap oval eval --results rhsa-results-oval.xml --report centos7-report.html Red_Hat_Enterprise_Linux_7.xml

#### Wazuh Endpoint Protection Prevention
#rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
#cat > /etc/yum.repos.d/wazuh.repo << EOF
#[wazuh]
#gpgcheck=1
#gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
#enabled=1
#name=EL-$releasever - Wazuh
#baseurl=https://packages.wazuh.com/4.x/yum/
#protect=1
#EOF
#sudo yum install -y wazuh-agent
#systemctl enable wazuh-agent
#systemctl start wazuh-agent


#### SELinux
# https://tamirsuliman.medium.com/selinux-101-get-started-with-selinux-to-secure-your-systems-22b9f16fe712
# https://medium.com/@ChristopherShaffer/selinux-making-it-a-little-easier-for-web-b8fad76e2d97

#### Firewall: firewalld

