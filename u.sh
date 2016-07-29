
dir=`pwd`

port="53488"
password="password"

kill(){
	
	kill `ps -ef | grep server.py | awk 'NR==1{print $2}'`
}

update(){
	
	cd ${dir}/shadowsocks
	git pull
	python server.py -p ${port} -k ${password} -m rc4-md5 -o http_simple -d start

}

u(){
	kill
	update
}

u

echo "Finished"
