
dir=`pwd`

port="53489"
password="password"

stop(){
	
	cd ${dir}/shadowsocks/shadowsocks
	rm -rf /var/log/shadowsocks.log
	python server.py -d stop
	
}

update(){
	
	cd ${dir}/shadowsocks
	git pull
	cd ${dir}/shadowsocks/shadowsocks
	python server.py -p ${port} -k ${password} -m rc4-md5 -P auth_sha1 -o http_simple -d start

}

u(){
	stop
	update
}

u

echo "Finished"
