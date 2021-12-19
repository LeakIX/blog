+++
title = "Introduction: the \"dataset\" field"
description = "Presenting the new metrics you can now filter on"
tags = [
    "howto",
    "feature",
    "dataset",
]
date = "2020-10-08 14:30:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
    "search",
    "database",
]
menu = "main"
images = ["/leakix/dataset/dataset-size.png"]
+++

Searching datasets based on size and row count is now as easy as it sounds !

<!--more-->

#### Filtering on row count

The field `dataset.rows` can now be filtered and range can be used on it, eg :

The query `dataset.rows:>0` will [display](https://leakix.net/search?scope=leak&q=dataset.rows%3A%3E0) anything indexed that contains at least 1 record :

![Dataset rows](/leakix/dataset/search-rows.png)


#### Filtering on size

The field `dataset.size` can now be filtered and range can be used on it, eg :

The query `dataset.size:>1073741824` will [display](https://leakix.net/search?scope=leak&q=dataset.size%3A%3E1073741824) anything indexed that contains at least 1GB of data :

![Dataset rows](/leakix/dataset/dataset-size.png)

Hope it helps your research !

[leakix]: <https://leakix.net/>