+++
title = "BanqueAtlantique.net, what your config reveals"
description = ""
tags = [
    "fixed-undisclosed",
    "declassified",
    "financial",
]
date = "2020-10-10 16:21:00"
categories = [
    "Public reports",
]
keywords = [
    "banqueatlantique",
    "leak",
    "report",
]
image = "cover.png"

+++

### When you ask for config files nicely ...

... you might as well [get some](https://leakix.net/host/154.68.41.73)!
<!--more-->

The server got indexed the first time by our system the __8th of August 2020__, with the content of the leak leaving now doubt about its origin :

![LeakIX results](/banqueatlantique/results.png)

_The reports and leaks are visible to the reporting team only considering their risk, the detail page will however mention the leaks and reports count._

### Problem

The culprit here, is a left over `/.env` file revealing information about the infrastructure, and its credentials.

```sh
$ curl 'http://154.68.41.73/.env'
```

```sh
APP_NAME=Banque-Atlantique
APP_ENV=production
APP_KEY=base64:<redacted>
APP_DEBUG=false
APP_URL=http://satis-abi.<redacted>/

LOG_CHANNEL=stack


LDAP_SCHEMA=ActiveDirectory
LDAP_HOSTS=192.168.<redacted>
LDAP_BASE_DN=ou=banqueatlantique,dc=banqueatlantique,dc=group
LDAP_USER_ATTRIBUTE=<redacted>
LDAP_USER_FORMAT=<redacted>=%s,ou=banqueatlantique,dc=banqueatlantique,dc=group
LDAP_CONNECTION=default
LDAP_USERNAME=satis.abi@<redacted>
LDAP_PASSWORD=<redacted>

#LDAP_HOSTS2=<redacted>
#LDAP_BASE_DN2=ou=dmdtest,dc=dmd,dc=com
#LDAP_USERNAME2=useradmin@test.com
#LDAP_PASSWORD2=<redacted>

#DB_CONNECTION=mysql
#DB_HOST=127.0.0.1
#DB_PORT=3306
#DB_DATABASE=abi
#DB_USERNAME=root
#DB_PASSWORD=null

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=10.<redacted>
MAIL_PORT=25
MAIL_USERNAME=reclamation@banqueatlantique.net
MAIL_PASSWORD=<redacted>
MAIL_ENCRYPTION=

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

SESSION_DRIVER=file
SESSION_DOMAIN=
JWT_SECRET=<redacted>


ADMIN_MAIL_ADDRESS=<redacted>
```

As you can see multiple credentials are leaking :

- __LDAP credentials__ -> useful for all sort of internal applications to test against
- __SMTP credentials__ -> useful for customer data mining and possibly scamming
- App key -> Could be used to forge requests to the application or predict cryptographic events 

### Disclosure

Notification and disclosure to the mentioned tech emails and support team would be fired on the __14th of August 2020__, 6 days after index :

![Disclosure](/banqueatlantique/report.png)

The issue would be resolved quickly after contacting them, although no reply nor disclosure has been provided by the company. 

### End word

There's a substantial amount of `.env` files in our index, you can [check it for yourself](https://leakix.net/search?page=0&q=%2Bplugin%3ADotEnvConfigPlugin&scope=leak).

__Tip__: You'll have to login to consult this specific plugin's details and data on the host detail page.

Well that's all we have for today. There's ... still ... plenty more in the backlog. Stay tuned!

[leakix]: <https://leakix.net/>
[banqueatlantique]: <https://www.banqueatlantique.net/>
