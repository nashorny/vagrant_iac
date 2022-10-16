import sys


def main():
    csvpath = sys.argv[1]
    domainpath = sys.argv[2]
    generate_vagrantfile(domainpath, csvpath)
    generate_kvm_net_file(domainpath, csvpath)


def generate_vagrantfile(domainpath, csvpath):
    csv = open(csvpath, "r")
    for csvline in csv:
        box = parse_csv_line_to_box(csvline)
        if bool(box):
            write_vagrantfile(domainpath, box)


def parse_csv_line_to_box(csvline):
    box = {}
    if not csvline.startswith("#"):
        csv_values =  csvline.split(";")
        if len(csv_values) == 8:
            box['host'] = csv_values[0]
            box['mac'] = csv_values[1]
            box['ip'] = csv_values[2]
            box['cpu'] = csv_values[3]
            box['mem'] = csv_values[4]
            box['disk'] = csv_values[5]
            box['image'] = csv_values[6]
            box['script'] = csv_values[7].strip()
    return box


def write_vagrantfile(domainpath, box):
    with open(domainpath + "/Vagrantfile", "a") as vagrant_file:
        vagrant_file.write(f'Vagrant.configure("2") do |config|\n')
        vagrant_file.write(f' config.vm.synced_folder "{domainpath}", "/vagrant", type: "rsync"\n')
        vagrant_file.write(f' config.vm.define :{box["host"]} do |node|\n')
        if 'centos' not in box['image']:
            vagrant_file.write(f' node.ssh.username = "vagrant"\n')
            vagrant_file.write(f' node.ssh.password = "vagrant"\n')
        vagrant_file.write(f'  node.vm.box = "{box["image"]}"\n')
        vagrant_file.write(f'  node.vm.hostname = "{box["host"]}"\n')
        vagrant_file.write(f'  node.vm.provision "shell", run: "always", inline: "/bin/bash /vagrant/share/{box["script"]}"\n')
        vagrant_file.write(f'  node.vm.provider :libvirt do |domain|\n')
        vagrant_file.write(f'   domain.management_network_address = "192.168.122.0/24"\n')
        vagrant_file.write(f'   domain.management_network_name = "default"\n')
        vagrant_file.write(f'   domain.management_network_mode = "nat"\n')
        vagrant_file.write(f'   domain.management_network_mac = "'+box['mac'].replace(':', '')+'"\n')
        vagrant_file.write(f'   domain.memory = {box["mem"]}\n')
        vagrant_file.write(f'   domain.cpus = {box["cpu"]}\n')
        vagrant_file.write(f'   domain.machine_virtual_size = {box["disk"]}\n')
        vagrant_file.write(f'   domain.nested = true\n')
        vagrant_file.write(f'   domain.keymap = "es"\n')
        vagrant_file.write(f'   domain.video_type = "qxl"\n')
        vagrant_file.write(f'   domain.graphics_type = "spice"\n')
        vagrant_file.write(f'   domain.graphics_ip = "127.0.0.1"\n')
        vagrant_file.write(f'   domain.channel :type => "spicevmc", :target_name => "com.redhat.spice.0", :target_type => "virtio"\n')
        vagrant_file.write(f'   domain.input :type => "tablet", :bus => "usb"\n')
        vagrant_file.write(f'  end\n')
        vagrant_file.write(f' end\n')
        vagrant_file.write(f'end\n\n')


def generate_kvm_net_file(domainpath, csvpath):
    csv = open(csvpath, "r")
    dhcp_block = ""
    for csvline in csv:
        box = parse_csv_line_to_box(csvline)
        if bool(box):
            dhcp_block += dhcp_line(box)
    write_kvm_net(domainpath, dhcp_block)
    write_kvm_dhcp_items(domainpath, dhcp_block)


def dhcp_line(box):
    return "<host mac='"+box["mac"]+"' name='"+box["host"]+"' ip='"+box["ip"]+"'/>\n"


def write_kvm_net(domainpath, dhcp_block):
    with open(domainpath + "/defaultnet.xml", "w") as kvm_net_file:
        kvm_net_file.write("<network>\n")
        kvm_net_file.write(" <name>default</name>\n")
        kvm_net_file.write(" <uuid>1a00a42a-e1f9-420b-b2df-18e7752cc015</uuid>\n")
        kvm_net_file.write(" <forward mode='nat'/>\n")
        kvm_net_file.write(" <bridge name='virbr0' stp='on' delay='0'/>\n")
        kvm_net_file.write(" <mac address='52:54:00:e3:46:61'/>\n")
        kvm_net_file.write(" <ip address='192.168.122.1' netmask='255.255.255.0'>\n")
        kvm_net_file.write("  <dhcp>\n")
        kvm_net_file.write("   <range start='192.168.122.100' end='192.168.122.254'/>\n")
        kvm_net_file.write(dhcp_block)
        kvm_net_file.write("  </dhcp>\n")
        kvm_net_file.write(" </ip>\n")
        kvm_net_file.write("</network>\n")


def write_kvm_dhcp_items(domainpath, dhcp_block):
    with open(domainpath + "/netmodify.txt", "w") as kvm_dhcp_file:
        kvm_dhcp_file.write(dhcp_block)


if __name__ == '__main__':
    main()
