+++
title = "New search and host details page"
description = "The old ugly host details page was sure useful, but let's face it, it was unreadable"

tags = [
    "howto",
    "feature",
    "leakix",
    "details",
]
date = "2020-10-25 15:00:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
]
image = "cover.png"

+++

The old ugly host details page was sure useful, but let's face it, it was unreadable

<!--more-->

### Resource details

All details pages now come with new information linked to it :

- Domains
- IP list
- Softwares and versions

Furthermore, they also now come in 3 variant : 

##### Host details

Eg : [https://leakix.net/host/23.97.216.47](https://leakix.net/host/23.97.216.47)

![host-scope](/leakix/v2/host-scope.png)

All domains linked to this IP will now be displayed and can be followed for further investigation.

##### Domain details

*If your search matched a domain, you will be directed to this page*

Eg : [https://leakix.net/domain/ruralskillsonline.com](https://leakix.net/domain/ruralskillsonline.com)

![host-scope](/leakix/v2/domain-scope.png)

All IPs and subdomains for this domain will now be displayed and can be followed for further investigation

##### Network details

Eg : [https://leakix.net/network/13.89.186.0/24](https://leakix.net/network/13.89.186.0/24)

![host-scope](/leakix/v2/network-scope.png)

This one is not linked from anywhere yet, although we plan to use this screen for users dashboard too.

Just know it's there, (:)) and like all details pages can be queried as `application/json` !

[leakix]: <https://leakix.netloc/>
