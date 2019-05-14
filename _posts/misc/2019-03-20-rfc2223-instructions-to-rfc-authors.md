---
layout:        post
title:         "nroffマクロを使ったRFCの作成"
menutitle:     "nroffマクロを使ったRFCの作成"
date:          2019-03-20
tags:          Misc
category:      Misc
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

[Instructions to RFC Authors -- RFC 2223](https://tools.ietf.org/html/rfc2223) の付録にRFCのnroffマクロについての記述があります。
一般的に、RFCの作成では nroff の ms マクロ（書類用マクロ）を使います。
なのでコマンドは `nroff -ms input-file > output-file` のようになりますが、
nroff では改ページ（form feed）の空行を調整することができないので、
この問題を解決する Perl スクリプトの fix.pl を用意します。
これによってRFCを生成するコマンドは次のようになります。

```bash
nroff -ms input-file | fix.pl > output-file
```


#### RFCの元となる文書（roff形式）

元となる文書には「[A Standard for the Transmission of IP Datagrams on Avian Carriers（鳥類キャリアによるIPデータグラムの伝送規格） -- RFC 1449](https://tools.ietf.org/rfc/rfc1149.txt)」というエイプリルフールにRFCで発表されたジョーク規格を使いました。

input-file

```
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Waitzman
.ds RF FORMFEED[Page %]
.ds CF
.ds LH RFC 1149
.ds RH 1 April 1990
.ds CH IP Datagrams on Avian Carriers
.hy 0
.ad l
.in 0
Network Working Group                                        D. Waitzman
Request for Comments: 1149                                       BBN STC
                                                            1 April 1990


.ce
A Standard for the Transmission of IP Datagrams on Avian Carriers

.ti 0
Status of this Memo

.fi
.in 3
This memo describes an experimental method for the encapsulation of IP datagrams in avian carriers.  This specification is primarily useful in Metropolitan Area Networks.  This is an experimental, not recommended standard.  Distribution of this memo is unlimited.

.ti 0
Overview and Rational

Avian carriers can provide high delay, low throughput, and low altitude service.  The connection topology is limited to a single point-to-point path for each carrier, used with standard carriers, but many carriers can be used without significant interference with each other, outside of early spring.  This is because of the 3D ether space available to the carriers, in contrast to the 1D ether used by IEEE802.3.  The carriers have an intrinsic collision avoidance system, which increases availability.  Unlike some network technologies, such as packet radio, communication is not limited to line-of-sight distance.  Connection oriented service is available in some cities, usually based upon a central hub topology.

.ti 0
Frame Format

The IP datagram is printed, on a small scroll of paper, in hexadecimal, with each octet separated by whitestuff and blackstuff. The scroll of paper is wrapped around one leg of the avian carrier. A band of duct tape is used to secure the datagram's edges.  The bandwidth is limited to the leg length.  The MTU is variable, and paradoxically, generally increases with increased carrier age.  A typical MTU is 256 milligrams.  Some datagram padding may be needed.

Upon receipt, the duct tape is removed and the paper copy of the datagram is optically scanned into a electronically transmittable form.

.ti 0
Discussion

Multiple types of service can be provided with a prioritized pecking order.  An additional property is built-in worm detection and eradication.  Because IP only guarantees best effort delivery, loss of a carrier can be tolerated.  With time, the carriers are self-regenerating.  While broadcasting is not specified, storms can cause data loss.  There is persistent delivery retry, until the carrier drops.  Audit trails are automatically generated, and can often be found on logs and cable trays.

.ti 0
Security Considerations

.in 3
Security is not generally a problem in normal operation, but special measures must be taken (such as data encryption) when avian carriers are used in a tactical environment.

.ti 0
Author's Address

.nf
David Waitzman
BBN Systems and Technologies Corporation
BBN Labs Division
10 Moulton Street
Cambridge, MA 02238

Phone: (617) 873-4323

EMail: dwaitzman@BBN.COM
```

#### ページの区切りで空白を調整するスクリプト

fix.pl

```perl
#!/usr/local/bin/perl

# fix.pl  17-Nov-93  Craig Milo Rogers at USC/ISI
#
#       The style guide for RFCs calls for pages to be delimited by the
# sequence <last-non-blank-line><formfeed-line><first-non-blank-line>.
# Unfortunately, NROFF is reluctant to produce output that conforms to
# this convention.  This script fixes RFC-style documents by searching
# for the token "FORMFEED[Page", replacing "FORMFEED" with spaces,
# appending a formfeed line, and deleting white space up to the next
# non-white space character.
#
#       There is one difference between this script's output and that of
# the "fix.sh" and "pg" programs it replaces:  this script includes a
# newline after the formfeed after the last page in a file, whereas the
# earlier programs left a bare formfeed as the last character in the
# file.  To obtain bare formfeeds, uncomment the second substitution
# command below.  To strip the final formfeed, uncomment the third
# substitution command below.
#
#       This script is intended to run as a filter, as in:
#
# nroff -ms input-file | fix.pl > output-file
#
#       When porting this script, please observe the following points:
#
# 1)    ISI keeps perl in "/local/bin/perl";  your system may keep it
#       elsewhere.
# 2)    On systems with a CRLF end-of-line convention, the "\n"s below
#       may have to be replaced with "\r\n"s.

#$* = 1;                                 # Enable multiline patterns.
undef $/;                               # Read whole files in a single
                                        # gulp.

while (<>) {                            # Read the entire input file.
    s/FORMFEED(\[Page\s+\d+\])\s+/        \1\n\f\n/mg;
                                        # Rewrite the end-of-pages.
#    s/\f\n$/\f/;                       # Want bare formfeed at end?
#    s/\f\n$//;                         # Want no formfeed at end?
    print;                              # Print the resultant file.
}
```


### 実行コマンド

```bash
chmod +x fix.pl
nroff -ms input-file | ./fix.pl > output-file
```

### 結果

output-file

```





Network Working Group                                        D. Waitzman
Request for Comments: 1149                                       BBN STC
                                                            1 April 1990


   A Standard for the Transmission of IP Datagrams on Avian Carriers

Status of this Memo

   This memo describes an experimental method for the encapsulation of
   IP datagrams in avian carriers.  This specification is primarily
   useful in Metropolitan Area Networks.  This is an experimental, not
   recommended standard.  Distribution of this memo is unlimited.

Overview and Rational

   Avian carriers can provide high delay, low throughput, and low
   altitude service.  The connection topology is limited to a single
   point‐to‐point path for each carrier, used with standard carriers,
   but many carriers can be used without significant interference with
   each other, outside of early spring.  This is because of the 3D ether
   space available to the carriers, in contrast to the 1D ether used by
   IEEE802.3.  The carriers have an intrinsic collision avoidance
   system, which increases availability.  Unlike some network
   technologies, such as packet radio, communication is not limited to
   line‐of‐sight distance.  Connection oriented service is available in
   some cities, usually based upon a central hub topology.

Frame Format

   The IP datagram is printed, on a small scroll of paper, in
   hexadecimal, with each octet separated by whitestuff and blackstuff.
   The scroll of paper is wrapped around one leg of the avian carrier. A
   band of duct tape is used to secure the datagram’s edges.  The
   bandwidth is limited to the leg length.  The MTU is variable, and
   paradoxically, generally increases with increased carrier age.  A
   typical MTU is 256 milligrams.  Some datagram padding may be needed.

   Upon receipt, the duct tape is removed and the paper copy of the
   datagram is optically scanned into a electronically transmittable
   form.

Discussion

   Multiple types of service can be provided with a prioritized pecking
   order.  An additional property is built‐in worm detection and
   eradication.  Because IP only guarantees best effort delivery, loss
   of a carrier can be tolerated.  With time, the carriers are self‐



Waitzman                                                        [Page 1]

RFC 1149             IP Datagrams on Avian Carriers         1 April 1990


   regenerating.  While broadcasting is not specified, storms can cause
   data loss.  There is persistent delivery retry, until the carrier
   drops.  Audit trails are automatically generated, and can often be
   found on logs and cable trays.

Security Considerations

   Security is not generally a problem in normal operation, but special
   measures must be taken (such as data encryption) when avian carriers
   are used in a tactical environment.

Author’s Address

   David Waitzman
   BBN Systems and Technologies Corporation
   BBN Labs Division
   10 Moulton Street
   Cambridge, MA 02238

   Phone: (617) 873‐4323

   EMail: dwaitzman@BBN.COM





























Waitzman                                                        [Page 2]
```
