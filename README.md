# docker-cloudboot

Thanks to [云霁科技](http://idcos.com/) & [Cloudboot](https://github.com/idcos/Cloudboot) & [osinstall-deploy](https://github.com/idcos/osinstall-deploy)

## docker

    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker

## docker-compose

    curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

## usage

    git clone https://github.com/bookgh/docker-cloudboot.git
    cd docker-cloudboot
    ./run.sh	

## example

    mount -o loop CentOS-7-x86_64-DVD-1810.iso /media
    mkdir -p /data/iso/centos/7.6/os/x86_64/
    rsync -a /media/ /data/iso/centos/7.6/os/x86_64/
    umount /media

确保服务器上80 3306 53 等端口未被占用，最好单独一台服务器。
如果无法访问服务请确认 selinx, 防火墙配置正确

http://{YOUR SERVER IP} username:`admin` ,password:`admin`


[官方文档](http://idcos.github.io/osinstall-doc/)
