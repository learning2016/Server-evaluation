#!/bin/sh
#Shell menu
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
pwd=/tmp

#初始化、安装跑分
function Test_environment_initialization() {
      dir=$(pwd)
      cd $pwd
      yum -y install gcc automake autoconf libtool make perl-Time-HiRes perl wget vim screen
      cd $pwd
      wget https://github.com/qcsuper/byte-unixbench/releases/download/v5.1.4/UnixBench-5.1.4.tar.gz
      tar -zxvf UnixBench-5.1.4.tar.gz && rm -f UnixBench-5.1.4.tar.gz
      cd UnixBench
      make
      cd $pwd
      wget https://codeload.github.com/akopytov/sysbench/tar.gz/1.0.17
      tar -zxvf 1.0.17 -C /usr/local/
      cd /usr/local/sysbench-1.0.17
      ./autogen.sh
      ./configure --without-mysql
      make -j
      make install

#安装获取服务器软件、硬件信息的脚本。
      if  [ ! -e '/tmp/systeminfo.sh' ]; then
          echo "Installing systeminfo.sh......"
          dir=$(pwd)
          cd $pwd
          wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/systeminfo.sh > /dev/null 2>&1
          cd $pwd     
          chmod a+rx /tmp/systeminfo.sh
      fi
#安装网络延迟的脚本。
      if  [ ! -e '/tmp/AWS-ping.py' ]; then
          echo "Installing AWS-ping.py......"
          dir=$(pwd)
          cd $pwd
          wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/AWS-ping.py > /dev/null 2>&1
          cd $pwd
          chmod a+rx /tmp/AWS-ping.py
      fi
}

function Get_hardware_and_software_information () {
       /usr/bin/bash /tmp/systeminfo.sh
}


function Network_delay_test () {
       python /tmp/AWS-ping.py
}


function The_CPU_test () {
      #printf "正在测试，请耐心等待"
      /usr/local/sysbench-1.0.17/src/sysbench cpu --cpu-max-prime=20000 --threads=2 run > /tmp/cpu.log 2>&1
      #clear
      name13=测试计算素数所需要时间
      name14=$(cat /tmp/cpu.log |grep "total time:")
      str7=$name13$name14
      echo $str7
}


function The_memory_test () {
      #printf "正在测试，请耐心等待"
      /usr/local/sysbench-1.0.17/src/sysbench --test=memory --memory-block-size=8K --memory-total-size=4G --num-threads=2 run  > /tmp/memory.log 2>&1
      name15=内存读写性能
      name16=$(cat /tmp/memory.log |grep "transferred")
      str8=$name15$name16
      echo $str8
}


function Disk_test () {
      #printf "正在测试，请耐心等待，大约30分钟"
      #rndrw 混合随机读/写
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw prepare > /tmp/rndrw-prepare.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw run > /tmp/rndrw-run.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw cleanup > /tmp/rndrw-cleanup.log 2>&1
      
      #rndwr 随机写入
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndwr prepare > /tmp/rndwr-prepare.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndwr run > /tmp/rndwr-run.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndwr cleanup > /tmp/rndwr-cleanup.log 2>&1
      
      #rndrd 随机读取
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrd prepare > /tmp/rndrd-prepare.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrd run > /tmp/rndrd-run.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrd cleanup > /tmp/rndrd-cleanup.log 2>&1
      
      #seqrd 顺序读取
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrd prepare > /tmp/seqrd-prepare.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrd run > /tmp/seqrd-run.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrd cleanup > /tmp/seqrd-cleanup.log 2>&1
      
      #seqrewr 顺序读写
      #/usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrewr prepare > /tmp/seqrewr-prepare.log 2>&1
      #/usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrewr run > /tmp/seqrewr-run.log 2>&1
      #/usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqrewr cleanup > /tmp/seqrewr-cleanup.log 2>&1
      
      #seqwr 顺序写入
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqwr prepare > /tmp/seqwr-prepare.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqwr run > /tmp/seqwr-run.log 2>&1
      /usr/local/sysbench-1.0.17/src/sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=seqwr cleanup > /tmp/seqwr-cleanup.log 2>&1
      
      #clear
      name1=顺序写入速度
      name2=$(cat /tmp/seqwr-run.log |grep "written, MiB/s:")
      str1=$name1$name2
      echo $str1
      
      #name3=顺序读写速度
      #name4=$(cat /tmp/seqrewr-run.log |grep "written, MiB/s:")
      #str2=$name3$name4
      #echo $str2
      
      name5=顺序读取速度
      name6=$(cat /tmp/seqrd-run.log |grep "read, MiB/s:")
      str3=$name5$name6
      echo $str3
      
      name7=随机读取速度
      name8=$(cat /tmp/rndrd-run.log |grep "read, MiB/s:")
      str4=$name7$name8
      echo $str4
      
      name9=随机写入速度
      name10=$(cat /tmp/rndwr-run.log |grep "written, MiB/s:")
      str5=$name9$name10
      echo $str5
      
      name11=混合随机读/写
      name12=$(cat /tmp/rndrw-run.log |grep "MiB/s")
      str6=$name11$name12
      echo $str6
}

function Grading_test () {
      cd /tmp/UnixBench
      ./Run > /tmp/unixbench.log 2>&1
      name17=评分
      name18=$(cat /tmp/unixbench.log |grep "System Benchmarks Index Score")
      str9=$name17$name18
      echo $str9
}
	
function A_key_test () {
      screen iotest
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
`echo -e "\033[33m 6)磁盘IO测试(预估至少30分钟)\033[0m"`
`echo -e "\033[33m 7)评分测试(预估至少45分钟)\033[0m"`
`echo -e "\033[33m 8)一键测试(预估至少75分钟)\033[0m"`
`echo -e "\033[33m 9)退出\033[0m"`
EOF
read -p "请输入对应产品的数字：" num1
case $num1 in
    1)
      #clear
      Test_environment_initialization
      menu
      ;;
#获取服务器软件、硬件信息。
    2)
      #clear
      Get_hardware_and_software_information
      menu
      ;;
#获取网络延迟。
    3)
      #clear
      Network_delay_test
      menu
      ;;
#测试cpu。
    4)
      #clear
      The_CPU_test
      menu
      ;;
#测试内存。
    5)
      #clear
      The_memory_test
      menu
      ;;
#测试磁盘IO。
    6)
      #clear
      Disk_test
      menu
      ;;
#服务器性能跑分。
    7)
      #clear
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
