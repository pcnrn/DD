Cf#!/bin/bash
#
# Script Copyright www.fawzya.net
# ==========================
# 

if [[ $USER != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
        ether=eth0
fi

vps="FNS";

if [[ $vps = "FNS" ]]; then
	source="http://script.fawzya.net/debian"
else
	source="http://script.fawzya.net/debian"
fi

# go to root
cd



    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
	LGREEN=`echo "\033[0m\033[1;32m"`
    ENTER_LINE=`echo "\033[33m"`
	LRED=`echo "\033[0m\033[1;31m"`
	BLUE=`echo "\033[0m\033[1;36m"`


# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;
sudo apt-get install ca-certificates

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -q -O /etc/apt/sources.list $source/null/sources.list.debian7
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
#apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update
#apt-get install screen

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# install screenfetch
cd
wget -q $source/null/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch-dev
chmod +x /usr/bin/screenfetch-dev
echo "clear" >> .profile
echo "screenfetch-dev" >> .profile


# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf $source/null/nginx.conf
mkdir -p /home/fns/public_html
echo "<pre>Default Webpage</pre><br/><pre>Auto Installer Script Premium - ForNesia Community</pre>" > /home/fns/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/fns/public_html/info.php
wget -q -O /etc/nginx/conf.d/vps.conf $source/null/vps.conf
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
cd
# apt-get -y install openvpn
# wget -q -O /etc/openvpn/openvpn.tar "https://github.com/ForNesiaFreak/FNS/raw/master/sett/openvpn-debian.tar"
# cd /etc/openvpn/
# tar xf openvpn.tar
# wget -q -O /etc/openvpn/1194.conf $source/null/1194.conf
# service openvpn restart
# sysctl -w net.ipv4.ip_forward=1
# sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# wget -q -O /etc/iptables.up.rules $source/null/iptables.up.rules
# sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
# sed -i $MYIP2 /etc/iptables.up.rules;
# iptables-restore < /etc/iptables.up.rules
# service openvpn restart

#configure openvpn client config
# cd /etc/openvpn/
# wget -q -O /etc/openvpn/1194-client.ovpn $source/null/1194-client.conf
# sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false PremiumVPS
echo "PremiumVPS:$PASS" | chpasswd
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://github.com/ForNesiaFreak/FNS/raw/master/sett/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://github.com/ForNesiaFreak/FNS/raw/master/sett/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300


# install mrtg
wget -q -O /etc/snmp/snmpd.conf $source/null/snmpd.conf
wget -q -O /root/mrtg-mem.sh $source/null/mrtg-mem.sh
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/fns/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/fns/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl $source/null/mrtg.conf >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/fns/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 80' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 110 -p 80 -p 109"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# upgrade dropbear 2014
apt-get install zlib1g-dev
wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-2012.55.tar.bz2
bzip2 -cd dropbear-2012.55.tar.bz2 | tar xvf -
cd dropbear-2012.55
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart


# install vnstat gui
cd /home/fns/public_html/
wget https://github.com/ForNesiaFreak/FNS/raw/master/go/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# Instal (D)DoS Deflate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'


# install squid3
apt-get -y install squid3
wget -q -O /etc/squid3/squid.conf $source/null/squid3.conf
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
apt-get -y install apt-transport-https
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.831_all.deb
dpkg --install webmin_1.831_all.deb
service webmin restart
service vnstat restart



# install dos2unix
apt-get install dos2unix


wget -q https://github.com/ForNesiaFreak/FNS/raw/master/go/fornesia87.tgz
tar xvfz fornesia87.tgz
cd fornesia87
make

# install New pptp vpn 
wget -q $source/null/fnspptp.sh


#ADD MENU + Compiler

wget -q $source/freak/menu.sh
dos2unix /root/fornesia87/menu.sh


# download script lain + Compile

wget -q $source/freak/welcome.sh
wget -q $source/freak/user-login.sh
wget -q $source/freak/user-renew.sh
wget -q $source/freak/user-expired.sh
wget -q $source/freak/user-list.sh
wget -q $source/freak/add-del.sh
wget -q $source/freak/useradd.sh
wget -q $source/freak/user-pass.sh
wget -q $source/freak/mrtg.sh
wget -q $source/freak/vnstat.sh
wget -q $source/null/dropmon.sh
wget -q $source/freak/user-ban.sh
wget -q $source/freak/user-unban.sh
wget -q $source/freak/expiry-change.sh
wget -q $source/freak/user-limit.sh
wget -q $source/freak/del-user-expire.sh
wget -q $source/openvpn.sh
#wget -q $source/ocs.sh

./shc -f welcome.sh
./shc -f menu.sh
./shc -f fnspptp.sh
#./shc -v -r -T -f bench-network.sh
./shc -f user-login.sh
./shc -f user-renew.sh
./shc -f user-expired.sh
./shc -f user-list.sh
./shc -f add-del.sh
./shc -f useradd.sh
./shc -f user-pass.sh
./shc -f mrtg.sh
./shc -f vnstat.sh
./shc -f dropmon.sh
./shc -f user-ban.sh
./shc -f user-unban.sh
./shc -f expiry-change.sh
./shc -f user-limit.sh
./shc -f del-user-expire.sh
./shc -f openvpn.sh
#./shc -f ocs.sh

cp /root/fornesia87/welcome.sh.x /usr/bin/welcomeadmin
cp /root/fornesia87/menu.sh.x /usr/bin/panel
cp /root/fornesia87/fnspptp.sh.x /usr/bin/fnspptp
cp /root/fornesia87/user-login.sh.x /usr/bin/userloginfns
cp /root/fornesia87/user-renew.sh.x /usr/bin/userenewfns
cp /root/fornesia87/dropmon.sh.x /usr/bin/dropmon
cp /root/fornesia87/user-expired.sh.x /usr/bin/userexpiredfns
cp /root/fornesia87/user-list.sh.x /usr/bin/userlistfns
cp /root/fornesia87/add-del.sh.x /usr/bin/adddelfns
cp /root/fornesia87/useradd.sh.x /usr/bin/useraddfns
cp /root/fornesia87/user-pass.sh.x /usr/bin/userpassfns
cp /root/fornesia87/mrtg.sh.x /usr/bin/mrtgfns
cp /root/fornesia87/vnstat.sh.x /usr/bin/vnstatfns
cp /root/fornesia87/user-ban.sh.x /usr/bin/banneduserfns
cp /root/fornesia87/user-unban.sh.x /usr/bin/unbanneduserfns
cp /root/fornesia87/expiry-change.sh.x /usr/bin/expirychangefns
cp /root/fornesia87/user-limit.sh.x /usr/bin/limitsshfns
cp /root/fornesia87/del-user-expire.sh.x /usr/bin/deluserexpiredfns
cp /root/fornesia87/openvpn.sh.x /usr/bin/installvpn
#cp /root/fornesia87/ocs.sh.x /usr/bin/installocs

#Download Lain
cd
wget -q -O /usr/bin/benchfns $source/null/bench.sh
wget -q -O /usr/bin/speedtestfns $source/null/speedtest_cli.py
wget -q -O /usr/bin/psmemfns $source/null/ps_mem.py
wget -q -O /etc/issue.net $source/null/banner


echo "*/10 * * * * root /usr/bin/userexpiredfns" > /etc/cron.d/userexpiredfns
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "0 */8 * * * root service dropbear restart" > /etc/cron.d/dropbear
#sed -i '$ i\screen -AmdS limit /root/limit.sh' /etc/rc.local
#sed -i '$ i\screen -AmdS check /root/autokill.sh' /etc/rc.local

# Admin Welcome
chmod +x /usr/bin/welcomeadmin
echo "welcomeadmin" >> .profile


chmod +x /usr/bin/speedtestfns
chmod +x /usr/bin/fnspptp
chmod +x /usr/bin/benchfns
chmod +x /usr/bin/psmemfns
chmod +x /usr/bin/dropmon
chmod +x /usr/bin/userloginfns
chmod +x /usr/bin/userenewfns
chmod +x /usr/bin/userexpiredfns
chmod +x /usr/bin/userlistfns
chmod +x /usr/bin/adddelfns
chmod +x /usr/bin/useraddfns
chmod +x /usr/bin/userpassfns
chmod +x /usr/bin/mrtgfns
chmod +x /usr/bin/vnstatfns
chmod +x /usr/bin/userexpiredfns
chmod +x /usr/bin/panel
chmod +x /usr/bin/banneduserfns
chmod +x /usr/bin/unbanneduserfns
chmod +x /usr/bin/expirychangefns
chmod +x /usr/bin/limitsshfns
chmod +x /usr/bin/deluserexpiredfns
chmod +x /usr/bin/installvpn
#chmod +x /usr/bin/installocs

# finishing
chown -R www-data:www-data /home/fns/public_html
service cron restart
service nginx start
service php-fpm start
service vnstat restart
#service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile
userexpiredfns

# info
clear
echo -e "${LRED}Autoscript Includes:${NORMAL}" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Service${NORMAL}"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo -e "${LGREEN}OpenSSH  : ${NORMAL}22, 143"  | tee -a log-install.txt
echo -e "${LGREEN}Dropbear : ${NORMAL}443, 110, 109, 80"  | tee -a log-install.txt
echo -e "${LGREEN}Squid3    : ${NORMAL}8080, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo -e "${LGREEN}badvpn   : ${NORMAL}badvpn-udpgw port 7300"  | tee -a log-install.txt
echo -e "${LGREEN}PPTP VPN  : ${NORMAL}Create User via Panel Menu"  | tee -a log-install.txt
echo -e "${LGREEN}nginx    : ${NORMAL}81"  | tee -a log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Tools${NORMAL}"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs venet0"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}PANEL MENU${NORMAL}"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo -e "Silahkan Ketik ${LRED}panel ${NORMAL}Untuk Akses Fitur"  | tee -a log-install.txt
echo -e "Silahkan Ketik ${LRED}insttallvpn ${NORMAL}Untuk Install/Remove VPN Manual"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Fitur lain${NORMAL}"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo -e "${LGREEN}Webmin   : ${NORMAL}http://$MYIP:10000/"  | tee -a log-install.txt
echo -e "${LGREEN}Timezone : ${NORMAL}Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo -e "${LGREEN}Fail2Ban : ${NORMAL}[on]"  | tee -a log-install.txt
echo -e "${LGREEN}(D)DoS Deflate : ${NORMAL}[on]" | tee -a log-install.txt
echo -e "${LGREEN}IPv6     : ${NORMAL}[off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Auto Lock User Expire tiap jam 00:00" | tee -a log-install.txt
echo "Auto Reboot tiap jam 00:00 dan jam 12:00" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Deafult Akun SSH/OpenVPN${NORMAL}"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo -e "${LGREEN}Username   : ${NORMAL}PremiumVPS"  | tee -a log-install.txt
echo -e "${LGREEN}Password : ${NORMAL}$PASS"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
echo "Auto Script Installer Vps By suryadewa bangsat"  | tee -a log-install.txt
echo "suryadewa bangsat (http://www.imadenews.com/contact/ - 08563776008)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt

echo "-------------------------------------------"  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "-------------------------------------------"  | tee -a log-install.txt
echo -e "${LRED}SILAHKAN REBOOT VPS ANDA !${NORMAL}"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/debian7.sh
rm -f /root/fnspptp.sh
rm -f /root/menu.sh
rm -r /root/fornesia87
rm -f /root/fornesia87.tgz
rm -f /root/speedtest_cli.py
rm -f /root/ps_mem.py
rm -f /root/xfg.sh
rm -f /root/dropbear-2012.55.tar.bz2
rm -f /root/webmin_1.831_all.deb
