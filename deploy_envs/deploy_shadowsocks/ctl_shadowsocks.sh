#!/bin/bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   email : smalldegree@163.com  
#
#   date  : 2015-12-25 17:00:00
#
#   description: 
#           1)This script is used to config shadowsocks under Linux os.
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#           3)If you know proxy's domain, you can specify the variable 
#             proxy_domain, otherwise you should specify proxy_ip.
#
#   history:
#           1)Created by He Jianfei on 2015-12-25 17:00:00.
#
#           2)Modifed config, use variable to replace by He Jianfei on
#             2015-12-28 11:50:00.
#---------------------------------------------------------------------------


proxy_domain=""
proxy_ip="10.10.10.200"
proxy_port="15261"
proxy_passwd="123456abcdef"
local_address="0.0.0.0"
local_port="1080"


function pre_check()
{
    which pip
    [ $? -gt 0 ] && easy_install pip
}

function ins_shadowsocks()
{
    pip install shadowsocks
}

function config_shadowsocks()
{
    echo '{' > ~/.config.json
    echo '    "server":"PROXY_IP or PROXY_DOMAIN",' >> ~/.config.json
    echo '    "server_port":PROXY_PORT,' >> ~/.config.json
    echo '    "local_address": "LOCAL_ADDRESS",' >> ~/.config.json
    echo '    "local_port":LOCAL_PORT,'>> ~/.config.json
    echo '    "password":"PROXY_PASSWD",' >> ~/.config.json
    echo '    "timeout":300,' >> ~/.config.json
    echo '    "method":"aes-256-cfb",' >> ~/.config.json
    echo '    "fast_open": false' >> ~/.config.json
    echo '}' >> ~/.config.json

    sed -i "s/PROXY_IP or PROXY_DOMAIN/${proxy_domain:=$proxy_ip}/g" ~/.config.json
    sed -i "s/PROXY_PORT/$proxy_port/g" ~/.config.json
    sed -i "s/PROXY_PASSWD/$proxy_passwd/g" ~/.config.json

    sed -i "s/LOCAL_ADDRESS/$local_address/g" ~/.config.json
    sed -i "s/LOCAL_PORT/$local_port/g" ~/.config.json
}

function show_usage()
{
    echo "Congratulations, Shadowsocks has been configed successfully, you can use 'sslocal -c ~/.config.json' to start it, for more infomation, see 'sslocal -h'."
}


pre_check
ins_shadowsocks
config_shadowsocks
echo "" && show_usage


