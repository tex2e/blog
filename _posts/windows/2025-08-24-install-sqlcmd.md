---
layout:        post
title:         "[Windows] sqlcmdコマンドをインストールする"
date:          2025-08-24
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

Windowsに最新のsqlcmd (ver18) をインストールする手順について説明します。

### 背景

前提として、SQL Serverをインストールしていると、古いバージョンのsqlcmd（ver9）やosqlコマンドが使えるのですが、暗号化通信のTLSのバージョンが古くてSQL Serverと通信ができないため、sqlcmdを最新化することで通信できるようにするのが目的となります。

### インストール手順

まず、以下のサイトにアクセスして、最新のsqlcmdを確認します。

[https://github.com/microsoft/go-sqlcmd/releases](https://github.com/microsoft/go-sqlcmd/releases)

（2025/8時点で）Latestと書かれている安定板のv1.8.2の「sqlcmd-amd64.msi」をダウンロードして、インストーラを起動します。
インストールが完了したら、PowerShellを起動して、`sqlcmd -?` を入力し、バージョンが表示されるか確認してください。

SQL Serverとの接続まで確認したいときは、以下のコマンドを実行してください（IPアドレス、ユーザー名、パスワードは環境に合わせて適宜変更してください）。

```
sqlcmd -S IPアドレス,1433 -U SA -P 'YourPassword'
```

補足：sqlcmd.exeの既定のインストール先フォルダはWindowsの場合は以下になります。

```
C:\Program Files\SqlCmd\sqlcmd.exe
```

以上です。
