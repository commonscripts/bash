#!/bin/env bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   email : smalldegree@163.com  
#
#   date  : 2016-07-08 17:15:00
#
#   description: 
#           1)This script is used to deploy tcpcopy environment.
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#   history:
#           1)Created by He Jianfei on 2016-07-08 17:15:00.
#
#           2)Modified the way adding the route item instead of 'route add'
#             by He Jianfei on 2016-07-12 09:47:00.
#
#           3)Added the description that the both servers online and
#             assistant should<must> be on the same 2(3) layer switch or 
#             you must add some routes on middle routers in order to make
#             system works.
#
#           4)We strongly suggested that you should specify the value of 
#             the parameter '-c' about tcpcopy with $ip_online, in other
#             words, $ip_client=$ip_online, then you can copy any online
#             server's flux.
#
#           5)Modified the interpreter way about the script.
#
#           6)Modified the tcpcopy's destination_port.
#
#           7)Modified the tcpcopy's source_port on 2016-08-30 15:43:00.
#
#           8)Added the SSH batch install mode on 2016-08-30 16:26:00.
#
#           9)Added the del rule/route before add them on 2016-08-31 
#             12:06:00.
#
#           10)Add the display config function on 2016-08-31 12:06:00.
#
#           11)Modified the parameter ip_client's default value on
#             2016-09-14 12:08:00.
#
#---------------------------------------------------------------------------


ip_online="192.168.144.182"
ip_test="192.168.145.202"
ip_assistant="192.168.144.184"
ip_client=$ip_online

source_port="1935"
destination_port="1937"

src_libpcap="libpcap-1.7.4.tar.gz"
src_tcpcopy="tcpcopy-1.0.0.tar.gz"
src_intercept="intercept-1.0.0.tar.gz"

ssh_user="root"
sshd_port="22"
config_script="ctl_tcpcopy.sh"


