+++
title = "LeakIX goes open source"
description = "We're releasing a good part of the toolset we use to run the indexing service to the community"

tags = [
"opensource",
"l9",
"leakix",
]
date = "2020-12-17 13:30:00"
categories = [
"LeakIX How-to",
]
keywords = [
"leakix",
"howto",
"l9format"
]
image = "cover.png"

+++

We're releasing a good part of the toolset we use for our indexing service to the community !

Learn more about how to use them in this post.

<!--more-->

### The tools

We sure love to decouple every step of our scanning process, so it can be distributed and updated quickly to our needs.

There are a few parts involved, but so far the opensource releases are :

- [ip4scout](https://github.com/LeakIX/ip4scout), our random ipv4 space scanner.
- [l9tcpid](https://github.com/LeakIX/l9tcpid), our TCP protocol inspector.
- [l9explore](https://github.com/LeakIX/l9explore), our deep protocol exploration tool.


### Interoperability
All those parts use **STDIN**/**STDOUT** to communicate JSON lines between each others. ( quick ACK to Project Discovery, it just makes sense !)

They all use a common schema : [l9format](https://github.com/LeakIX/l9format)

![l9format](/leakix/oss/l9sample.png)

The goal of any tool the l9 suite is simple :

*Complete the schema by using the information it's provided*

We also came up with [l9filter](https://github.com/LeakIX/l9filter) who's job is to transform l9format **to** and **from** any other supported format :

- nmap
- masscan
- human
- *more coming*

Doing so made it possible to use a tooling that was once written for random Internet scanning in private and other large networks.

### Scan your network

The following example covers `10.0.0.0/8` :

```sh
masscan --rate 100000 -p1-65535 10.0.0.0/8|\              #Use masscan to scan 10.0.0.0/8
  l9filter transform -i masscan -o l9|\                   #Transform masscan output to l9format
  l9tcpid service --deep-http --max-threads=2048|\        #Identifies each protocol
  pv -rabl|\                                              #Displays rate at which we identify hosts
  tee services.json|\                                     #Save l9 formatted lines to services.json
  l9explore service --explore-timeout 5s -t 2048 -l|\     #Run every l9plugin against to protocol they know
  tee leaks.json |\                                       #Save protocol leaks to leaks.json
  l9filter transform -i l9 -o human                       #Displays a human readable output
```

By working that way you can :

- Reuse services.json with other tools for further exploration
- Connect masscan to the tool suite efficiently by forwarding its live output
- Import the JSON data to any backend for analysis
- Use JQ to perform filtering

With the next example, you can extract all the domains found in SSL certificates :

```sh
jq 'select(.ssl.certificate.domain != null) .ssl.certificate.domain[]' < services.json|sort|uniq
*.123-flowers.co.uk
*.3rdeyecam.com
*.aerocrs.com
*.aganytime.com
*.agro.services
*.air-watch.com
*.all-flo.com
*.americasfarmers.com
```

### Plugins

[l9plugins](https://github.com/LeakIX/l9plugins) are currently used by l9explore. They could be implemented by any Golang based tool.

There's a limited set at the moment, we're busy porting them from our old architecture.

|Plugin|Description|
|------|-----|---|
|mysql_open|Connects and checks for default credentials|
|mongo_open|Connects and checks for open instance|
|elasticsearch_open|Connects and checks for open instance|
|redis_open|Connects and checks for open instance|

### Creating plugins

There will be a separate post describing the process, meanwhile the bravest can [check the interface reference](https://github.com/LeakIX/l9format/blob/master/l9plugin.md) if you want to develop your own.

#### Conclusion

This is just the first step as more integrations with other tools are making it to l9filter.

We hope you have fun connecting those things together ! Feel free to report bugs and contribute on Github's project page. 

[leakix]: <https://leakix.net/>
