#!/bin/env bash

proc=${1}
objs=${proc##*/}

function usage()
{
cat <<END 2>&1
usage: ${0##*/} [path_to_objs]
       path_to_objs     --the binary path you want to monitor, such as "/usr/local/nginx/sbin/nginx"
END
}

function handle_proc()
{
    [ -e $proc ] && has_image=1 || echo "The binary image $proc not exist."
}

function pre_oprofileing()
{

    rm -rf /tmp/vmlinuz-$(uname -r) && cp /boot/vmlinuz-$(uname -r) /tmp/

    skip_len=$(od -t x1 -A d /tmp/vmlinuz-$(uname -r) | grep '1f 8b 08' | awk '{print $1}' | sed 's/00//')
    let skip_len=skip_len+9

    rm -rf /tmp/vmlinux* && dd if=/tmp/vmlinuz-$(uname -r) bs=1 skip=$skip_len of=/tmp/vmlinux_temp 2> /dev/null
    zcat /tmp/vmlinux_temp &> /tmp/vmlinux

    wait
    echo 0 > /proc/sys/kernel/watchdog
    echo 0 > /proc/sys/kernel/nmi_watchdog
    sed -i '608,613 s/^[^#]/#&/' /usr/bin/opcontrol
}

function oprofileing()
{
    opcontrol --vmlinux=/tmp/vmlinux && opcontrol --reset
    opcontrol --init && opcontrol --start &> /dev/null

    opcontrol --status | grep 'Daemon running' &> /dev/null
    [ $? -eq 0 ] && { echo "oprofile is ok, please wait a moment."; echo ""; } || { echo "oprofile is not ok."; echo ""; }

    sleep 10 
}

function post_oprofileing()
{
    rm -rf cpu_high && mkdir cpu_high

    opcontrol --dump 2> /dev/null
    opcontrol --shutdown > /dev/null 2>&1 && opcontrol --deinit > /dev/null 2>&1
    
    sed -i '608,613 s/^#/ /' /usr/bin/opcontrol
    echo 1 > /proc/sys/kernel/watchdog
    echo 1 > /proc/sys/kernel/nmi_watchdog

    handle_proc
    opreport > cpu_high/opreport.dat 2> /dev/null
    opreport -l > cpu_high/opreport_l.dat 2> /dev/null

    [ $has_image -eq 1 ] && opreport -l $proc > cpu_high/opreport_l_${objs}.dat 2> /dev/null && opannotate -s $proc > cpu_high/opannotate_s_${objs}.dat 2> /dev/null
}


[ $# -eq 0 ] && usage && exit

pre_oprofileing
oprofileing
post_oprofileing

