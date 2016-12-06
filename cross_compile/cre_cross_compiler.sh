#!/bin/bash

#---------------------------------------------------------------------------
#
#   author: He Jianfei
#
#   email : smalldegree@163.com  
#
#   date  : 2015-12-23 10:30:00
#
#   description: 
#           1)This script is used to build ARM cross_compile environment.
#
#           2)This script is for CentOS 6.4 x86_64, and installation
#             mode is "Basic Server" with 607 packages.
#
#   history:
#           1)Created by He Jianfei on 2015-12-23 10:30:00.
#
#           2)Set the env handler to the front of check dependency, on 
#             2015-12-29 12:45:00.
#---------------------------------------------------------------------------


#Steps of creating cross_compile environment based on ARM arch on CentOS 6.4 x86_64.
#01.prepare resources and check dependency.
#02.init environment.
#03.compile binutils.
#04.compile gcc first without C lib support.
#05.generate kernel headers.
#06.compile C lib for ARM arch, such as glibc.
#07.compile gcc second with C lib support.
#08.check toolchains config.
#09.test HelloWorld program.
#10.report the config.


host_os=$(cat /etc/issue | head -n 1)
host_kernel=$(uname -r)
host_cpu=$(cat /proc/cpuinfo | grep 'model name' | awk -F ': ' '{print $2}')

rc_binutils=binutils-2.25.tar.gz

rc_gcc=gcc-4.4.7.tar.gz
rc_glibc=glibc-2.11.tar.gz
rc_glibc_ports=glibc-ports-2.11.tar.gz

rc_gmp=gmp-4.2.tar.gz
rc_mpfr=mpfr-2.4.0.tar.gz

rc_linux_kernel=linux-2.6.32.27.tar.gz    

#ftp://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz
#ftp://ftp.gnu.org/gnu/gcc/gcc-4.4.7/gcc-4.4.7.tar.gz
#ftp://ftp.gnu.org/gnu/glibc/glibc-2.11.tar.gz
#ftp://ftp.gnu.org/gnu/glibc/glibc-ports-2.11.tar.gz
#ftp://ftp.gnu.org/gnu/gmp/gmp-4.2.tar.gz
#ftp://ftp.gnu.org/gnu/mpfr/mpfr-2.4.0.tar.gz
#ftp://ftp.kernel.org/pub/linux/kernel/v2.6/linux-2.6.32.27.tar.gz


echo 'export    TOP_DIR=/root/cross_compile' > /tmp/env.sh
echo 'export    PRJROOT=$TOP_DIR/embeded_toolchains' >> /tmp/env.sh
echo 'export    TARGET=arm-linux' >> /tmp/env.sh

echo 'export    PREFIX=$PRJROOT/tool_chain' >> /tmp/env.sh
echo 'export    TARGET_PREFIX=$PREFIX/$TARGET' >> /tmp/env.sh

echo 'export    PATH=$PATH:$PREFIX/bin' >> /tmp/env.sh


echo $PATH | grep tool_chain 
[ $? -gt 0 ] && source /tmp/env.sh


#01.prepare resources and check dependency.
function precheck()
{
    rc=0
    
    echo "Checking packages dependencies:"
    for i in bash grep sed awk perl gcc glibc make coreutils diffutils gettext texinfo
    do
        rpm -qa | grep $i > /dev/null 2>&1
        rc=$?

        echo "    Checking whether has installed package ${i}: $([ $rc -eq 0 ] && echo yes || echo no)"
        [ ! $rc -eq 0 ] && { echo "Please install package ${i} first." && exit; }
    done

    echo -e "\033[32mDependency packages have been installed already.\033[0m"
}


