#!/bin/bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#   
#   email : smalldegree@163.com  
#
#   date  : 2015-12-14 14:23:00
#
#   description: 
#           1)This script is used to config system gui access. 
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#   history:
#           1)Created by He Jianfei on 2015-12-17 11:53:00.
#
#---------------------------------------------------------------------------


function usage()
{
cat <<END 2>&1
usage: ${0##*/} [kde | gnome | both | status]
       kde     --   config kde only
       gnome   --   config gnome only
       both    --   config both kde and gnome
       status  --   show gui_config status

notice: 01)after run this script with para 'both', default gui is 'KDE';
        02)continue above, if want to switch default gui, please modify manually the file '/etc/sysconfig/desktop' like

        DESKTOP=KDE
        DISPLAYMANAGER=KDE
END
}

function config_kde()
{
    echo "DESKTOP=KDE" > /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=KDE" >> /etc/sysconfig/desktop

    sed -i 's/Enable=false/Enable=true/g' /etc/kde/kdm/kdmrc
    sed -i 's/Xaccess=\/etc\/X11\/xdm\/Xaccess/Xaccess=\/etc\/kde\/kdm\/Xaccess/g' /etc/kde/kdm/kdmrc

    sed -i '/any host/ s/#\*/\*/g' /etc/kde/kdm/Xaccess  
}

function config_gnome()
{
    echo "DESKTOP=GNOME" > /etc/sysconfig/desktop
    echo "DISPLAYMANAGER=GNOME" >> /etc/sysconfig/desktop

    grep "AllowRemoteRoot" > /dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '5a AllowRemoteRoot=yes' /etc/gdm/custom.conf

    grep "DisallowTCP" >/dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '6a DisallowTCP=no' /etc/gdm/custom.conf
    
    grep "Enable=true" >/dev/null 2>&1 /etc/gdm/custom.conf
    [ $? -gt 0 ] && sed -i '9a Enable=true' /etc/gdm/custom.conf
    
    return 0
}

function config_status()
{
    echo "System gui config as follow:"
    echo ""
    echo "    01.GUI_Default_Type: $(grep 'DESKTOP' /etc/sysconfig/desktop | awk -F '=' '{print $2}')"
    echo "    02.Access point IP: $(ifconfig eth0 | grep 'inet addr' | sed 's/Bcast.*//g' | awk -F ':' '{print $2}')"
    echo "    03.Access point port: 177"
    echo "    04.Access protocol: XDMCP"
    echo "    05.Recommanded tool: suite 'XManager Enterprise'"
    echo ""
    
    echo "    Note: if you want to access GUI Server(Linux) from Windows, please add the firewall rule income about port 6000 to Windows
          and 177(GUI Server Listening) income to GUI Server(Linux)."
    
    echo ""
    
    echo "Congratulations: the GUI Server has been configed successfully."
}

function pre_check()
{
    yum grouplist 'X Window System' | grep 'Installed' > /dev/null 2>&1
    [ $? -gt 0 ] && echo "'X Window System' has not been installed, please use cmd 'yum groupinstall "X Window System" to install it first.'" && exit

    if [ $gui_type = 'kde' ]
    then
        yum grouplist 'KDE Desktop' | grep 'Installed' > /dev/null 2>&1
        [ $? -gt 0 ] && echo "'KDE Desktop' has not been installed, please use cmd 'yum groupinstall "KDE Desktop" to install it first.'" && exit
    elif [ $gui_type = 'gnome' ]
    then
        yum grouplist 'Desktop' | grep 'Installed' > /dev/null 2>&1
        [ $? -gt 0 ] && echo "'Desktop' has not been installed, please use cmd 'yum groupinstall "Desktop" to install it first.'" && exit
    elif [ $gui_type = 'both' ]
    then
        yum grouplist 'KDE Desktop' | grep 'Installed' > /dev/null 2>&1
        [ $? -gt 0 ] && echo "'KDE Desktop' has not been installed, please use cmd 'yum groupinstall "KDE Desktop" to install it first.'"

        yum grouplist 'Desktop' | grep 'Installed' > /dev/null 2>&1
        [ $? -gt 0 ] && echo "'Desktop' has not been installed, please use cmd 'yum groupinstall "Desktop" to install it first.'" && exit
    elif [ $gui_type = 'status' ]
    then
        [ -e /etc/sysconfig/desktop ] || \
            { echo "Please check whether 'X Window System' or 'KDE Desktop' or 'Desktop' has been installed using cmd 'yum grouplist 'X Window System'' and so on."; echo ""; echo "Note: if you can confirm above, you can ignore this."; exit; }
    fi
}

function default_gui()
{
    if [ $gui_type = 'kde' ]
    then
        echo "DESKTOP=KDE" > /etc/sysconfig/desktop
        echo "DISPLAYMANAGER=KDE" >> /etc/sysconfig/desktop
    elif [ $gui_type = 'gnome' ]
    then
        echo "DESKTOP=GNOME" > /etc/sysconfig/desktop
        echo "DISPLAYMANAGER=GNOME" >> /etc/sysconfig/desktop
    elif [ $gui_type = 'both' ]    
    then
        echo "DESKTOP=KDE" > /etc/sysconfig/desktop
        echo "DISPLAYMANAGER=KDE" >> /etc/sysconfig/desktop
    fi
}


[ $# -eq 0 ] && usage && exit


gui_type=$1

pre_check

if [ $gui_type = 'kde' ]
then
    config_kde && config_status && exit
elif [ $gui_type = 'gnome' ]
then
    config_gnome && config_status && exit
elif [ $gui_type = 'both' ]
then
    config_kde && config_gnome && default_gui && config_status && exit
elif [ $gui_type = 'status' ]
then
    config_status && exit
else
    echo "Parameter error: para must be 'kde' or 'gnome' or 'both' or 'status'."
    exit
fi


