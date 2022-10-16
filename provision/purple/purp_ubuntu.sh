#### Ubuntu1804 Box preparation
# https://holdmybeersecurity.com/2021/02/04/ir-tales-the-quest-for-the-holy-siem-graylog-auditd-osquery/
sudo usermod -p '$6$xyz$..nPhuX9fvttLoVCA4THygI77eCMd8kBGcQJDudyWHAeflYvPxm9lQsbHvxdOrZFn0GAmLFmvy3uQrO1kb01J1' vagrant
sudo cat /vagrant/share/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
sudo timedatectl set-timezone Europe/Madrid
sudo apt-get update -y && sudo apt-get install -y git

#### auditd
#sudo apt-get install -y auditd audispd-plugins

#### osquery
#wget https://pkg.osquery.io/deb/osquery_4.7.0-1.linux_amd64.deb -O osquery.deb && sudo dpkg -i osquery.deb && \
#sudo cp /vagrant/share/osquery/osquery.* /etc/osquery
#sudo chmod 644 /etc/osquery/osquery.*
#sudo systemctl enable osqueryd && sudo systemctl restart osqueryd

#### Security Compliance
#git clone https://github.com/CISOfy/lynis
#sudo apt-get install libopenscap8
#wget https://security-metadata.canonical.com/oval/com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
#bunzip2 com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
#oscap oval eval --report ubuntu1804-report.html com.ubuntu.$(lsb_release -cs).usn.oval.xml

#### Wazuh Endpoint Protection Prevention
#curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
#echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
#sudo apt-get update -y && sudo apt-get install -y wazuh-agent
#systemctl enable wazuh-agent
#systemctl start wazuh-agent

#### AppArmor
#https://medium.com/information-and-technology/so-what-is-apparmor-64d7ae211ed

#### Firewall: ufw
#sudo systemctl start apparmor
#sudo aa-status