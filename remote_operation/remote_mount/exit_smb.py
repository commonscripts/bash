#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os,sys


remote_ip       = sys.argv[1]
remote_port     = sys.argv[2]
#remote_password = sys.argv[3]

#local_path      = sys.argv[4]
#remote_path     = sys.argv[5]

#local_ip        = sys.argv[6]
#local_password  = sys.argv[7]

#remote_ip       = "222.222.222.222" 
#remote_port     = "22222" 
remote_password = "this_is_remote_passwd" 
local_path      = "//localhost/root/version"
remote_path     = "/mnt/hjf/version"
local_ip        = "192.168.145.202"
local_password  = "this_is_local_passwd"

#umount_command   = "[ -e /mnt/hjf/version ] || mkdir /mnt/hjf/version && mount -t cifs //localhost/root/version /mnt/hjf/version -o rw,username=root,password=this_is_local_passwd"
#umount_command   = "[ " + "-e" + " " + remote_path + " ]" + " " + "||" + " " + "mkdir" + " " + remote_path + " " + "&&" + " " + "mount -t cifs" + " " + local_path + " " + remote_path + " " + "-o rw,username=root,password=" + local_password
umount_command   = "umount" + " " + remote_path + " && " "netstat -atunp" + " | " + "grep 127.0.0.1:445" + " | " + "grep sshd" + " | " + "awk -F" + " " + "'/'" + " " + "'{print $1}'" + " | " + "awk '{print $7}'" + " | " + "xargs -n 1 kill -9"
#remote_command  = "ssh -fCN -R 222.222.222.222:445:192.168.145.202:445 root@222.222.222.222 -p 22222"
remote_command  = "ssh -fC -R" + " " + remote_ip + ":" + "445" + ":" + local_ip + ":" + "445" + " " + "root@" + remote_ip + " " + "-p" + " " + remote_port + " " + '"' + umount_command + '"' 


def exit():
    os.system(remote_command)    
    return True 

if __name__ == '__main__':
    if exit():
        print u'\033[1;32;47mSuccessfully!\033[0m'

    else:
        print u'\033[1;31;47mFailed!\033[0m'


