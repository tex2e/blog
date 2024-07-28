---
layout:        post
title:         "[PowerShell] ローカルユーザのパスワードを変更する"
date:          2022-11-10
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellでローカルユーザのパスワードを変更する方法について説明します。

まず、Get-LocalUser でローカルのユーザーの一覧を取得し、パスワード変更したいユーザ名を確認します。

```powershell
PS> Get-LocalUser

Name               Enabled Description
----               ------- -----------
tex2e              True
```

次に、Set-LocalUser でパスワード変更を行います。引数 -Name でユーザ名、-Password でパスワードを指定します。
-Password にはセキュア文字列オブジェクトを渡さないといけないので、事前に ConvertTo-SecureString コマンドレットを使ってオブジェクトを生成して $PASSWORD 変数に格納しています。

```powershell
PS> $PASSWORD = ConvertTo-SecureString -AsPlainText -Force -String "VeryStrongP@ssw0rd"
PS> Set-LocalUser -Name "tex2e" -Password $PASSWORD
```

対象ユーザのパスワード変更が成功すると、何も出力されません。
失敗した場合はエラーが表示されます。

以上です。


### 参考文献

- [Set-LocalUser (Microsoft.PowerShell.LocalAccounts) - PowerShell \| Microsoft Learn](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.localaccounts/set-localuser?view=powershell-5.1)
- [ConvertTo-SecureString (Microsoft.PowerShell.Security) - PowerShell \| Microsoft Learn](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.3)
