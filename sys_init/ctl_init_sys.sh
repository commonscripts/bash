#!/bin/bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   date  : 2015-12-14 14:23:00
#
#   email : smalldegree@163.com  
#
#   description: 
#           1)This script is used to init system environment after first
#             system installation.
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#   history:
#           1)Created by He Jianfei on 2015-12-14 14:23:00.
#           2)Modified the yum repo config, enable more base repo by 
#             He Jianfei on 2015-12-16 15:00:00.
#
#---------------------------------------------------------------------------


#01.Base config
HostName="developer"

IP="172.16.1.100"
NetMask="255.255.255.0"
DefaultGateway="172.16.1.254"
DNS="202.106.0.20"
INTER_FILE="/etc/sysconfig/network-scripts/ifcfg-eth0"

Zone="Asia/Chongqing"
NtpServer="time.windows.com"

SELinux="disabled"
Iptables="off"

Language="en_US.UTF-8"
#Language="zh_CN.UTF-8"

VimNu="yes"
SSHDNS="no"

tasknums=04

sed -i "s/HOSTNAME=.*/HOSTNAME=$HostName/g" /etc/sysconfig/network

sed -i "s/ONBOOT=no/ONBOOT=yes/g" $INTER_FILE 
sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=none/g" $INTER_FILE 
sed -i "s/NM_CONTROLLED=yes/NM_CONTROLLED=no/g" $INTER_FILE 

grep -i 'IPADDR' $INTER_FILE > /dev/null 
[ $? -gt 0 ] && echo "IPADDR=$IP" >> $INTER_FILE || sed -i "s/IPADDR=.*/IPADDR=$IP/g" $INTER_FILE 

grep -i 'NETMASK' $INTER_FILE > /dev/null 
[ $? -gt 0 ] && echo "NETMASK=$NetMask" >> $INTER_FILE || sed -i "s/NETMASK=.*/NETMASK=$NetMask/g" $INTER_FILE 

grep -i 'GATEWAY' $INTER_FILE > /dev/null 
[ $? -gt 0 ] && echo "GATEWAY=$DefaultGateway" >> $INTER_FILE || sed -i "s/GATEWAY=.*/GATEWAY=$DefaultGateway/g" $INTER_FILE 

echo "nameserver $DNS" > /etc/resolv.conf

rm -rf /etc/localtime 
cp -n /usr/share/zoneinfo/$Zone /etc/localtime
ntpdate $NtpServer > /dev/null 2>&1 &

sed -i "s/SELINUX=enforcing/SELINUX=$SELinux/g" /etc/selinux/config

chkconfig --level 35 iptables $Iptables
chkconfig --level 35 ip6tables $Iptables

grep 'export LANG' /etc/profile > /dev/null
[ $? -gt 0 ] && echo "export LANG=$Language" >> /etc/profile

grep 'export LC_ALL' /etc/profile > /dev/null
[ $? -gt 0 ] && echo "export LC_ALL=$Language" >> /etc/profile


grep 'set number' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set number' >> /etc/vimrc

grep 'set ts' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set ts=4' >> /etc/vimrc

grep 'set expandtab' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set expandtab' >> /etc/vimrc


grep 'set expandtab' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set expandtab' >> /etc/vimrc

grep 'set expandtab' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set expandtab' >> /etc/vimrc

grep 'set autoindent' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set smartindent' >> /etc/vimrc

grep 'syntax on' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'syntax on' >> /etc/vimrc

grep 'filetype on' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'filetype on' >> /etc/vimrc

grep 'set ruler' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set ruler' >> /etc/vimrc

grep 'set incsearch' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set incsearch' >> /etc/vimrc

grep 'set cursorline' /etc/vimrc > /dev/null
[ $? -gt 0 ] && echo 'set cursorline' >> /etc/vimrc


sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config


