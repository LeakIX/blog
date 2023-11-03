+++
title = "CVE-2023-45498: RCE in VinChin Backup"
url = "2023/10/vinchin-backup-rce-chain"
description = "CVE-2023-45498/CVE-2023-45499 advisory"
tags = [
    "vulnerability",
    "research",
    "LeakIX",
]
date = "2023-10-15 20:20:00"
categories = [
    "vulnerability",
    "research",
    "LeakIX"
]
menu = "main"
images = ["/vinchin/vinchin.png"]

+++

![Picture](/vinchin/vinchin.png)

**Update 2023-11-03:** The issue has been fixed in version 7.2.

## Vulnerability research

At LeakIX we analyse new vulnerabilities discovered by other researchers every day.

Our goal is to understand them, discover non-intrusive ways to detect them and provide our customers with a [list of vulnerable assets](https://leakix.net/plugins).

While researching what others have already found is always an exciting challenge and provides valuable experience,
it was time for us to go through the research and disclosure process first hand and get our first CVE on the board.
<!--more-->

We decided to look for issues in critical software.
It was natural for us to select the "Infrastructure Backup" category. Such software will hold an entire organisation's data but also credentials to critical points of the network, including:

- Servers
- Hypervisors
- Storage
- Cloud accounts


## VinChin Backup

VinChin Backup & Recovery is an **all-in-one backup solution for virtual infrastructures** supporting VMWare, KVM, Xen Server, Hyper-V, OpenStack and more. The product also supports AWS, Azure and other cloud providers as backup storage.

It is used by companies like Sony, Guizhou Power Grid, and while its main market is located in Asia, it has decent adoption on other continents and protects over 10,000 clients.

### CVE-2023-45499

During our research we discovered an HTTP API exposed by VinChin Backup. This API can be accessed using hard-coded credentials.

The privileges granted are high since ACLs are bypassed for this authentication method.

The list of actions available from the API includes:

- View/Edit/Add/Delete storage
- View/Delete backups
- View/Edit/Add/Delete jobs
- View/Edit/Add/Delete cloud accounts
- View/Edit/Add/Delete hypervisors
- View/Edit/Add/Delete users
- Query various information such as:
  - Services status
  - System information
  - Licensing

The list is non-exhaustive.


### CVE-2023-45498

While exploring the various functionalities exposed by the API a particular endpoint was found vulnerable to improper input sanitization.
A specially crafted payload results in remote code execution allowing the attacker to execute code with the permissions of the web server.

### Demo

{{< youtube NVT9_KODKSQ >}}

###

### Affected versions

During our routine scans we identified vulnerable products starting from 5.0 up until the last known version.

### IOC

Any requests made to `/api/` from an untrusted IP should be considered suspicious. The log can be found in `/var/log/nginx/access.log`.

### Fix

VinChin's fix was to limit the number of method callable with the hardcoded API key. The key itself still remains
but gives access to a limited set of endpoints.

![Picture](/vinchin/vinchin-fix.png)

CVE-2023-45498 still remains though, but API ACLs have been updated to avoid it being reached with hard-coded credentials.

![Picture](/vinchin/vinchin-rce.png)



### Mitigation

~~At this point VinChin has not acknowledged the issue despite our multiple requests, we can only recommend to remove all exposed instances from
untrusted network.~~

VinChin released version 7.2 fixing the issue. Users should update as soon as possible.

### Timeline

```
2023-09-22: LeakIX makes initial contact
2023-09-25: VinChin request details
2023-09-25: LeakIX request Safe harbour
2023-09-26: No reply, LeakIX requests update
2023-09-27: No reply, LeakIX sends PoC
2023-09-29: No reply, LeakIX requests feedback
2023-10-05: No reply, LeakIX requests feedback
2023-10-10: No reply, LeakIX requests feedback from alternative email
2023-10-11: No reply, LeakIX requests feedback from another alternative email
2023-10-16: No reply, CVE reserved and vendor notified
2023-10-18: No reply, LeakIX sent 7 day disclosure warning
2023-10-24: LeakIX sends early warning to providers hosting VinChin on their network.
2023-10-26: No reply, Publishing this advisory
2023-11-02: VinChin 7.2 released
2023-11-03: Updating this advisory with fix details
```

<!---
### First impressions

VinChin Backup & Recovery comes as **prebuilt ISO based on CentOS**. Starting its installation is straight forward and after
setting up the root and user account, the software is up and running on port 443!

We made sure to add our user to the administrative group so `sudo` would let us run command as root once installed.

Once logged in, we can see an NGINX/PHP installation running the frontend at `/usr/share/nginx/vinchin` 

### Encrypting and providing the key

-->
