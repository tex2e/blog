---
layout:        post
title:         "Windowsポート番号一覧"
date:          2021-07-09
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsポート番号一覧です。ペネトレーションテストで注目すべきWindows特有のポート番号は太字にしています。

| ポート | ネットワーク | システム | 論理名 | ペネトレ
|-|-|-|-|-|
| 7/tcp/upd | Echo | 簡易 TCP/IP サービス | SimpTcp | [Echo](https://book.hacktricks.xyz/pentesting/7-tcp-udp-pentesting-echo)
| 9/tcp/upd | Discard | 簡易 TCP/IP サービス | SimpTcp
| 13/tcp/upd | Daytime | 簡易 TCP/IP サービス | SimpTcp
| 17/tcp/upd | Quotd | 簡易 TCP/IP サービス | SimpTcp
| 19/tcp/upd | Chargen | 簡易 TCP/IP サービス | SimpTcp
| 20/tcp | FTP default data | FTP Publishing Service | MSFtpsvc
| 21/tcp | FTP control | FTP Publishing Service | MSFtpsvc | [FTP](https://book.hacktricks.xyz/pentesting/pentesting-ftp)
|        |             | アプリケーション層ゲートウェイ サービス | ALG
| 23/tcp | Telnet | Telnet | TlntSvr | [Telnet](https://book.hacktricks.xyz/pentesting/pentesting-telnet)
| 25/tcp/upd | SMTP | Simple Mail Transport Protocol | SMTPSVC | [SMTP](https://book.hacktricks.xyz/pentesting/pentesting-smtp)
|            | SMTP | Exchange Server |
| 42/tcp/upd | WINS Replication | Windows インターネット ネーム サービス  | WINS
| 53/tcp/upd | DNS | DNS サーバー | DNS | [DNS](https://book.hacktricks.xyz/pentesting/pentesting-dns)
|            |     | インターネット接続ファイアウォール/インターネット接続の共有 | SharedAccess |
| 67/udp | DHCP Server | DHCP サーバー | DHCPServer
|        |             | インターネット接続ファイアウォール/インターネット接続の共有 | SharedAccess
| 69/udp | TFTP | Trivial FTP Daemon Service | tftpd | [TFTP](https://book.hacktricks.xyz/pentesting/69-udp-tftp)
| 80/tcp | HTTP | Windows Media サービス | WMServer | [Web](https://book.hacktricks.xyz/pentesting/pentesting-web)
|        |      | World Wide Web 発行サービス | W3SVC |
|        |      | SharePoint Portal Server | |
| **88/tcp/upd** | **Kerberos** | Kerberos キー配布センター | Kdc | [**Kerberos**](https://book.hacktricks.xyz/pentesting/pentesting-kerberos-88)
| 102/tcp | X.400 | Microsoft Exchange MTA Stacks |
| 110/tcp | POP3 | Microsoft POP3 サービス | POP3SVC | [POP](https://book.hacktricks.xyz/pentesting/pentesting-pop)
|         |      | Exchange Server |
| 119/tcp | NNTP | Network News Transfer Protocol | NntpSvc
| 123/udp | NTP/SNTP | Windows Time | W32Time
| **135/tcp** | **RPC** | メッセージ キュー | msmq | [**MSRPC**](https://book.hacktricks.xyz/pentesting/135-pentesting-msrpc)
|             |         | リモート プロシージャ コール | RpcSs |
|             |         | Exchange Server | |
|             |         | 証明書サービス | CertSvc |
|             |         | クラスタ サービス | ClusSvc |
|             |         | 分散ファイルシステム | DFS |
|             |         | 分散リンクトラッキング | TrkSvr |
|             |         | 分散トランザクション コーディネータ | MSDTC |
|             |         | イベント ログ | Eventlog |
|             |         | Fax サービス | Fax |
|             |         | ファイル複製 | NtFrs |
|             |         | ローカル セキュリティ機関 | LSASS |
|             |         | Remote Storage Notification | Remote_Storage<br>_User_Link |
|             |         | リモート記憶域サーバー | Remote_Storage<br>_Server |
|             |         | Systems Management Server 2.0 | |
|             |         | ターミナル サービス ライセンス | TermServLicensing |
|             |         | ターミナル サービス セッション ディレクトリ | Tssdis |
| **137/tcp/upd** | **NetBIOS 名前解決** | Computer ブラウザ | Browser | [**NetBios**](https://book.hacktricks.xyz/pentesting/137-138-139-pentesting-netbios)
|                 |                     | サーバー サービス  | lanmanserver|
|                 |                     | Windows インターネット ネーム サービス | WINS |
|                 |                     | Net Logon | Netlogon |
|                 |                     | Systems Management Server 2.0 | |
| **138/udp** | **NetBIOS Datagram Service** | Computer ブラウザ | Browser | [**NetBios**](https://book.hacktricks.xyz/pentesting/137-138-139-pentesting-netbios)
|             |                              | メッセンジャー | Messenger |
|             |                              | サーバー サービス | lanmanserver |
|             |                              | Net Logon | Netlogon |
|             |                              | 分散ファイル システム | Dfs |
|             |                              | Systems Management Server 2.0 | |
|             |                              | ライセンス ログ サービス | LicenseService |
| **139/tcp** | **NetBIOS Session Service** | Computer ブラウザ | Browser | [**NetBios**](https://book.hacktricks.xyz/pentesting/137-138-139-pentesting-netbios)
|             |                             | Fax サービス | Fax |
|             |                             | パフォーマンス ログと警告 | SysmonLog |
|             |                             | 印刷スプーラ | Spooler |
|             |                             | サーバー サービス | lanmanserver |
|             |                             | Net Logon | Netlogon |
|             |                             | リモート プロシージャ コール ロケータ | RpcLocator |
|             |                             | 分散ファイル システム | Dfs |
|             |                             | Systems Management Server 2.0 | |
|             |                             | ライセンス ログ サービス | LicenseService |
| 143/tcp | IMAP | Exchange サーバー | | [IMAP](https://book.hacktricks.xyz/pentesting/pentesting-imap)
| 161/udp | SNMP | SNMP サービス | SNMP | [SNMP](https://book.hacktricks.xyz/pentesting/pentesting-snmp)
| 162/udp | SNMP Traps Outbound | SNMP Trap サービス | SNMPTRAP | [SNMP](https://book.hacktricks.xyz/pentesting/pentesting-snmp)
| 270/tcp | MOM 2004 | Microsoft Operations Manager 2004 | MOM
| **389/tcp/upd** | **LDAP Server** | ローカル セキュリティ機関 | LSASS | [**LDAP**](https://book.hacktricks.xyz/pentesting/pentesting-ldap)
|                 |                 | 分散ファイル システム | Dfs |
| 443/tcp | HTTPS | HTTP SSL | HTTPFilter
|         |       | World Wide Web 発行サービス | W3SVC
|         |       | SharePoint Portal Server |
| **445/tcp/upd** | **SMB** | Fax サービス | Fax | [**SMB**](https://book.hacktricks.xyz/pentesting/pentesting-smb)
|                 |         | ライセンス ログ サービス | LicenseService
|                 |         | 印刷スプーラ | Spooler
|                 |         | サーバー サービス | lanmanserver
|                 |         | リモート プロシージャ コール ロケータ | RpcLocator
|                 |         | 分散ファイルシステム | Dfs
|                 |         | Net Logon | Dfs
| 500/udp | IPSec ISAKMP | IPSec サービス | PolicyAgent | [IPsec/IKE VPN](https://book.hacktricks.xyz/pentesting/ipsec-ike-vpn-pentesting)
| 515/tcp | Line Print Server (LPD) | LPDSVC | [LPD](https://book.hacktricks.xyz/pentesting/515-pentesting-line-printer-daemon-lpd)
| 548/tcp | File Server for Macintosh | File Server for Macintosh | MacFile
| 554/tcp | RTSP | Windows Media サービス | WMServer
| 563/tcp | NNTP over SSL | Network News Transfer Protocol | NntpSvc
| 593/tcp | RPC over HTTP | リモート プロシージャ コール | RpcSs
|         |               | Exchange Server |
| **636/tcp/upd** | **LDAP SSL** | ローカル セキュリティ機関 | LSASS | [**LDAP**](https://book.hacktricks.xyz/pentesting/pentesting-ldap)
| 993/tcp | IMAP over SSL | Exchange Server |
| 995/tcp | POP3 over SSL | Exchange Server |
| 1270/tcp | MOM-Encrypted | Microsoft Operations Manager 2000 | one point
| **1433/tcp** | **SQL over TCP** | Microsoft SQL Server | SQLSERVR | [**MSSQL**](https://book.hacktricks.xyz/pentesting/pentesting-mssql-microsoft-sql-server)
|              |                  | MSSQL$UDDI | SQLSERVR |
| 1434/udp | SQL Probe | Microsoft SQL Server | SQLSERVR
|          |           | MSSQL$UDDI | SQLSERVR
| 1645/udp | Legacy RADIUS | インターネット認証サービス | IAS
| 1646/udp | Legacy RADIUS | インターネット認証サービス | IAS
| 1701/udp | L2TP | ルーティングとリモート アクセス | RemoteAccess
| 1723/tcp | PPTP | ルーティングとリモート アクセス | RemoteAccess
| 1755/tcp/upd | MMS | Windows Media サービス | WMServer
| 1801/tcp/upd | MSMQ | メッセージ キュー | msmq
| 1812/udp | RADIUS 認証 | インターネット認証サービス | IAS
| 1813/udp | RADIUS アカウンティング | インターネット認証サービス | IAS
| 1900/udp | SSDP | SSDP Discovery Service | SSDPRSRV
| 2101/tcp | MSMQ-DCs | メッセージ キュー | msmq
| 2103/tcp | MSMQ-RPC | メッセージ キュー | msmq
| 2105/tcp | MSMQ-RPC | メッセージ キュー | msmq
| 2107/tcp | MSMQ-Mgmt | メッセージ キュー | msmq
| 2393/tcp | OLAP Services 7.0 | SQL Server: Downlevel OLAP Client Support |
| 2394/tcp | OLAP Services 7.0 | SQL Server: Downlevel OLAP Client Support |
| 2460/udp | MS Theater | Windows Media サービス | WMServer
| 2535/udp | MADCAP | DHCP サーバー? | DHCPServer
| 2701/tcp/upd | SMS リモート コントロール（コントロール） | SMS リモート コントロール エージェント |
| 2702/tcp/upd | SMS リモート コントロール（データ） | SMS リモート コントロール エージェント |
| 2703/tcp/upd | SMS Remote Chat | SMS リモート コントロール エージェント |
| 2704/tcp/upd | SMS Remote File Transfer | SMS リモート コントロール エージェント |
| 2725/tcp | SQL Analysis Services | SQL 2000 Analysis Server |
| 2869/tcp | UPNP | ユニバーサル プラグ アンド プレイ サービス | UPNPHost
| 2869/tcp | SSDP event notification | SSDP Discovery Service | SSDPRSRV
| 3268/tcp | グローバル カタログ サーバー | ローカル セキュリティ機関 | LSASS
| 3269/tcp | グローバル カタログ サーバー | ローカル セキュリティ機関 | LSASS
| 3343/udp | クラスタ サービス | クラスタ サービス | ClusSvc
| **3389/tcp** | **ターミナル サービス** | NetMeeting リモート デスクトップ共有 | mnmsrvc | [**RDP**](https://book.hacktricks.xyz/pentesting/pentesting-rdp)
|              |                     | ターミナル サービス | TermService |
| 3527/udp | MSMQ-Ping | メッセージ キュー | msmq
| 4011/udp | BINL | Remote Installs BINL サービス | BINLSVC
| 4500/udp | NAT-T | ルーティングとリモート アクセス | RemoteAccess
| 5000/tcp | SSDP legacy event notification | SSDP Discovery Service | SSDPRSRV
| 5004/udp | RTP | Windows Media サービス | WMServer
| 5005/udp | RTCP | Windows Media サービス | WMServer
| 42424/tcp | ASP.Net Session State | ASP.NET State Service | aspnet_state
| 51515/tcp | MOM-Clear | Microsoft Operations Manager 2000 | one point



### 参考文献

- [Microsoft ポート番号一覧](http://cya.sakura.ne.jp/pc/Port.htm)
- [HackTricks - HackTricks](https://book.hacktricks.xyz/)
