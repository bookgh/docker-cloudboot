#!/bin/bash

/bin/cp example.yml docker-compose.yml

local_ip=$(nmcli device show eth0 | grep IP4.ADDRESS | awk '{print $NF}' | cut -d '/' -f1 | head -n1)

read -p '请输入数据存储目录：[/data]' data_dir
read -p "请输入当前服务器IP地址：[$local_ip]" server_ip


data_dir=${data_dir:-/data}
server_ip=${server_ip:-$local_ip}
sed -i "s#{{DATA_DIR}}#$data_dir#" docker-compose.yml
sed -i "s/{{SERVER_IP}}/$server_ip/" docker-compose.yml


docker-compose up -d