#02.Base config report
echo "[Task 01 of $tasknums]"
echo "Your base configuration has finished, configs as follow:"
echo ""
echo "    01.HostName: $(hostname)"
echo ""
echo "    02.SELinux: $(grep 'SELINUX=' /etc/selinux/config | grep -v '#' | awk -F '=' '{print $2}')"
echo "    03.iptables: $(chkconfig --list | grep iptables | awk '{print $5, $7}')"
echo "    04.ip6tables: $(chkconfig --list | grep ip6tables | awk '{print $5, $7}')"
echo ""
echo "    05.LANG: $(grep 'export LANG' /etc/profile | awk -F '=' '{print $2}')"
echo "    06.LC_ALL: $(grep 'export LC_ALL' /etc/profile | awk -F '=' '{print $2}')"
echo ""
echo "    07.Vim's line nu: $(grep 'set nu' /etc/profile 2>&1 > /dev/null && echo 'yes')"
echo "    08.SSH UseDNS: $(grep 'UseDNS' /etc/ssh/sshd_config | awk '{print $2}')"
echo ""
echo "    09.Net interface: $(ifconfig -a | grep 'Link ' | awk '{print $1}' | xargs | sed 's/ /, /g')"
echo "    10.Interface: $(ifconfig -a | head -n 1 | awk '{print $1}')"
echo "    11.IP: $(ifconfig eth0 | grep 'inet addr' | sed 's/Bcast.*//g' | awk -F ':' '{print $2}')"
echo "    12.Mask: $(ifconfig eth0 | grep 'inet addr' | sed 's/.*Mask://g')"
echo "    13.Gateway: $(grep -i 'GATEWAY' /etc/sysconfig/network-scripts/ifcfg-eth0 | awk -F '=' '{print $2}')"
echo ""
echo "    14.Default GW: $(route -n | grep 'UG' | awk '{print $2", "$8}')"
echo "    15.Internet: $(ping -w 2000 -c 2 www.baidu.com 2>&1 > /dev/null && echo 'online' || echo 'offline')"
echo ""
echo "    16.Current time: $(date), synced from NTPServer ${NtpServer}, if your Internet status is 'offline',
                     please use cmd "ntpdate $NtpServer" to update your date after online or modify it manually.                                                                                                         "
echo "    17.Current user: $(whoami)"
echo ""
echo "    Note: Some configs must take effect after reboot!"
echo ""
echo ""


#03.Yum repository config 
ISO_path="/data/isos/CentOS"
ISO_file="CentOS-6.4-x86_64.iso"
ISO_mount_path="/mnt/CentOS"

echo "[Task 02 of $tasknums]"
echo "Configuring the yum repository:"

[ -e $ISO_path ] || mkdir -p $ISO_path
[ -e $ISO_mount_path ] || mkdir -p $ISO_mount_path

[ -e $ISO_path/$ISO_file ] || { echo "Notice: your CentOS image file is not exists, please upload the file to $ISO_path first, and rename it to $ISO_file" && exit; } 

umount /mnt/CentOS > /dev/null 2>&1
mount -o loop $ISO_path/$ISO_file $ISO_mount_path

#[ -e /etc/yum.repos.d/backups ] || mkdir -p /etc/yum.repos.d/backups
cp -n /etc/yum.repos.d/CentOS-Media.repo    /etc/yum.repos.d/CentOS_Local.repo > /dev/null 2>&1

sed -i -e 's/c6-media/CentOS_Local/g' \
       -e "/releasever/a baseurl=file://$ISO_mount_path/" \
       -e 's/\(baseurl=file:\/\/\/media\/CentOS\/\)/#\1/g' \
       -e 's/\(        file:\/\/\/media\/cdrom\/\)/#\1/g' \
       -e 's/\(        file:\/\/\/media\/cdrecorder\/\)/#\1/g' \
       -e 's/gpgcheck=1/gpgcheck=0/g' \
       -e 's/enabled=0/enabled=1/g' \
       /etc/yum.repos.d/CentOS_Local.repo

[ 5 -eq $(grep 'enabled' /etc/yum.repos.d/CentOS-Base.repo | wc -l 2>&1) ]
[ $? -gt 0 ] && { sed -i -e '17a enabled=1' \
                         -e '25a enabled=1' \
                         -e '33a enabled=1' \
                         /etc/yum.repos.d/CentOS-Base.repo; \
                  sed -i -e 's/gpgcheck=1/gpgcheck=0/g' \
                         -e 's/enabled=0/enabled=1/g' \
                         /etc/yum.repos.d/CentOS-Base.repo; } || \
                sed -i -e 's/gpgcheck=1/gpgcheck=0/g' \
                       -e 's/enabled=0/enabled=1/g' \
                       /etc/yum.repos.d/CentOS-Base.repo

sed -i -e 's/gpgcheck=1/gpgcheck=0/g' \
       -e 's/enabled=0/enabled=1/g' \
       /etc/yum.repos.d/CentOS-Debuginfo.repo

