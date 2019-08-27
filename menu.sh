#!/bin/sh
#Shell menu
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
`echo -e "\033[33m 7)跑分测试\033[0m"`
`echo -e "\033[33m 8)一键测试\033[0m"`
`echo -e "\033[33m 9)退出\033[0m"`
EOF
read -p "请输入对应产品的数字：" num1
case $num1 in
    1)
      clear
      yum -y install gcc automake autoconf libtool make perl-Time-HiRes perl sysbench
      wget https://download.laobuluo.com/tools/UnixBench5.1.3.tgz
      tar -zxvf UnixBench5.1.3.tgz
      cd UnixBench
      make
      menu
      ;;
    2)
    if  [ ! -e '/tmp/systeminfo.sh' ]; then
        echo "Installing systeminfo.sh......"
        dir=$(pwd)
        cd /tmp/
        wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/systeminfo.sh > /dev/null 2>&1
        cd $dir
        chmod a+rx /tmp/systeminfo.sh
        /usr/bin/bash /tmp/systeminfo.sh
    fi
      menu
      ;;
    3)
    if  [ ! -e '/tmp/AWS-ping.py' ]; then
        echo "Installing AWS-ping.py......"
        dir=$(pwd)
        cd /tmp/
        wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/AWS-ping.py > /dev/null 2>&1
        cd $dir
        chmod a+rx /tmp/AWS-ping.py
        python /tmp/AWS-ping.py
    fi
      menu
      ;;
    4)
      clear
      sysbench cpu --cpu-max-prime=20000 --threads=2 run
      menu
      ;;
    5)
      clear
      sysbench --test=memory --memory-block-size=8k --memory-total-size=4G run
      menu
      ;;
    6)
      clear
      sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw prepare
      sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw run
      sysbench --test=fileio --num-threads=16 --file-total-size=3G --file-test-mode=rndrw cleanup
      menu
      ;;
    7)
      cd /tmp/UnixBench
      ./Run
      menu
      ;;
    8)
      python /tmp/IO.sh
      menu
      ;;
    9)
      exit 0

esac
}
menu
