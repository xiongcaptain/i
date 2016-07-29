
dir=`pwd`

port="53488"
password="password"

stop(){
	
	cd ${dir}/shadowsocks/shadowsocks
	python server.py -d stop
	
}

update(){
	
	cd ${dir}/shadowsocks
	git pull
	python server.py -p ${port} -k ${password} -m rc4-md5 -o http_simple -d start

}

u(){
	stop
	update
}

u

echo "Finished"
