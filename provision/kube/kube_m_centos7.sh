#### Centos7 Box preparation
sudo usermod -p '$6$xyz$..nPhuX9fvttLoVCA4THygI77eCMd8kBGcQJDudyWHAeflYvPxm9lQsbHvxdOrZFn0GAmLFmvy3uQrO1kb01J1' vagrant
sudo cat /vagrant/share/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
sudo timedatectl set-timezone Europe/Madrid
sudo yum update -y && sudo yum install -y docker

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a
sudo systemctl enable docker
sudo systemctl start docker

sudo bash -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "192.168.122.61  kube1" | sudo tee -a /etc/hosts
echo "192.168.122.62  kube2" | sudo tee -a /etc/hosts
echo "192.168.122.63  kube3" | sudo tee -a /etc/hosts

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | grep -e "kubeadm join " -e "discovery-token-ca-cert-hash" > /home/vagrant/kube_init

#set config to allow normal user to exec kubectl ...
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#Then no need to execute as root
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#only for checking
kubectl get nodes
kubectl get pods --all-namespaces

sudo kubeadm token create --print-join-command > /vagrant/join.sh
sudo chown vagrant:vagrant  /vagrant/join.sh
