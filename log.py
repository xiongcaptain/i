#-*-coding : utf-8 -*-

import os,re,urllib,json

log = "shadowsocks.log"
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
        url = 'http://ip.taobao.com/service/getIpInfo.php?ip=' + i
        page = urllib.urlopen(url)
        data = page.read()
        j = json.loads(data)
        if j[u'code'] == 0:
            print i,' Country :',j[u'data'][u'country'].encode('utf-8'),j[u'data'][u'city'].encode('utf-8')
else:
    print 'no exists !'
