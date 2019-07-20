#!/bin/bash

VERSION=18.09.4
BIN_DIR=/usr/local/docker/bin

[ $# -ne 1 ] && echo "Usage $0 {install|uninstall}"

repeat() {
    while true; do
        $@ && return
    done
}

install(){
    # 安装 wget
    which wget > /dev/null 2>&1 || { rm -f /etc/yum.repos.d/*.repo; \
    curl -so /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo; \
    curl -so /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo; \
    sed -i '/aliyuncs.com/d' /etc/yum.repos.d/Centos-7.repo /etc/yum.repos.d/epel-7.repo; \
    yum install -y wget; }

    # 时间同步
    yum install -y ntpdate
    ntpdate ntp1.aliyun.com
    hwclock -w
    crontab -l > /tmp/crontab.tmp
    echo "*/20 * * * * /usr/sbin/ntpdate ntp1.aliyun.com > /dev/null 2>&1 && /usr/sbin/hwclock -w" >> /tmp/crontab.tmp
    cat /tmp/crontab.tmp | uniq > /tmp/crontab
    crontab /tmp/crontab
    rm -f /tmp/crontab.tmp /tmp/crontab

    # 关闭selinux, firewalld
    setenforce 0
    sed -i 's#SELINUX=.*#SELINUX=disabled#' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld

    # 下载解压docker 二进制文件
    [ -d $BIN_DIR ] || mkdir -p $BIN_DIR
    repeat wget -c http://kaifa.hc-yun.com:30040/docker-install-bin/docker-${VERSION}.tgz
    tar xvf docker-${VERSION}.tgz -C $BIN_DIR --strip-components 1
    rm -f docker-${VERSION}.tgz
    [ $(grep "# docker path" ~/.bashrc | wc -l) -eq 0 ] && echo -e "\n# docker path\nPATH=$BIN_DIR:\$PATH" >> ~/.bashrc

    #  配置docker加速
    [ -d /etc/docker ] || mkdir /etc/docker
    cat > /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": ["http://3272dd08.m.daocloud.io", "https://docker.mirrors.ustc.edu.cn"],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}
EOF

    # 创建服务管理脚本
    cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io
After=keepalived.service glusterd.service autofs.service

[Service]
Type=idle
Environment="PATH=$BIN_DIR:/bin:/sbin:/usr/bin:/usr/sbin"
ExecStart=$BIN_DIR/dockerd
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

    iptables -P INPUT ACCEPT
    iptables -F
    iptables -X
    iptables -F -t nat
    iptables -X -t nat
    iptables -F -t raw
    iptables -X -t raw
    iptables -F -t mangle
    iptables -X -t mangle

    systemctl daemon-reload
    systemctl start docker
    systemctl enable docker
    systemctl restart docker

    repeat wget -c -O /usr/local/bin/docker-compose http://kaifa.hc-yun.com:30040/docker-install-bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    source ~/.bashrc
    docker -v
    docker-compose -v
    echo -e '\nsource ~/.bashrc\n'
}

uninstall(){
    systemctl stop docker
    systemctl disable docker
    rm -rf $BIN_DIR
    rm -f /etc/docker/daemon.json
    rm -f /etc/systemd/system/docker.service
    rm -f /usr/local/bin/docker-compose
}

case "$1" in
    install) install
    ;;
    uninstall) uninstall
    ;;
    *) echo "Usage $0 {install|uninstall}"
esac
