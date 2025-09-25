+++
title = "What we know about the China Leak"
description = "Quick analysis of  the facts we gathered"
tags = [
"leak",
"research",
"reporting",
"china",
]
date = "2022-07-07 11:00:00"
sections = [
"Research",
"Exploration",
]
keywords = [
"leak",
"research",
"reporting",
"china",
]
image = "cover.png"
+++

In this quick blog post we'll see what LeakIX has indexed over this incident.

<!--more-->

## Software stack

The service leaking the data was an unprotected Kibana instance running on port
`5601` ( default Kibana port ).

[Kibana](https://www.elastic.co/kibana/) is used to view data and administrate
an Elasticsearch cluster and **allows for proxied connections** to the
underlying Elasticsearch cluster.

At the time of the index, the endpoint was running version `5.5.3` of the ELK
stack.

![Home](/chinaleak/1.png)

## Cloud service

The certificate information we gathered indicates the service was running behind
`es-cn-ex719u34jb5099704.kibana.elasticsearch.aliyuncs.com`.

This is the default Kibana endpoint exposed by AliBaba when an Elasticsearch
service is deployed on a public network.

[Alibaba's documentation](https://partners-intl.aliyun.com/help/en/elasticsearch/latest/log-on-to-the-kibana-console)
currently states that exposure of the endpoint to a public network will happen
by default.

![Home](/chinaleak/3.png)

## Lack of password protection

AliBaba's documentation also states that a default username and password
(`elastic/elastic`) will be assigned to the ElasticSearch cluster.

However, we can see the Elasticsearch version that was exposed is actually
`5.5.3`.

This look like a legacy Elasticsearch cluster version, **which did NOT support
authentication out of the box** and required a paid license or a third-party
authentication plugin to enable it.

An analysis of the running cluster features reveals that **x-pack** wasn't
installed on any of the 33 servers.

## External activity

The first sign of external activity
[was detected around the 26th of June](https://leakix.net/host/101.89.99.234) by
our probes with the appearance of the following indices :

```
Found index contact_for_data with 0 documents (810 B)
Found index recovery10btc with 0 documents (810 B)
Found index your_data_is_safe with 1 documents (6.0 kB)
Found index contact_for_your_data with 2 documents (11.2 kB)
Found index read_note_for_details with 1 documents (6.0 kB)
```

This suggests at least 4 different groups got their hands on the cluster at that
date.

Most of the data was also dropped, allegedly by the ransomware groupS.

## Other impacts

Multiple ElasticSearch cluster deployed at Alibaba faced the same issue with
older version of ElasticSearch all exposed if the default Kibana configuration
was kept :

[See other affected Kibana endpoints](https://leakix.net/search?scope=leak&q=%2Bssl.certificate.cn%3A%22kibana.elasticsearch.aliyuncs.com+%22)

![Home](/chinaleak/4.png)

On the 1st of July, AliBaba has made private or has shutdown all the Kibana
servers running `5.5.3`.

The oldest exposed endpoint is dated from `2020-12-24 20:30`.

### References

- [CNN : Nearly one billion people in China had their personal data leaked, and it's been online for more than a year](https://edition.cnn.com/2022/07/05/china/china-billion-people-data-leak-intl-hnk/index.html)
- [Exposed 5.5.3 clusters](https://leakix.net/search?scope=leak&q=%2Bssl.certificate.cn%3A%22kibana.elasticsearch.aliyuncs.com+%22)
- [Exposed server history](https://leakix.net/host/101.89.99.234)
- [Optional X-Pack plugin for security](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/installing-xpack-es.html)
