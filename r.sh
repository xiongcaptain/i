#cent 6 64 bit

dir=`pwd`

port="53489"
password="password"

#Function

install_ss(){

	yum -y update
	yum -y install python-setuptools && easy_install pip
	yum -y install m2crypto git
	git clone -b manyuser https://github.com/breakwa11/shadowsocks.git
	cd ${dir}/shadowsocks/shadowsocks
	python server.py -p ${port} -k ${password} -m rc4-md5 -P auth_sha1 -o http_simple -d start
	echo 'python '${dir}'/shadowsocks/shadowsocks/server.py -p '${port}' -k '${password}' -m rc4-md5 -P auth_sha1 -o http_simple -d start' >> /etc/rc.local
	
}

elimits(){

	echo "* soft nofile 51200" >> /etc/security/limits.conf
	echo "* hard nofile 51200" >> /etc/security/limits.conf

}

esysctl(){

	echo "fs.file-max = 51200" >> /etc/sysctl.conf
	echo "net.ipv4.conf.lo.accept_redirects=0" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
	echo "net.ipv4.conf.eth0.accept_redirects=0" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.conf
	echo "net.ipv4.ip_local_port_range = 10000 65000" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = hybla" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_rmem  = 32768 436600 873200" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_timestsmps = 0" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_max_tw_buckets = 9000" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_max_syn_backlog = 65536" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_mem = 94500000 91500000 92700000" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_max_orphans = 3276800" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_wmem = 8192 436600 873200" >> /etc/sysctl.conf
	echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.conf
	echo "net.core.somaxconn = 32768" >> /etc/sysctl.conf
	echo "net.core.wmem_default = 8388608" >> /etc/sysctl.conf
	echo "net.core.rmem_default = 8388608" >> /etc/sysctl.conf
	echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
	echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf

	sysctl -p

}

eiptables(){

	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
	/etc/init.d/iptables save
	/etc/init.d/iptables restart

}

net_speeder(){

	wget --no-check-certificate https://gist.github.com/LazyZhu/dc3f2f84c336a08fd6a5/raw/d8aa4bcf955409e28a262ccf52921a65fe49da99/net_speeder_lazyinstall.sh
	sh net_speeder_lazyinstall.sh
	nohup /usr/local/net_speeder/net_speeder venet0 "ip" >/dev/null 2>&1 &
	echo 'nohup /usr/local/net_speeder/net_speeder venet0 "ip" >/dev/null 2>&1 &' >> /etc/rc.local

}


shadowsocks_py(){

	clear
	install_ss
	elimits
	esysctl
	eiptables
	net_speeder

}

# Main process

shadowsocks_py

echo "Finished"
