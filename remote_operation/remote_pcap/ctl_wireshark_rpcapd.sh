#!/bin/env bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   email : smalldegree@163.com  
#
#   date  : 2016-12-09 11:39:00
#
#   description: 
#           1)This script is used to deploy rpcapd environment.
#
#   history:
#           1)Created by He Jianfei on 2016-11-09 11:39:00.
#
#---------------------------------------------------------------------------


src_rpcapd="WpcapSrc_4_1_2.tar.gz"
listen_port="2002"
default_para="-d -n -4 -p $listen_port"

function usage()
{
cat <<END 2>&1
usage: ${0##*/} [i | r | t | p | u]
       i     --   install the rpcapd service
       r     --   reinstall the service
       m     --   remove the service
       t     --   start the service
       p     --   stop the service
       u     --   check the service status
END
}

function pre_check()
{
    [ -e $src_rpcapd ] || { echo -e "\033[31mNo such file $src_rpcapd in the current directory.\033[0m" && exit; }
}

function ins_rpcapd()
{
    tar -zxvf $src_rpcapd
    cd ${src_rpcapd%%.tar.gz}/wpcap/libpcap

    sh configure
    make

    cd rpcapd
    make
}

function reins_rpcapd()
{
    rm -rf ${src_rpcapd%%.tar.gz}
    ins_rpcapd
}

function remove_rpcapd()
{
    rm -rf ${src_rpcapd%%.tar.gz}
    killall -9 rpcapd
}

function start_rpcapd()
{
    pidof rpcapd > /dev/null
    [ $? -eq 0 ] && echo -e "\033[32mThe service rpcapd has been running!\033[0m" && exit

    ${src_rpcapd%%.tar.gz}/wpcap/libpcap/rpcapd/rpcapd $default_para
}

function stop_rpcapd()
{
    killall -9 rpcapd
}

function show_status()
{
    ps axu | grep -E "rpcapd|${src_rpcapd%%_*}" | grep -vE 'grep|vim|.sh' > /dev/null 
    [ $? -eq 0 ] && { echo -e "\033[32mstatus: running\nport: $listen_port\033[0m"; exit; }
    echo -e "\033[31mstatus: not running\033[0m"
}


[ $# -eq 0 ] && usage && exit
pre_check

if [ $1 = 'i' ]
then
    ins_rpcapd
elif [ $1 = 'r' ]
then
    reins_rpcapd
elif [ $1 = 'm' ]
then
    remove_rpcapd 
elif [ $1 = 't' ]
then
    start_rpcapd
elif [ $1 = 'p' ]
then
    stop_rpcapd
elif [ $1 = 'u' ] 
then                                                                                                                                            
    show_status
else
    echo -e "\033[31mUnknown parameter.\033[0m"
fi