function usage()
{
cat <<END 2>&1

usage: ${0##*/} [t | i | r | si | st]
       t     --   install tcpcopy 
       i     --   install intercept
       r     --   add route on test server
       si    --   start intercept
       st    --   start tcpcopy
       b     --   install intercept and tcpcopy in SSH batch mode
       s     --   display config

01: eg. ${0##*/} t    --  install tcpcopy on online server.
02: eg. ${0##*/} i    --  install intercept on assistant server.
03: eg. ${0##*/} r    --  add route on test server.

04: eg. ${0##*/} si   --  start intercept on assistant server.
05: eg. ${0##*/} st   --  start tcpcopy on online server.

06. eg. ${0##*/} b    --  install intercept and tcpcopy in SSH batch mode.

07. eg. ${0##*/} s    --  display config.

END
}


function install_libpcap()
{
    tar -zxvf $src_libpcap

    cd ${src_libpcap%%.tar.gz}
    
    sh configure
    make && make install
}

function install_tcpcopy()
{
    tar -zxvf $src_tcpcopy

    cd ${src_tcpcopy%%.tar.gz}

    sh configure --with-debug --pcap-capture
    make && make install
}

function install_intercept()
{
    tar -zxvf $src_intercept

    cd ${src_intercept%%.tar.gz}

    sh configure --with-debug --pcap-capture
    make && make install
    
    echo 0 > /proc/sys/net/ipv4/ip_forward
}

function add_route()
{
    echo 1 > /proc/sys/net/ipv4/ip_forward
    #route add -host $ip_client gw $ip_assistant
    #route del -host $ip_client gw $ip_assistant
  
    /sbin/ip rule del to $ip_client > /dev/null 2>&1
    /sbin/ip rule add to ${ip_client}/32 table 500
   
    /sbin/ip route del default table 500 > /dev/null 2>&1
    /sbin/ip route replace default via $ip_assistant table 500

    /sbin/ip rule list | grep $ip_client
    /sbin/ip route list table 500
}

function start_intercept()
{
    interface=$(/sbin/ip addr | sed -n "/$ip_assistant/p" | awk -F ' ' '{print $7}')

    /usr/local/intercept/sbin/intercept -i $interface -F "tcp and src port $destination_port" -d -l /dev/null
}

function start_tcpcopy()
{
    interface=$(/sbin/ip addr | sed -n "/$ip_online/p" | awk -F ' ' '{print $7}')
    
    /usr/local/tcpcopy/sbin/tcpcopy -x ${source_port}-${ip_test}:${destination_port} -s $ip_assistant -c $ip_client -i $interface -F "tcp and dst port $source_port" -d -l /dev/null  
}

function display_config()
{
    echo -e "\033[32mCongratulations: tcpcopy environment has been deployed successfully, if you are sure of running ${0##*/} b\033[0m"
    echo "configs as follow:"
    echo "    01.ip_client   : ${ip_client}"
    echo "    02.ip_online   : ${ip_online}:$source_port"
    echo "    03.ip_test     : ${ip_test}:$destination_port"
    echo ""
    echo "    04.ip_assistant: ${ip_assistant}:36524, default"
    echo ""
    echo "    version info:"
    echo "    libpcap:   $src_libpcap"
    echo "    tcpcopy:   $src_tcpcopy"
    echo "    intercept: $src_intercept"
    echo ""
    echo "    data flow:"
    echo "    xxx.xxx.xxx.xxx:yyyy    -->    ${ip_online}:$source_port (ip_online)"
    echo "    ${ip_client}:vvvv    -->    ${ip_test}:$destination_port  (tcpcopy's copy)"
    echo "    ${ip_test}:$destination_port    -->    ${ip_client}:vvvv  (tcpcopy's forward, real server: $ip_assistant)"
    echo ""
}


[ $# -eq 0 ] && usage && exit


if [ $1 = 't' ]
then
    install_libpcap && cd .. && install_tcpcopy

    [ -e /usr/local/tcpcopy/sbin/tcpcopy ] && echo -e "\033[32mservice tcpcopy has been installed successfully!\033[0m"
elif [ $1 = 'i' ]
then
    install_libpcap && cd .. && install_intercept
    
    [ -e /usr/local/intercept/sbin/intercept ] && echo -e "\033[32mservice intercept has been installed successfully!\033[0m"
elif [ $1 = 'r' ]
then
    add_route

    #route -n | grep "$ip_client" 2>&1 > /dev/null && echo -e "\033[32mstatic route item has been added successfully!\033[0m"
    /sbin/ip route list table 500 | grep "$ip_assistant" 2>&1 > /dev/null && echo "" && echo -e "\033[32mstatic route item has been added successfully!\033[0m"                                                                                                                          
elif [ $1 = 'si' ]
then
    [ -e /usr/local/intercept/sbin/intercept ] && killall -9 intercept > /dev/null 2>&1
    start_intercept

    ps axu | grep 'intercept' 2>&1 > /dev/null && netstat -atunp | grep 'intercept' 2>&1 > /dev/null && echo -e "\033[32mservice intercept has been started successfully!\033[0m"
elif [ $1 = 'st' ] 
then                                                                                                                                            
    [ -e /usr/local/tcpcopy/sbin/tcpcopy ] && killall -9 tcpcopy > /dev/null 2>&1
    start_tcpcopy

    ps axu | grep 'tcpcopy' 2>&1 > /dev/null && netstat -atunp | grep 'tcpcopy' 2>&1 > /dev/null && echo -e "\033[32mservice tcpcopy has been startd successfully!\033[0m" 
elif [ $1 = 'b' ]
then
    scp -P $sshd_port $config_script $src_libpcap $src_intercept ${ssh_user}@${ip_assistant}:/tmp/
    ssh -p $sshd_port -l $ssh_user $ip_assistant "{ cd /tmp/ && sh ${config_script} i; } && { sh ${config_script} si; }" 
    echo ""                                                                                                                                                                       

    sleep 1
    scp -P $sshd_port $config_script $src_libpcap $src_tcpcopy ${ssh_user}@${ip_online}:/tmp/
    ssh -p $sshd_port -l $ssh_user $ip_online "{ cd /tmp/ && sh ${config_script} t; } && { sh ${config_script} st; }" 
    echo ""

    sleep 1
    scp -P $sshd_port $config_script ${ssh_user}@${ip_test}:/tmp/
    ssh -p $sshd_port -l $ssh_user $ip_test "{ cd /tmp/ && sh ${config_script} r; }" 

    echo ""
    display_config
elif [ $1 = 's' ]
then
    display_config
else
    echo "Unknown parameter."
fi


