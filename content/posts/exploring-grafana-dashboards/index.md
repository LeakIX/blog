+++
title = "Exploring Grafana dashboards"
description = "Presenting the new Grafana indexer plugin"
tags = [
    "howto",
    "feature",
    "dashboard",
]
date = "2020-10-15 23:20:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
    "search",
    "dashboard",
]
image = "cover.png"

+++

This new plugin looks for open Grafana dashboards and provides a summary.

<!--more-->

You can [query the index](https://leakix.net/search?q=plugin%3AGrafanaOpenPlugin) with `plugin:GrafanaOpenPlugin`

#### Reading the results

It currently scans for dashboards in the Grafana installation and list their names.

![Grafana results](/grafana/grafana-results.png)

It will also check if the Grafana installation is secured or if admin access is allowed, in which case the data-sources URLs are retrieved too :

![Grafana results](/grafana/datasources.png)

Hope it helps your research !

[leakix]: <https://leakix.net/>
