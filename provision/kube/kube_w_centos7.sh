#### Centos7 Box preparation
sudo usermod -p '$6$xyz$..nPhuX9fvttLoVCA4THygI77eCMd8kBGcQJDudyWHAeflYvPxm9lQsbHvxdOrZFn0GAmLFmvy3uQrO1kb01J1' vagrant
sudo cat /vagrant/share/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
sudo timedatectl set-timezone Europe/Madrid
sudo yum update -y && sudo yum install -y docker

