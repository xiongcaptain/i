#centos 6 64bit

dir=`pwd`
iprange="192.168.18"
ip=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
psk="pskishere"
username="user"
password="password"

#Function

download_lib(){

	yum -y install epel-release
	yum -y install gcc gcc-c++ ppp iptables make gmp-devel xmlto bison flex libpcap-devel lsof
	yum -y install xl2tpd curl-devel nss-devel nspr-devel pkgconfig pam-devel unbound-devel libcap-ng-devel

	wget --no-check-certificate https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
	tar -zxf libevent-2.0.22-stable.tar.gz
	rm -rf libevent-2.0.22-stable.tar.gz
	wget --no-check-certificate https://download.libreswan.org/libreswan-3.9.tar.gz
	tar -zxf libreswan-3.9.tar.gz
	rm -rf libreswan-3.9.tar.gz

}

install(){

	#libevent
	cd libevent-2.0.22-stable
	./configure
	make && make install
	ln -sf /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
	ln -sf /usr/local/lib/libevent_pthreads-2.0.so.5 /usr/lib64/libevent_pthreads-2.0.so.5

	#libreswan
	cd ${dir}/libreswan-3.9
	echo "WERROR_CFLAGS =" > Makefile.inc.local
	make programs && make install

	/usr/local/sbin/ipsec --version >/dev/null 2>&1
	
}

econf(){

	cat > /etc/ipsec.conf<<EOF
config setup
	nat_traversal=yes
	protostack=netkey
	oe=off
	interfaces="%defaultroute"
	dumpdir=/var/run/pluto/
	virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v6:fd00::/8,%v6:fe80::/10

conn L2TP-PSK-NAT
	rightsubnet=vhost:%priv
	also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
	authby=secret
	pfs=no
	auto=add
	keyingtries=3
	rekey=no
	ikelifetime=8h
	keylife=1h
	type=transport
	left=${ip}
	leftid=${ip}
	leftprotoport=17/1701
	right=%any
	rightprotoport=17/%any
	dpddelay=40
	dpdtimeout=130
	dpdaction=clear
EOF

	cat > /etc/ipsec.secrets<<EOF
${ip} %any: PSK "${psk}"
EOF

	cat > /etc/xl2tpd/xl2tpd.conf<<EOF
[global]
listen-addr = ${ip}
[lns default]
ip range = ${iprange}.2-${iprange}.254
local ip = ${iprange}.1
require chap = yes
refuse pap = yes
require authentication = yes
name = LinuxVPNserver
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

	cat > /etc/ppp/options.xl2tpd<<EOF
ipcp-accept-local
ipcp-accept-remote
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
crtscts
hide-password
idle 1800
mtu 1410
mru 1410
nodefaultroute
name l2tpd
debug
lock
proxyarp
connect-delay 5000
EOF

	rm -f /etc/ppp/chap-secrets

	cat > /etc/ppp/chap-secrets<<EOF
${username}    l2tpd    ${password}       *
EOF

	cp -pf /etc/sysctl.conf /etc/sysctl.conf.bak

	sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

	for each in `ls /proc/sys/net/ipv4/conf/`
	do
		echo "net.ipv4.conf.${each}.accept_source_route=0" >> /etc/sysctl.conf
		echo "net.ipv4.conf.${each}.accept_redirects=0" >> /etc/sysctl.conf
		echo "net.ipv4.conf.${each}.send_redirects=0" >> /etc/sysctl.conf
		echo "net.ipv4.conf.${each}.rp_filter=0" >> /etc/sysctl.conf
	done
	sysctl -p

}

eiptables(){

	iptables -I INPUT -p udp -m multiport --dports 500,4500,1701 -j ACCEPT
	iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -I FORWARD -s ${iprange}.0/24  -j ACCEPT
	iptables -t nat -A POSTROUTING -s ${iprange}.0/24 -j SNAT --to-source ${ip}
	/etc/init.d/iptables save

	echo > /var/tmp/libreswan-nss-pwd
	certutil -N -f /var/tmp/libreswan-nss-pwd -d /etc/ipsec.d
	rm -f /var/tmp/libreswan-nss-pwd

	chkconfig --add iptables
	chkconfig iptables on
	chkconfig --add ipsec
	chkconfig ipsec on
	chkconfig --add xl2tpd
	chkconfig xl2tpd on

	/etc/init.d/iptables restart
	/etc/init.d/ipsec start
	/etc/init.d/xl2tpd start

	ipsec verify
	
}

l2(){

	download_lib
	install
	econf
	eiptables
	
}

# Main process

l2

echo "Finished"
