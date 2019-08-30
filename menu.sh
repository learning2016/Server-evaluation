#!/bin/sh
#Shell menu
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
pwd=/tmp

#初始化、安装跑分
function Test_environment_initialization() {
      dir=$(pwd)
      cd /tmp/
      yum -y install gcc automake autoconf libtool make perl-Time-HiRes perl sysbench libaio-devel wget screen
      wget https://download.laobuluo.com/tools/UnixBench5.1.3.tgz
      tar -zxvf UnixBench5.1.3.tgz
      cd UnixBench
      make

#安装fio
      cd /tmp
      wget http://brick.kernel.dk/snaps/fio-2.7.tar.gz
      tar zxvf fio-2.7.tar.gz
      cd fio-2.7
      ./configure
      make && make install

#安装获取服务器软件、硬件信息的脚本。
      if  [ ! -e '/tmp/systeminfo.sh' ]; then
          echo "Installing systeminfo.sh......"
          dir=$(pwd)
          cd /tmp/
          wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/systeminfo.sh > /dev/null 2>&1
          cd $dir     
          chmod a+rx /tmp/systeminfo.sh
      fi
#安装网络延迟的脚本。
      if  [ ! -e '/tmp/AWS-ping.py' ]; then
          echo "Installing AWS-ping.py......"
          dir=$(pwd)
          cd /tmp/
          wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/AWS-ping.py > /dev/null 2>&1
          cd $dir
          chmod a+rx /tmp/AWS-ping.py
      fi
}

#获取服务器软硬件信息
function Get_hardware_and_software_information () {
    /usr/bin/bash /tmp/systeminfo.sh
}

#获取服务器网络信息
function Network_delay_test () {
    python /tmp/AWS-ping.py
}

#测试CPU
function The_CPU_test () {
    #printf "正在测试，请耐心等待"
    sysbench cpu --cpu-max-prime=20000 --threads=2 run > /tmp/cpu.log 2>&1
    name13=CPU计算素数所需要时间
    name14=$(cat /tmp/cpu.log |grep "total time:")
    str7=$name13$name14
    echo $str7
}

#测试内存
function The_memory_test () {
    #printf "正在测试，请耐心等待"
    sysbench --test=memory --memory-block-size=8K --memory-total-size=4G --num-threads=2 run  > /tmp/memory.log 2>&1
    name15=内存读写性能
    name16=$(cat /tmp/memory.log |grep "transferred")
    str8=$name15$name16
    echo $str8

}

#测试磁盘IO
function Disk_test () {

      fdisk -l >> /tmp/fdisk.log
      if grep -q xvdb /tmp/fdisk.log ; then
        #随机读
        fio -filename=/dev/xvdb -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randread.log 2>&1
        #顺序读
#        fio -filename=/dev/xvdb -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/read.log 2>&1
        #随机写
        fio -filename=/dev/xvdb -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randwrite.log 2>&1
        #顺序写
#        fio -filename=/dev/xvdb -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/write.log 2>&1
        #混合随机读写
        fio -filename=/dev/xvdb -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop > /tmp/randrw.log 2>&1
    elif grep -q sdb /tmp/fdisk.log ; then
        #随机读
        fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randread.log 2>&1
        #顺序读
#        fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/read.log 2>&1
        #随机写
        fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randwrite.log 2>&1
        #顺序写
#        fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/write.log 2>&1
        #混合随机读写
        fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop > /tmp/randrw.log 2>&1
    else
        #随机读
        fio -filename=/dev/vdb -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randread.log 2>&1
        #顺序读
#        fio -filename=/dev/vdb -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/read.log 2>&1
        #随机写
        fio -filename=/dev/vdb -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/randwrite.log 2>&1
        #顺序写
#        fio -filename=/dev/vdb -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=1000 -group_reporting -name=mytest > /tmp/write.log 2>&1
        #混合随机读写
        fio -filename=/dev/vdb -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=20G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop > /tmp/randrw.log 2>&1
        fi

        name1=随机读
        name2=$(cat /tmp/randread.log |grep iops)
        str1=$name1$name2
        echo $str1
        
#        name3=顺序读
#        name4=$(cat /tmp/read.log |grep iops)
#        str2=$name3$name4
#        echo $str2
        
        name5=随机写
        name6=$(cat /tmp/randwrite.log |grep iops)
        str3=$name5$name6
        echo $str3
        
#        name7=顺序写
#        name8=$(cat /tmp/write.log |grep iops)
#        str4=$name7$name8
#        echo $str4
        
        name9=混合随机读写
        name10=$(cat /tmp/randrw.log |grep iops)
        str5=$name9$name10
        echo $str5

}

#服务器跑分
function Grading_test () {
    cd /tmp/UnixBench
    ./Run > /tmp/unixbench.log 2>&1
    name17=评分
    name18=$(cat /tmp/unixbench.log |grep "System Benchmarks Index Score")
    str9=$name17$name18
    echo $str9
}

#一键测试
function A_key_test () {
    Test_environment_initialization
    printf '%80s\n' | tr ' ' -
    Get_hardware_and_software_information
    printf '%80s\n' | tr ' ' -
    Network_delay_test
    printf '%80s\n' | tr ' ' -
    The_CPU_test
    printf '%80s\n' | tr ' ' -
    The_memory_test
    printf '%80s\n' | tr ' ' -
    Disk_test
    printf '%80s\n' | tr ' ' -
    Grading_test
    printf '%80s\n' | tr ' ' -
}

function menu ()
{
    cat << EOF
----------------------------------------
|***************菜单主页***************|
----------------------------------------
`echo -e "\033[33m 1)测试环境初始化\033[0m"`
`echo -e "\033[33m 2)获取软硬件信息\033[0m"`
`echo -e "\033[33m 3)网络延迟测试\033[0m"`
`echo -e "\033[33m 4)CPU测试\033[0m"`
`echo -e "\033[33m 5)内存测试\033[0m"`
`echo -e "\033[33m 6)磁盘测试\033[0m"`
`echo -e "\033[33m 7)评分测试\033[0m"`
`echo -e "\033[33m 8)一键测试\033[0m"`
`echo -e "\033[33m 9)退出\033[0m"`
EOF
read -p "请输入对应产品的数字：" num1
case $num1 in
    1)
      Test_environment_initialization
      menu
      ;;
#获取服务器软件、硬件信息。
    2)
      Get_hardware_and_software_information
      menu
      ;;
#获取网络延迟。
    3)
      Network_delay_test
      menu
      ;;
#测试cpu。
    4)
      The_CPU_test
      menu
      ;;
#测试内存。
    5)
      The_memory_test
      menu
      ;;
#测试磁盘IO。
    6)
      Disk_test
      menu
      ;;
#服务器性能跑分。
    7)
      Grading_test
      menu
      ;;
#以上功能，一键完成。
    8)
      A_key_test
      menu
      ;;
    9)
      exit 0
esac
}
menu