#02.init environment.
function init_env()
{
    mkdir $TOP_DIR > /dev/null 2>&1
    mkdir $PRJROOT > /dev/null 2>&1
   
    mkdir $PRJROOT/setup_dir > /dev/null 2>&1
    mkdir $PRJROOT/src_dir > /dev/null 2>&1
    
    mkdir $PRJROOT/build_dir > /dev/null 2>&1
    mkdir $PRJROOT/build_dir/build_binutils > /dev/null 2>&1
    mkdir $PRJROOT/build_dir/build_gcc > /dev/null 2>&1
    mkdir $PRJROOT/build_dir/build_glibc > /dev/null 2>&1
    
    mkdir $PRJROOT/kernel > /dev/null 2>&1
    
    mkdir $PRJROOT/tool_chain > /dev/null 2>&1

    mkdir $PRJROOT/doc > /dev/null 2>&1
    mkdir $PRJROOT/program > /dev/null 2>&1
    

    echo ""    
    echo "Checking the files' existence:" 
    for i in $rc_binutils $rc_gcc $rc_glibc $rc_glibc_ports $rc_gmp $rc_mpfr
    do
        if [ -f ./$i ]
        then
            cp -an ./$i $PRJROOT/setup_dir/ && echo "    File ${i}: exists"
        elif [ -f /tmp/$i ]
        then
            cp -an /tmp/$i $PRJROOT/setup_dir/ && echo "    File ${i}: exists"
        elif [ -f ~/$i ]
        then
            cp -an ~/$i $PRJROOT/setup_dir/ && echo "    File ${i}: exists"
        else
            echo "    File ${i}: Not found in current dir or /tmp/ or ~/" && exit
        fi
    done

    if [ -f ./$rc_linux_kernel ]
    then
        cp -an ./$rc_linux_kernel $PRJROOT/kernel/ && echo "    File ${rc_linux_kernel}: exists"
    elif [ -f /tmp/$rc_linux_kernel ]
    then
        cp -an /tmp/$rc_linux_kernel $PRJROOT/kernel/ && echo "    File ${rc_linux_kernel}: exists"
    elif [ -f ~/$rc_linux_kernel ]
    then
        cp -an ~/$rc_linux_kernel $PRJROOT/kernel/ && echo "    File ${rc_linux_kernel}: exists"
    else
        echo "    File ${rc_linux_kernel}: Not found in current dir or /tmp/ or ~/" && exit
    fi

    echo ""
    for i in $rc_binutils $rc_gcc $rc_glibc $rc_glibc_ports $rc_gmp $rc_mpfr
    do
        echo "    Unziping the file $i ..."
        tar -zxvf $PRJROOT/setup_dir/$i -C $PRJROOT/src_dir/ > /dev/null
    done

    echo "    Unziping the file $rc_linux_kernel ..."
    tar -zxvf $PRJROOT/kernel/$rc_linux_kernel -C $PRJROOT/kernel/ > /dev/null
    
    cp -an /tmp/env.sh   $PRJROOT/doc/

    echo -e "\033[32mInit environment successfully.\033[0m"
}


#03.compile binutils.
function compile_binutils()
{
    echo ""
    echo "Compiling binutils: "

    cd $PRJROOT/build_dir/build_binutils
    sh ../../src_dir/${rc_binutils%%.tar.gz}/configure --prefix=$PREFIX --target=$TARGET

    make && make install

    [ $? -gt 0 ] && echo -e "\033[32mCompiled binutils successfully.\033[0m"
}


