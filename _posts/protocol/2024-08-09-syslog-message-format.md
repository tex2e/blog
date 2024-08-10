---
layout:        post
title:         "Syslogデータの構造 (RFC 5424)"
date:          2024-08-09
category:      Protocol
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

RFC 3164 と RFC 5424 で定義されている Syslogデータの構造について説明していきます。


### ABNF（Syslogデータの構文）

RFC 5424 の 6. Syslog Message Format に記載されているABNFの一部を抜粋すると、Syslogデータの構文は以下のようになっています。

```
SYSLOG-MSG      = HEADER SP STRUCTURED-DATA [SP MSG]

HEADER          = PRI VERSION SP TIMESTAMP SP HOSTNAME
                  SP APP-NAME SP PROCID SP MSGID
PRI             = "<" PRIVAL ">"
PRIVAL          = 1*3DIGIT ; range 0 .. 191
VERSION         = NONZERO-DIGIT 0*2DIGIT
HOSTNAME        = NILVALUE / 1*255PRINTUSASCII

STRUCTURED-DATA = NILVALUE / 1*SD-ELEMENT
SD-ELEMENT      = "[" SD-ID *(SP SD-PARAM) "]"
SD-PARAM        = PARAM-NAME "=" %d34 PARAM-VALUE %d34
SD-ID           = SD-NAME
PARAM-NAME      = SD-NAME
PARAM-VALUE     = UTF-8-STRING ; characters '"', '\' and
SD-NAME         = 1*32PRINTUSASCII

MSG             = MSG-ANY / MSG-UTF8
MSG-ANY         = *OCTET ; not starting with BOM
MSG-UTF8        = BOM UTF-8-STRING
BOM             = %xEF.BB.BF

NILVALUE        = "-"
```

ここから大雑把に、Syslogデータの構造を横に並べると、次のようになります。

    <プライオリティ>バージョン タイムスタンプ ホスト名 アプリケーション名 プロセスID メッセージID 構造化データ メッセージ(MSG)

ヘッダーの部分の要素について、何も設定しない場合は nil を表す「-」を設定します。

例えば、構造化データ (STRUCTURED-DATA) が nil (-) のとき、Syslogデータは以下のようになります。
※メッセージID (ID47) の次にある「-」が構造化データが存在しないことを表す。

    <34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47
    - BOM'su root' failed for lonvick on /dev/pts/8

構造化データ (STRUCTURED-DATA) が存在するときは、Syslogデータは以下のようになります。
※ 角括弧 `[ ]` で囲まれている部分が構造化データです。

    <165>1 2003-10-11T22:14:15.003Z mymachine.example.com
    evntslog - ID47 [exampleSDID@32473 iut="3" eventSource=
    "Application" eventID="1011"] BOMAn application
    event log entry...

### PRIパート

なお、Syslogデータの先頭にある PRI パート (\<数字> の部分) は、プライオリティ (Priority) の数値を表したものです。
プライオリティの値は、次の計算式で求めることができます。

    プライオリティ = ファシリティ × 8 + シビアリティ

ファシリティ（ログの種類）とシビアリティ（ログの重要度）は、ログごとにそれぞれ設定することができます。
ファシリティとその値の対応関係は以下の通りです。

-  0 : kernel messages (kern)
-  1 : user-level messages (user)
-  2 : mail system (mail)
-  3 : system daemons (daemon)
-  4 : security/authorization messages (auth)
-  5 : messages generated internally by syslogd (syslog)
-  6 : line printer subsystem (lpr)
-  7 : network news subsystem (news)
-  8 : UUCP subsystem (uucp)
-  9 : clock daemon (cron)
- 10 : security/authorization messages (authpriv)
- 11 : FTP daemon (ftp)
- 12 : NTP subsystem (ntp)
- 13 : log audit (security)
- 14 : log alert (console)
- 15 : clock daemon ※Linuxでは未使用
- 16 : local use 0  (local0)
- 17 : local use 1  (local1)
- 18 : local use 2  (local2)
- 19 : local use 3  (local3)
- 20 : local use 4  (local4)
- 21 : local use 5  (local5)
- 22 : local use 6  (local6)
- 23 : local use 7  (local7)

また、シビアリティとその値の対応関係は以下の通りです。

- 0 : Emergency: system is unusable
- 1 : Alert: action must be taken immediately
- 2 : Critical: critical conditions
- 3 : Error: error conditions
- 4 : Warning: warning conditions
- 5 : Notice: normal but significant condition
- 6 : Informational: informational messages
- 7 : Debug: debug-level messages

例えば、ファシリティ local4 (20) のシビアリティ notice (5) のログをSyslogデータとして構築するとき、そのプライオリティは 160×8 + 5 = 160 となるため、データの先頭が `<160>` と表記されます。

### MSGパート

メッセージ部分は、ログの内容を表すため、自由に内容を入れることができます。
ただし、メッセージの内容をUTF-8でエンコードするときは、必ずBOMを先頭に入れる必要があります。

RFC 3164 で定義されている BSD Syslog の形式では、MSGパートは**TAG**と**CONTENT**の2つから構成されています。
TAGとCONTENTは「: (コロン)」で区切られています。
例えば、次のメッセージは BSD Syslog 形式のメッセージの例です。

```
sshd[6554]: Connection closed by 127.0.0.1
```

上記の場合、TAGが `sshd[6554]` で、CONTENTが `Connection closed by 127.0.0.1` となります。

以上です。

### 参考資料

- [RFC 5424 - The Syslog Protocol](https://datatracker.ietf.org/doc/html/rfc5424)
