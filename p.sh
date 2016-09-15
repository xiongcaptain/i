
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
tar -zxvf Python-2.7.9.tgz
cd Python-2.7.9
./configure --prefix=/usr/local/
make && make install
ln -sf /usr/local/bin/python2.7 /usr/bin/python
sed -i 's/#!//usr//bin//python///#!//usr//bin//python2.6/g' /usr/bin/yum
python -V