#04.compile gcc first without C lib support.
function compile_gcc_without_c_lib()
{
    echo ""
    echo "Compiling gcc first: "

    cp -an $PRJROOT/src_dir/${rc_gmp%%.tar.gz}       $PRJROOT/src_dir/${rc_gcc%%.tar.gz}/gmp
    cp -an $PRJROOT/src_dir/${rc_mpfr%%.tar.gz}      $PRJROOT/src_dir/${rc_gcc%%.tar.gz}/mpfr

    cd $PRJROOT/build_dir/build_gcc
    sed -i 's/TARGET_LIBGCC2_CFLAGS.*/TARGET_LIBGCC2_CFLAGS = -fomit-frame-pointer -fPIC -Dinhibit_libc -D_gthr_posix.h/g' ../../src_dir/${rc_gcc%%.tar.gz}/gcc/config/t-linux

    sh ../../src_dir/${rc_gcc%%.tar.gz}/configure --prefix=$PREFIX \
                                                  --target=$TARGET \
                                                  --without-headers \
                                                  --enable-languages=c,c++ \
                                                  --disable-shared \
                                                  --disable-threads \
                                                  --disable-decimal-float \
                                                  --disable-libmudflap \
                                                  --disable-libssp

    make all-gcc
    make install-gcc

    make all-target-libgcc
    make install-target-libgcc

    str_temp=${rc_gcc%%.tar.gz}
    cd $PREFIX/lib/gcc/arm-linux/${str_temp#gcc-}
    ln -s libgcc.a libgcc_eh.a > /dev/null 2>&1
 
    [ $? -gt 0 ] && echo -e "\033[32mCompiled gcc without c lib support successfully.\033[0m"
}


#05.generate kernel headers.
function generate_kernel_headers()
{
    echo ""
    echo "Generating kernel headers: "

    cd $PRJROOT/kernel/${rc_linux_kernel%%.tar.gz}

    grep 'HOSTLOADLIBES_mconf' scripts/kconfig/Makefile
    [ $? -gt 0 ] && sed -i '202a HOSTLOADLIBES_mconf     = -ltinfo' scripts/kconfig/Makefile

    #make ARCH=arm CROSS_COMPILE=arm-linux- menuconfig    
    #you can use a common file ".config", so you needn't to config kernel.
    make ARCH=arm CROSS_COMPILE=arm-linux- 

    mkdir -p $TARGET_PREFIX/include > /dev/null 2>&1
    cp -an $PRJROOT/kernel/${rc_linux_kernel%%.tar.gz}/include/linux              $TARGET_PREFIX/include/
    cp -an $PRJROOT/kernel/${rc_linux_kernel%%.tar.gz}/include/asm-arm            $TARGET_PREFIX/include/
    cp -an $PRJROOT/kernel/${rc_linux_kernel%%.tar.gz}/include/asm-generic        $TARGET_PREFIX/include/
    
    cp -an $PRJROOT/kernel/${rc_linux_kernel%%.tar.gz}/arch/arm/include/asm       $TARGET_PREFIX/include/

    [ $? -gt 0 ] && echo -e "\033[32mGenerated kernel headers successfully.\033[0m"
}


#06.compile C lib for ARM arch, such as glibc.
function compile_c_lib()
{
    echo ""
    echo "Compiling glibc: "

    cp -an $PRJROOT/src_dir/${rc_glibc_ports%%.tar.gz}      $PRJROOT/src_dir/${rc_glibc%%.tar.gz}/ports

    cd $PRJROOT/build_dir/build_glibc
    CC=arm-linux-gcc AR=arm-linux-ar RANLIB=arm-linux-ranlib
    sh ../../src_dir/${rc_glibc%%.tar.gz}/configure --prefix=$PREFIX/$TARGET \
                                                    --host=arm-linux \
                                                    --enable-add-ons \
                                                    --with-headers=$PREFIX/$TARGET/include \
                                                    --with-tls \
                                                    --disable-profile \
                                                    libc_cv_forced_unwind=yes \
                                                    libc_cv_c_cleanup=yes \
                                                    libc_cv_arm_tls=yes

    make
    make install

    [ $? -gt 0 ] && echo -e "\033[32mCompiled glibc successfully.\033[0m"
}


#07.compile gcc second with C lib support.
function compile_gcc_with_c_lib()
{
    echo ""
    echo "Compiling gcc second: "

    cd $PRJROOT/build_dir/build_gcc
    sed -i 's/TARGET_LIBGCC2_CFLAGS.*/TARGET_LIBGCC2_CFLAGS = -fomit-frame-pointer -fPIC/g' ../../src_dir/${rc_gcc%%.tar.gz}/gcc/config/t-linux
    
    sh ../../src_dir/${rc_gcc%%.tar.gz}/configure --prefix=$PREFIX \
                                                  --target=$TARGET \
                                                  --enable-shared \
                                                  --enable-languages=c,c++

    make all-gcc
    make install-gcc

    make all-target-libgcc
    make install-target-libgcc
 
    [ $? -gt 0 ] && echo -e "\033[32mCompiled gcc with c lib support successfully.\033[0m"
}


#08.check toolchains config.
function postcheck()
{
    echo ""
    echo "Checking the env and files after all configs:"
    
    ls $PREFIX/bin/

    which arm-linux-gcc > /dev/null 2>&1
    [ $? -eq 0 ] && echo "" && echo -e "\033[32mCompiled gcc with c lib support can work successfully.\033[0m"
}


#09.test HelloWorld program.
function test_hello_world()
{
    echo '#include <stdio.h>' > $PRJROOT/program/helloworld.c
    echo '' >> $PRJROOT/program/helloworld.c
    echo 'int main(int argc, char * argv[])' >> $PRJROOT/program/helloworld.c
    echo '{' >> $PRJROOT/program/helloworld.c
    echo '    printf("If you can see this message, Congratulations, your cross_compile has worked on arm-linux platform./n");' >> $PRJROOT/program/helloworld.c
    echo '' >> $PRJROOT/program/helloworld.c    
    echo '    return 0;' >> $PRJROOT/program/helloworld.c
    echo '}' >> $PRJROOT/program/helloworld.c

    cd $PRJROOT/program
    arm-linux-gcc -static -I $PREFIX/include -o helloworld helloworld.c
    echo "" && echo 'arm-linux-size helloworld'
    arm-linux-size helloworld && echo "" && [ $? -eq 0 ] && echo -e "\033[32mCongratulations, your cross_compile has worked now.\033[0m" || { echo ""; echo "Notice: there are some errors."; }
}


#10.report the config.
function report_config()
{
echo ""
cat <<END 2>&1
Configs as follow:

    01.the script is used to build ARM cross_compile env based on CentOS 6.4 x86_64.

    02.the main used resources as follow: default, you can use others
        *binutils: ${rc_binutils} 
        
        *gcc: ${rc_gcc}
        *glibc: ${rc_glibc}
        *glibc_ports: ${rc_glibc_ports}

        *gmp: ${rc_gmp}
        *mpfr: ${rc_mpfr}

        *linux_kernel: ${rc_linux_kernel}

    03.the env as follow:
        TOP_DIR: ${TOP_DIR}
        PRJROOT: ${PRJROOT}
        TARGET : ${TARGET}
        
        PREFIX : ${PREFIX}
        TARGET_PREFIX: ${TARGET_PREFIX}

        PATH   : ${PATH}
    
    04.the host info:
        host_os:     ${host_os}
        host_kernel: ${host_kernel}
        host_cpu:    ${host_cpu}

END
}


precheck && sleep 2

init_env && sleep 2

compile_binutils && sleep 2

compile_gcc_without_c_lib && sleep 2

generate_kernel_headers && sleep 2

compile_c_lib && sleep 2

compile_gcc_with_c_lib && sleep 2

postcheck && sleep 2

test_hello_world && sleep 2

report_config


