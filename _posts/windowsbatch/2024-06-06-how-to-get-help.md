---
layout:        post
title:         "Windowsのコマンドプロンプトのhelpの閲覧方法"
date:          2024-06-06
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsのコマンドプロンプトのhelpの閲覧方法について説明します。

### 1. helpコマンド

helpコマンドは組み込みのコマンドのヘルプを閲覧するためのコマンドです。

```cmd
C:\> help time

システム時刻を表示または設定します。

TIME [/T | 時刻]

パラメーターの指定がなければ、現在の設定が表示され、新しい時刻を入力できる
プロンプトになります。変更しない場合は、Enter キーを押してください。
```

### 2. オプション `/?`

いくつかのコマンドでは、引数に `/?` を追加すると help が表示されます。

```cmd
C:\> ipconfig /?

使用法:
    ipconfig [/allcompartments] [/? | /all |
                                 /renew [adapter] | /release [adapter] |
                                 /renew6 [adapter] | /release6 [adapter] |
                                 /flushdns | /displaydns | /registerdns |
                                 /showclassid adapter |
                                 /setclassid adapter [classid] |
                                 /showclassid6 adapter |
                                 /setclassid6 adapter [classid] ]
```

### 3. MS公式ドキュメント

Microsoftが公開している公式のドキュメントには、コマンドラインで実行できるコマンドの一覧と、それらの使用方法の詳細な説明が書かれています。
インターネットに接続できる環境であれば、MS公式ドキュメントを読むのが理解するのに最も効率的です。

- [Windows commands \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

### 4. ss64

ss64というWebサイトでは、cmd、PowerShell、Bashなど、コマンドライン関連の便利なクイックリファレンスが公開されています。

- [An A-Z Index of Windows CMD commands - SS64.com](https://ss64.com/nt/)


以上です。
