#!/usr/bin/python
# -*- coding: UTF-8 -*-
'''
 Author qinliang
 Reference:
 1. https://www.s0nnet.com/archives/python-icmp
 2. http://www.pythoner.com/357.html
 3. https://github.com/ylws-4617
'''

import commands

def ping(host):
    cmd = "ping "+ str(host) + " -c2 -W 2"
    result = commands.getoutput(cmd)
    result = result.split()
    result = result[-2].split("/")[0]
    if result.isalpha():
        result = False
    return float(result)


STYLE = {
    'fore': {
        'black': 30, 'red': 31, 'green': 32, 'yellow': 33,
        'blue': 34, 'purple': 35, 'cyan': 36, 'white': 37,
    },
    'back': {
        'black': 40, 'red': 41, 'green': 42, 'yellow': 43,
        'blue': 44, 'purple': 45, 'cyan': 46, 'white': 47,
    },
    'mode': {
        'bold': 1, 'underline': 4, 'blink': 5, 'invert': 7,
    },
    'default': {
        'end': 0,
    }
}


def use_style(string, mode='', fore='', back=''):
    mode = '%s' % STYLE['mode'][mode] if STYLE['mode'].has_key(mode) else ''
    fore = '%s' % STYLE['fore'][fore] if STYLE['fore'].has_key(fore) else ''
    back = '%s' % STYLE['back'][back] if STYLE['back'].has_key(back) else ''
    style = ';'.join([s for s in [mode, fore, back] if s])
    style = '\033[%sm' % style if style else ''
    end = '\033[%sm' % STYLE['default']['end'] if style else ''
    return '%s%s%s' % (style, string, end)

D = {
    '北京-OFFICE': '106.38.76.146',
    '东京-GCP': '34.84.147.9',
    '新加坡-GCP': '35.240.222.92',
    '法兰克福-GCP': '35.198.79.218',
    '爱尔兰-AWS': '52.210.67.143',
    '艾奥瓦-GCP': '34.66.103.117'
    }



string =list()
d=dict()

for x in D:
    host=D[x]
    result = ping(host)


    if result == False:
        latency_str = use_style(str("Fail"), fore='red')
    elif float(result) <= 60:
        latency_str =use_style(str(round(result,2)) + " ms",fore='green')
    elif float(result) <= 130:
        latency_str = use_style(str(round(result,2))+" ms",fore='yellow')
    else:
        latency_str = use_style(str(round(result,2))+" ms", fore='red')

    d[x] = float(result)

    string.append((x,latency_str))
    if len(string) == 3:
        l1 = str(int(len(string[0][0])/3+12))
        l2 = str(int(len(string[1][0])/3+12))
        l3 = str(int(len(string[2][0])/3+12))
        mystring = "{0:"+l1+"}: {1:20}{2:"+l2+"}: {3:20}{4:"+l3+"}: {5:20}"
        print(mystring.format(string[0][0],string[0][1],string[1][0],string[1][1],string[2][0],string[2][1]))
        string = list()


if len(string) == 2:
    l1 = str(int(len(string[0][0])/3+12))
    l2 = str(int(len(string[1][0])/3+12))
    mystring = "{0:"+l1+"}: {1:20}{2:"+l2+"}: {3:20}"
    print(mystring.format(string[0][0],string[0][1],string[1][0],string[1][1]))

if len(string) == 1:
    l1 = str(int(len(string[0][0])/3+12))
    mystring = "{0:"+l1+"}: {1:20}"
    print(mystring.format(string[0][0],string[0][1]))

