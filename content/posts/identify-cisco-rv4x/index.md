+++
title = "How we remotely identify Cisco's RV34X versions"
description = "A quick research into remotely identifying Cisco's RV34Xs"
tags = [
"howto",
"research",
"colab",
]
date = "2022-02-15 17:00:00"
categories = [
"LeakIX How-to",
]
keywords = [
"leakix",
"howto",
"research",
"colab",
]
image = "cover.png"

+++

A quick research into remotely identifying Cisco's RV43Xs
<!--more-->

### Trigger

We decided to identify those VPN routers on the Internet when we noticed signs that a critical vulnerability could be exploited.

### Methodology


#### Find a target set

With no software name or version available we finally prepared a search query
including a JARM filter :


```
+http.status:301 +jarm:"29d29d00029d29d21c29d29d29d29d881e59db99b9f67f908be168829ecef9" +"Location: ./login.html" +"Content-Length: 178"
```

This [LeakIX service query](https://leakix.net/search?scope=service&q=%2Bhttp.status%3A301+%2Bjarm%3A%2229d29d00029d29d21c29d29d29d29d881e59db99b9f67f908be168829ecef9%22+%2B%22Location%3A+.%2Flogin.html%22+%2B%22Content-Length%3A+178%22) allowed us to find all the RV34x we currently have in index.

#### Analyse the targets

With multiple panel at our disposal, we started searching for version numbers anywhere in the code.

![/ciscorv/img.png](/ciscorv/img.png)

Nothing caught our eye in those scripts. They are reused across multiple versions.

We then noticed the static files were returning `Last-Modified` headers :

![/ciscorv/img_2.png](/ciscorv/img_2.png)


#### Checking facts

We decided to start correlating those headers to actual release dates.

To our surprise on the targets, the dates weren't matching any version whatsoever and where pretty random.

#### Extracting the firmware

One thing that caught my attention is the software nginx mentioned in the `Server` header.

Surely that can't be an IOS firmware, so we downloaded the files from Cisco's
website (`RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img`) to investigate with it binwalk:

```bash
$ binwalk ~/Downloads/RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0x3856B86F, created: 2021-10-22 04:21:20, image size: 74890751 bytes, Data Address: 0x0, Entry Point: 0x0, data CRC: 0x90B59708, OS: Linux, CPU: ARM, image type: Firmware Image, compression type: gzip, image name: "RV340 Firmware Package"
64            0x40            gzip compressed data, from Unix, last modified: 2021-10-22 04:21:18
12888796      0xC4AADC        MySQL MISAM index file Version 7
30375202      0x1CF7D22       lrzip compressed data
67511151      0x406236F       PGP RSA encrypted session key - keyid: EE5BA5A 5CC79EFE RSA Encrypt-Only 3072b
```

The first line tells us the firmware is a package and binwalk recognizes it.

We extract that package, and repeat the process for every sub-package :

```bash
$ binwalk ~/Downloads/RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img -e .

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0x3856B86F, created: 2021-10-22 04:21:20, image size: 74890751 bytes, Data Address: 0x0, Entry Point: 0x0, data CRC: 0x90B59708, OS: Linux, CPU: ARM, image type: Firmware Image, compression type: gzip, image name: "RV340 Firmware Package"

$ find
.
./_RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img.extracted
./_RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img.extracted/40.gz
./_RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img.extracted/40

$ file ./_RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img.extracted/40
40: POSIX tar archive (GNU)

$ tar -xvf ./_RV34X-v1.0.03.24-2021-10-22-09-51-15-AM.img.extracted/40
md5sum_fw-rv340
fw.gz
preupgrade.gz
preupgrade_md5sum

$ tar -xzvf fw.gz
barebox-c2krv340.bin
firmware_time
firmware_version
img_version
md5sums_fw
openwrt-comcerto2000-hgw-rootfs-ubi_nand.img
openwrt-comcerto2000-hgw-uImage.img
preupgrade.gz
preupgrade_md5sum

$ binwalk openwrt-comcerto2000-hgw-rootfs-ubi_nand.img
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             UBI erase count header, version: 1, EC: 0x0, VID header offset: 0x800, data offset: 0x1000

$ binwalk -e openwrt-comcerto2000-hgw-rootfs-ubi_nand.img
$ find _openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/|head -20
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/mke2fs
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/jffs2mark
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/power_up.sh
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/udhcpc
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/power_down.sh
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/hotplug2
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/snapshot
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/firstboot
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/cyclesoak
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/fdisk
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/wan-port-workaround
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/mdev
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/validate_data
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/mkfs.ext2
_openwrt-comcerto2000-hgw-rootfs-ubi_nand.img.extracted/ubifs-root/1225039038/rootfs/sbin/hwclock

```

And that's it, we have the content of the rootfs available for reading.

It's a fair assumption Cisco's using openwrt for those routers :)

#### Find and ID the web files

After some digging we find the web directory :

```sh
$ find ubifs-root/1225039038/rootfs/www/
ubifs-root/1225039038/rootfs/www/config/config.json
ubifs-root/1225039038/rootfs/www/model
ubifs-root/1225039038/rootfs/www/login.html
ubifs-root/1225039038/rootfs/www/index.html.default
ubifs-root/1225039038/rootfs/www/i18n
ubifs-root/1225039038/rootfs/www/i18n/lang.json
ubifs-root/1225039038/rootfs/www/i18n/login_tw.js
ubifs-root/1225039038/rootfs/www/i18n/login_en.js
ubifs-root/1225039038/rootfs/www/i18n/lang_tw.js
ubifs-root/1225039038/rootfs/www/i18n/lang_en.js
ubifs-root/1225039038/rootfs/www/portal
ubifs-root/1225039038/rootfs/www/portal/logo.png
ubifs-root/1225039038/rootfs/www/portal/bg.jpg
```

and after more investigation we notice that only 3 files have a modification
date matching the build file every time :

![/ciscorv/img_2.png](/ciscorv/img_3.png)


#### Rechecking facts

Using our target set, we try accessing multiple `/cgi-bin/blockpage.cgi` on multiple devices.

Everytime their `Last-Modified` header matches an image build [available for download](https://software.cisco.com/download/home/286287791/type/282465789/release/1.0.03.26).

#### The boring part

One can now build a bot that HEADs `/cgi-bin/blockpage.cgi`, and compare the `Last-Modified` header against the firmware list to get the final version :

```golang

var ciscoVersionMap = map[string][]string{
    "2022-Jan-6": {"1.0.03.26"},
    "2021-Oct-22": {"1.0.03.24"},
    "2021-Jun-12": {"1.0.03.22"},
}
```

### End word

The results are now available at [https://leakix.net/search?scope=leak&q=plugin%3ACiscoRV](https://leakix.net/search?scope=leak&q=plugin%3ACiscoRV)

[leakix]: <https://leakix.net/>
