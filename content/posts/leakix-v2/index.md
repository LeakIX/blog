+++
title = "LeakIX user account"
description = "The index is now limited to the public, we'll explore the limitations and how you can lift them !"

tags = [
    "howto",
    "feature",
    "leakix",
    "user",
]
date = "2020-10-25 14:30:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
]
image = "cover.png"

+++

The index is now limited to the public, we'll explore the limitations and how
you can lift them !

<!--more-->

#### Limit the dump

With over 10K visits per day, handling the load is not a huge deal. It becomes a
problem however when someone starts to download **~3M** pages in a few hours :

![Home](/leakix/v2/dump.png)

Results are now limited to **a period of 2 weeks, 2 weeks ago** for
non-registered users.

Every registered user gets **20K** requests to the site. Should you need more
for your research, feel free to contact us !

![Home](/leakix/v2/login.png)

You can create a [LeakIX account](https://leakix.net/auth/register) or
[sign-in with LinkedIn](https://leakix.net/auth/login) for the moment. Others
provider will be supported soon.

#### API users

You can generate an API key in your account settings :

![API-GEN](/leakix/v2/api-gen.png)

You can use it by adding an `api-key` http header containing it to your
requests.

#### LeakIX CLI users

[Version 0.3.0](https://github.com/LeakIX/LeakIXClient/releases/tag/0.3.0) has
been released and supports API keys through the `-k` switch.

#### Spiderfoot users

The latest development version contains support for the new API key and can be
found in the [master branch](https://github.com/smicallef/spiderfoot)

[leakix]: https://leakix.net/
