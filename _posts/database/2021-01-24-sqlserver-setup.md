---
layout:        post
title:         "SQL Serverへ別PCから接続できるようにする"
date:          2021-01-24
category:      Database
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SQL Serverを導入するときに別PC（クライアント側）からDBにリモート接続する方法についての備忘録。

まず、サーバには SQL Server と SQL Server Management Studio (SSMS) をインストールする。
SSMS は日本語版もあるので、日本語が好きな人は日本語版をダウンロードする。

- [SQL Server のダウンロード \| Microsoft](https://www.microsoft.com/ja-jp/sql-server/sql-server-downloads)
[SQL Server Management Studio (SSMS) のダウンロード - SQL Server Management Studio (SSMS) \| Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)

### DB設定

次に、サーバ側でSSMSを起動してデフォルト値でログインする。

- サーバ名：PCName\SQLEXPRESS
- 認証方法：Windows Authentication

接続後、DBの設定を行う。

1. DBのプロパティ > セキュリティ から、サーバ認証を「SQL Server認証モードとWindows認証モード」に変更する。
2. DBのプロパティ > 接続 から「このサーバーへのリモートサーバ接続を許可する」にチェックが入っていることを確認する。
3. DB > セキュリティ > ログイン を右クリックして「New Login...」をクリックする。
  - ログイン名を「SQL Server認証」とし、パスワードに自分の好きなユーザ名とパスワードを入力する。
4. DB > セキュリティ > ログイン 直下に追加したログインユーザが存在することを確認する。

### SQL Server

次に、SQL Server の設定を行う。

1. SQL Server 構成マネージャーを起動する。
2. SQL Server 構成マネージャー > SQL Server ネットワークの構成 > SQLEXPRESSのプロトコル を選択する。
3. TCP/IPを有効にする。
4. TCP/IPのプロパティ > プロトコル
   - すべて受信待ち：はい
5. TCP/IPのプロパティ > IPアドレス
   - IPALL > TCPポート：1433
6. SQL Server 構成マネージャー > SQL Server のサービス > SQL Server再起動

### SQL ServerBrowser

SQL Serverと一緒にインストールされる SQL ServerBrowser の設定も行う。

1. SQL Server 構成マネージャー > SQL Server のサービス > SQL ServerBrowser起動
2. サービス > SQL Server Browserのプロパティ > スタートアップの種類：自動

### Windows Firewall

最後に、Windowsファイアウォールの設定を行う。

1. 詳細設定 > 受信の規制 > 新しい規則...
   1. SQL Serverの通信設定
      - プロトコルおよびポート：TCP/1433
      - プロファイル：ドメイン、プライベート、パブリック
      - 名前：SQL Server (tcp/1433)
   2. SQL ServerBrowserの通信設定
      - プロトコルおよびポート：UDP/1434
      - プロファイル：ドメイン、プライベート、パブリック
      - 名前：SQL ServerBrowser (udp/1434)


### 動作確認

固定IPを設定してから、確認を行う。

1. サーバ側でSQL Serverに以下で接続できるか確認する
   - 認証方法：「SQL Server認証」
   - サーバ名：「固定IP\SQLEXPRESS」
   - ユーザ名・パスワード：自分で設定した値
2. クライアント側でSQL Serverに以下で接続できるか確認する
   - 認証方法：「SQL Server認証」
   - サーバ名：「固定IP\SQLEXPRESS」
   - ユーザ名・パスワード：自分で設定した値

1.で失敗する場合はDBのインストール・設定ミス、
2.で失敗する場合はファイアウォールやSQL ServerBrowserの設定ミスが考えられます。

以上です。



### 参考文献

- [SQL Server > エラー:18456 でログインできない場合 - Qiita](https://qiita.com/sugasaki/items/a95c2495085e32851707)
- [SQL Serverに外部から接続する備忘録 \| 沙羅.com](https://sara.jiin.com/other/sql.html)
- [SQL Server Express にリモート接続 - クリエイティブWeb](https://creativeweb.jp/fc/remote/)