#disable this repo, use CentOS-Local.repo
sed -i -e 's/gpgcheck=1/gpgcheck=0/g' \
       -e 's/enabled=1/enabled=0/g' \
       /etc/yum.repos.d/CentOS-Media.repo

sed -i -e 's/gpgcheck=1/gpgcheck=0/g' \
       -e 's/enabled=0/enabled=1/g' \
       /etc/yum.repos.d/CentOS-Vault.repo

echo ""


#04.Yum repo config report
yum repolist 2>&1 | grep -v 'Load'

echo ""
echo "Congratulations: the local yum repo has configed successfully, you can use 'yum install XXX' to install package XXX."
echo ""
echo ""


#05.Install general develop environment
echo "[Task 03 of $tasknums]"
echo "To install some general develop environment tools:"
echo ""

echo "    01.X Window System"
echo "    02.Desktop"
echo "    03.KDE Desktop"
echo "    04.Development tools"
echo "    05.Eclipse"
echo "    06.GCC, G++"
echo ""

echo "01.Installing 'X Window System', please wait..."
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "X Window System" > /dev/null 2>&1
wait
echo "The task has done."
echo ""

echo "02.Installing 'Desktop', please wait..."
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "Desktop" > /dev/null 2>&1
wait
echo "The task has done."
echo ""

echo "03.Installing 'KDE Desktop', please wait..."
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "KDE Desktop" > /dev/null 2>&1
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "KDE Desktop" > /dev/null 2>&1
wait
echo "The task has done."
echo ""

echo "04.Installing 'Development tools', please wait..."
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "Development tools" > /dev/null 2>&1
wait
echo "The task has done."
echo ""

echo "05.Installing 'Eclipse', please wait..."
yum -y groupinstall --disablerepo=* --enablerepo=CentOS_Local "Eclipse" > /dev/null 2>&1
wait
echo "The task has done."
echo ""

echo "06.Installing 'GCC, G++ and so on', please wait..."
yum -y install --disablerepo=* --enablerepo=CentOS_Local "gcc-c++ make kernel kernel-devel kernel-headers kernel-firmware" > /dev/null 2>&1
echo "The task has done."
wait

echo ""
echo "Selected packages has been installed successfully."
echo ""
echo ""


echo "[Task 04 of $tasknums]"
echo "Configuring GUI access:"

GUI_KDE=1
GUI_GNOME=1

default_gui=kde
#default_gui=gnome

[ -e /etc/sysconfig/desktop ] && echo "" > /etc/sysconfig/desktop || touch /etc/sysconfig/desktop

if [ $GUI_KDE -eq 1 ]
then
    echo "DESKTOP=KDE" > /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=KDE" >> /etc/sysconfig/desktop

    sed -i 's/Enable=false/Enable=true/g' /etc/kde/kdm/kdmrc
    sed -i 's/Xaccess=\/etc\/X11\/xdm\/Xaccess/Xaccess=\/etc\/kde\/kdm\/Xaccess/g' /etc/kde/kdm/kdmrc

    sed -i '/any host/ s/#\*/\*/g' /etc/kde/kdm/Xaccess  
fi

if [ $GUI_GNOME -eq 1 ]
then
    echo "DESKTOP=GNOME" >> /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=GNOME" >> /etc/sysconfig/desktop

    grep "AllowRemoteRoot" > /dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '5a AllowRemoteRoot=yes' /etc/gdm/custom.conf

    grep "DisallowTCP" >/dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '6a DisallowTCP=no' /etc/gdm/custom.conf
    
    grep "Enable=true" >/dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '9a Enable=true' /etc/gdm/custom.conf
fi

if [ $default_gui = "kde" ]
then
    echo "DESKTOP=KDE" > /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=KDE" >> /etc/sysconfig/desktop
else
    echo "DESKTOP=GNOME" > /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=GNOME" >> /etc/sysconfig/desktop
fi

echo ""
echo "    01.GUI_Default_Type: $([ $default_gui = 'kde' ] && echo 'KDE' || echo 'GNOME')"
echo "    02.Access point IP: $IP"
echo "    03.Access point port: 177"
echo "    04.Access protocol: XDMCP"
echo "    05.Recommanded tool: suite 'XManager Enterprise'"
echo ""

echo "    Note: if you want to access GUI Server(Linux) from Windows, please add the firewall rule income about port 6000 to Windows
          and 177(GUI Server Listening) income to GUI Server(Linux)."

echo ""

echo "Congratulations: the GUI Server has been configed successfully."


