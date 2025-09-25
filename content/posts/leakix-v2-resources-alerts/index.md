+++
title = "Managing resources and alerts"
description = "You can now add real-time monitoring on your resources and get notified by email!"

tags = [
    "howto",
    "feature",
    "leakix",
    "resources",
    "alerts",
]
date = "2020-10-28 20:57:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
    "resources",
    "alerts",
]
image = "cover.png"

+++

You can now add real-time monitoring on your resources and get notified by
email!

<!--more-->

### Managing resources

Navigating to [My resources](https://leakix.net/settings/resource) will open
your resource management page :

![mgmt](/leakix/v2/resources-list.png)

We currently support 3 types of resources :

- Network (represented as an IP `127.0.0.1` or CIDR `192.168.0.0/16`)
- Domain (`leakix.net` will match `*.leakix.net`)
- ASN

### Resource dashboard

The first advantage of registering your resources is the
[resource dashboard](https://leakix.net/dashboard/resources), which displays a
summary of all the recent events linked to them.

![dash](/leakix/v2/resource-dash.png)

3 different event levels are available for filtering, allowing you to prioritize
incident response.

### Configuring alerts

The second advantage is enabling notifications every time LeakIX finds a service
or leak matching your resources.

They can be configured by opening your
[Alert settings](https://leakix.net/settings/alert) screen :

![mgmt](/leakix/v2/alert-settings.png)

In here you can select which events should be notified to your primary email
address.

**By default, all resources will receive alerts when a leak is identified** on
one of their resources.

We hope it helps in eliminating easy targets from your infrastructure !

[leakix]: https://leakix.net/
