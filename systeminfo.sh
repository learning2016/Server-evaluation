# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Check if wget installed
if  [ ! -e '/usr/bin/wget' ]; then
    echo "Error: wget command not found. You must be install wget command at first."
    exit 1
fi

# Check release
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

rm -rf /tmp/report && mkdir /tmp/report

echo "正在安装必要的依赖，请耐心等待..."



# Install Virt-what
if  [ ! -e '/usr/sbin/virt-what' ]; then
    echo "Installing Virt-What......"
    if [ "${release}" == "centos" ]; then
        yum -y install virt-what > /dev/null 2>&1
    else
        apt-get update
        apt-get -y install virt-what > /dev/null 2>&1
    fi
fi

# Install uuid
echo "Installing uuid......"
if [ "${release}" == "centos" ]; then
    yum -y install uuid > /dev/null 2>&1
else
    apt-get -y install uuid > /dev/null 2>&1
fi


# Install curl
echo "Installing curl......"
if [ "${release}" == "centos" ]; then
    yum -y install curl > /dev/null 2>&1
else
    apt-get -y install curl > /dev/null 2>&1
fi


# Check Python
if  [ ! -e '/usr/bin/python' ]; then
    echo "Installing Python......"
    if [ "${release}" == "centos" ]; then
            yum update > /dev/null 2>&1
            yum -y install python
        else
            apt-get update > /dev/null 2>&1
            apt-get -y install python
    fi
fi

# Install AWS-ping
if  [ ! -e '/tmp/AWS-ping.py' ]; then
    echo "Installing AWS-ping.py......"
    dir=$(pwd)
    cd /tmp/
    wget -N --no-check-certificate https://raw.githubusercontent.com/learning2016/Server-evaluation/master/AWS-ping.py > /dev/null 2>&1
    cd $dir
fi
chmod a+rx /tmp/AWS-ping.py

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-74s\n" "-" | sed 's/\s/-/g'
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
uram=$( free -m | awk '/Mem/ {print $3}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
uswap=$( free -m | awk '/Swap/ {print $3}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
ipv6=$( wget -qO- -t1 -T2 ipv6.icanhazip.com )
disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )


clear
next
echo -e "CPU 型号             : ${SKYBLUE}$cname${PLAIN}"
echo -e "CPU 核心数           : ${SKYBLUE}$cores${PLAIN}"
echo -e "CPU 频率             : ${SKYBLUE}$freq MHz${PLAIN}"
echo -e "总硬盘大小           : ${SKYBLUE}$disk_total_size GB ($disk_used_size GB Used)${PLAIN}"
echo -e "总内存大小           : ${SKYBLUE}$tram MB ($uram MB Used)${PLAIN}"
echo -e "SWAP大小             : ${SKYBLUE}$swap MB ($uswap MB Used)${PLAIN}"
echo -e "开机时长             : ${SKYBLUE}$up${PLAIN}"
echo -e "系统负载             : ${SKYBLUE}$load${PLAIN}"
echo -e "系统                 : ${SKYBLUE}$opsy${PLAIN}"
echo -e "架构                 : ${SKYBLUE}$arch ($lbit Bit)${PLAIN}"
echo -e "内核                 : ${SKYBLUE}$kern${PLAIN}"
echo -ne "虚拟化平台           : "
virtua=$(virt-what) 2>/dev/null

if [[ ${virtua} ]]; then
    echo -e "${SKYBLUE}$virtua${PLAIN}"
else
    echo -e "${SKYBLUE}No Virt${PLAIN}"
fi

##Record All Test data
rm -rf /tmp/info.txt
touch /tmp/info.txt
echo $cname >> /tmp/info.txt
echo $cores >> /tmp/info.txt
echo $freq MHz >> /tmp/info.txt
echo "$disk_total_size GB ($disk_used_size GB 已使用) ">> /tmp/info.txt
echo "$tram MB ($uram MB 已使用) ">> /tmp/info.txt
echo "$swap MB ($uswap MB 已使用)" >> /tmp/info.txt
echo $up >> /tmp/info.txt
echo $load >> /tmp/info.txt
echo $opsy >> /tmp/info.txt
echo "$arch ($lbit 位) ">> /tmp/info.txt
echo $kern >> /tmp/info.txt
echo $virtua >> /tmp/info.txt
echo $io1 >> /tmp/info.txt
echo $io2 >> /tmp/info.txt
echo $io3 >> /tmp/info.txt
AKEY=$( uuid )


exec

