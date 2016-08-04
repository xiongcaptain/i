#cent 6 64 bit

dir=`pwd`

port="53489"
password="password"

#Function

install_ss(){

	yum -y update
	yum -y install python-setuptools && easy_install pip
	pip install shadowsocks
	sudo ssserver -p ${port} -k ${password} -m rc4-md5 --user nobody -d start
	echo 'sudo ssserver -p '${port}' -k '${password}' -m rc4-md5 --user nobody -d start' >> /etc/rc.local
	
}

shadowsocks_py(){

	clear
	install_ss

}

# Main process

shadowsocks_py

echo "Finished"
