#!/bin/bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   email : smalldegree@163.com  
#
#   date  : 2015-12-15 20:30:00
#
#   description: 
#           1)This script is used to enable or disable system ipv6 function.
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#   history:
#           1)Created by He Jianfei on 2015-12-15 20:30:00.
#
#---------------------------------------------------------------------------


function usage()
{
cat <<END 2>&1
usage: ${0##*/} [on | off | status]
       on      --   enable ipv6
       off     --   disable ipv6
       status  --   show ipv6 support status
END
}


[ $# -eq 0 ] && usage && exit


ipv6_enable=$1

if [ $ipv6_enable = 'on' ]
then
    grep -i 'NETWORKING_IPV6' > /dev/null 2>&1 /etc/sysconfig/network  
    [ $? -gt 0 ] && echo 'NETWORKING_IPV6=yes' >> /etc/sysconfig/network || sed -i 's/NETWORKING_IPV6.*/NETWORKING_IPV6=yes/g' /etc/sysconfig/network

    [ -e /etc/modprobe.d/ctl_ipv6.conf ] || touch /etc/modprobe.d/ctl_ipv6.conf

    grep -i 'net-pf-10' > /dev/null 2>&1 /etc/modprobe.d/ctl_ipv6.conf 
    [ $? -gt 0 ] && { echo 'alias net-pf-10 on' >> /etc/modprobe.d/ctl_ipv6.conf; echo 'options ipv6 disable=0' >> /etc/modprobe.d/ctl_ipv6.conf; } || sed -i \
    -e 's/disable.*/disable=0/g; s/alias net-pf-10.*/alias net-pf-10 on/g' /etc/modprobe.d/ctl_ipv6.conf

    sed -i 's/#::1/::1/g' /etc/hosts
elif [ $ipv6_enable = 'off' ]
then
    grep -i 'NETWORKING_IPV6' > /dev/null 2>&1 /etc/sysconfig/network  
    [ $? -gt 0 ] && echo 'NETWORKING_IPV6=no' >> /etc/sysconfig/network || sed -i 's/NETWORKING_IPV6.*/NETWORKING_IPV6=no/g' /etc/sysconfig/network

    [ -e /etc/modprobe.d/ctl_ipv6.conf ] || touch /etc/modprobe.d/ctl_ipv6.conf

    grep -i 'net-pf-10' > /dev/null 2>&1 /etc/modprobe.d/ctl_ipv6.conf 
    [ $? -gt 0 ] && { echo 'alias net-pf-10 off' >> /etc/modprobe.d/ctl_ipv6.conf; echo 'options ipv6 disable=1' >> /etc/modprobe.d/ctl_ipv6.conf; } || sed -i \
    -e 's/disable.*/disable=1/g; s/alias net-pf-10.*/alias net-pf-10 off/g' /etc/modprobe.d/ctl_ipv6.conf

    sed -i 's/\(::1\)/#\1/g' /etc/hosts
elif [ $ipv6_enable = 'status' ]
then
    grep -i 'NETWORKING_IPV6' > /dev/null 2>&1 /etc/sysconfig/network
    [ $? -gt 0 ] && echo "ipv6_enable: on" || echo "ipv6_enable: $(cat /etc/sysconfig/network | sed -n '/NETWORKING_IPV6/p' | awk -F '=' '{print $2}')"
    exit
else
    echo "Parameter error: para must be 'on' or 'off' or 'status'."
    exit
fi

echo "The system ipv6 support goes ${ipv6_enable}, it takes effect after reboot."


