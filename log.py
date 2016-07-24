#-*-coding : utf-8 -*-

import os,re

log = "/var/log/shadowsocks.log"
ip = []

if os.path.exists(log):
    lines = open(log)
    try:
        for i in lines:
            k = re.search(r'from \d+\.\d+\.\d+\.\d+',i,re.M|re.I)
            if k:
                (a,b) = k.group().split(' ',1)
                if b not in ip:
                    ip.append(b)
    except IOError as err:
        print err
    lines.close()
    print 'A total of',len(ip),'IP'
    for i in ip:
        print i
else:
    print 'no exists !'
