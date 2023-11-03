+++
title = "Introducing LeakIX Graph"
description = "Take a look at our new mapping feature, visualize and make sense of Internet resources in a blink !"
tags = [
    "howto",
    "feature",
    "graph",
]
date = "2022-01-21 06:30:00"
categories = [
    "LeakIX How-to",
]
keywords = [
    "leakix",
    "howto",
    "graph",
]
image = "cover.png"

+++

Take a look at our new mapping feature, visualize and make sense of Internet resources in a blink !
<!--more-->

### Connecting the dots

Using our new graph UI and API allows researchers to give context to resources they're investigating.

After selecting a resource type (DNS, IPs, ASN...) you can explore a subtree further with the context menu.

![Home](/leakix/graph/menu.png)

- **Remove**: will remove the node from the graph
- **Start here**: will clear the workspace and start from the selected node
- **Explore**: will explore the selected node further and add it to the graph

You can open the menu by clicking (hold) the node for 1 second.

### Suggested use cases

- Identify subdomains
- Identify IPs and networks used between resources
- Identify alternate domain listening on asset's IPs
- Rule in/out a leak based on connections (eg: Cloudflare, ELB, ect...) 
- Group multiple leak as one source

### Built for the future

The switch to a graph database means a better structured backend for our future:

The following changes are planned :

- Link current search to graph database
- Switch reporting system to the graph database
- Allow report contacts filling through graph walk
- Allow for report escalation to neighborhood nodes ( country CERT, hosting abuse)
- Deduplication of all events ( including alerts )
- Better alerting and personal dashboard

Meanwhile, we hope it helps your research !

[leakix]: <https://leakix.net/>
