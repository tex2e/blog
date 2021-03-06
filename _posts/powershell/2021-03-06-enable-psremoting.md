---
layout:        post
title:         "PowerShellをリモート実行する"
date:          2021-03-06
category:      PowerShell
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

PowerShellでSSHのように接続するには次の手順で行います。

1. サーバ側で全てのネットワーク接続の種類をPrivateまたはDomainにする
2. サーバ側で管理者権限で `Enable-PSRemoting` を実行する
3. クライアント側で管理者権限で WinRM を起動する
4. クライアント側で管理者権限で TrustedHosts にサーバIPを追加する
5. クライアントでPowerShellをリモート実行（サーバで実行）します

### 1. サーバ側で全てのネットワーク接続の種類をPrivateまたはDomainに変更

ネットワーク接続の種類が1つでもPublicになっていると `Enable-PSRemoting` でエラーになります。

```cmd
PS> Enable-PSRemoting
WinRM は要求を受信するように更新されました。
WinRM サービスの種類を正しく変更できました。
WinRM サービスが開始されました。

Set-WSManQuickConfig : <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" M
achine="localhost"><f:Message><f:ProviderFault provider="Config provider" path="%systemroot%\system32\WsmSvc.dll"><f:WS
ManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="サーバ名"><f:Mes
sage>このコンピューターのネットワーク接続の種類の 1 つが Public に設定されているため、WinRM ファイアウォール例外は機能
しません。 ネットワーク接続の種類を Domain または Private に変更して、やり直してください。 </f:Message></f:WSManFault><
/f:ProviderFault></f:Message></f:WSManFault>
発生場所 行:116 文字:17
+                 Set-WSManQuickConfig -force
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Set-WSManQuickConfig]、InvalidOperationException
    + FullyQualifiedErrorId : WsManError,Microsoft.WSMan.Management.SetWSManQuickConfigCommand
```

対応方法は、全てのネットワーク接続のカテゴリをPublicからPrivate（またはDomain）に変更します。
ネットワーク接続カテゴリの変更は `Set-NetConnectionProfile` コマンドレットを使います。
管理者権限のPowerShellで以下を実行します。

```cmd
PS> Get-NetConnectionProfile

Name             : Wi-Fiの名前
InterfaceAlias   : Wi-Fi
InterfaceIndex   : 16
NetworkCategory  : Private
IPv4Connectivity : Internet
IPv6Connectivity : NoTraffic

Name             : 識別されていないネットワーク
InterfaceAlias   : vEthernet (Default Switch)
InterfaceIndex   : 20
NetworkCategory  : Public
IPv4Connectivity : NoTraffic
IPv6Connectivity : NoTraffic

PS> Get-NetConnectionProfile -Name "識別されていないネットワーク" | Set-NetConnectionProfile -NetworkCategory private
```

### 2. サーバ側で管理者権限で `Enable-PSRemoting` を実行

設定したら再度 `Enable-PSRemoting` コマンドレットを実行すると成功します。

```cmd
PS> Enable-PSRemoting
WinRM は既にこのコンピューター上で要求を受信するように設定されています。
WinRM はリモート管理用に更新されました。
WinRM ファイアウォールの例外を有効にしました。
ローカル ユーザーにリモートで管理権限を付与するよう LocalAccountTokenFilterPolicy を構成しました。
```

### 3. クライアント側で管理者権限で WinRM を起動

WinRM（Windows Remote Management）という、Windowsを遠隔操作をする仕組みを使います。
クライアント側で管理者権限で以下を実行します。

```cmd
PS> net start WinRM
```

### 4. クライアント側で管理者権限で TrustedHosts にサーバIPを追加

管理者権限で `Set-Item WSMan:\localhost\Client\TrustedHosts -Value "サーバIP"` を実行します。

```cmd
PS> Set-Item WSMan:\localhost\Client\TrustedHosts -Value "サーバIP"
PS> Get-Item WSMan:\localhost\Client\TrustedHosts

   WSManConfig: Microsoft.WSMan.Management\WSMan::localhost\Client

Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   TrustedHosts                                   サーバIP
```

登録したIPを削除したいときは、`Clear-Item WSMan:\localhost\Client\TrustedHosts` を実行すれば信頼済みホストから削除されます。


### 5. PowerShellをリモート実行

サーバ名とログインユーザ名を指定して `Enter-PSSession` を実行すると、対話的なプロンプトが表示され、コマンドレットを入力するとサーバで実行されます。
なお、ユーザ名は「サーバ名\ログイン名」です。

```cmd
PS> Enter-PSSession -ComputerName サーバIP -Credential ユーザ名
(パスワード入力)
[サーバIP]: PS>
```

リモートPCにバッチ操作をしたいときは、`Invoke-Command` を使うと、コマンドを連続して実行することができます。
ScriptBlock 内に書いたコマンドがリモートで実行されます。

```cmd
PS> Invoke-Command -ScriptBlock { hostname } -ComputerName サーバIP -Credential ユーザ名
```

ScriptBlock に関数を渡したい場合は、`$function:関数名` を指定します。

```cmd
function MyTest {
  echo "Hello, $(hostname)!"
}

Invoke-Command -ScriptBlock $function:MyTest -ComputerName サーバIP -Credential ユーザ名
```

実行ファイルを指定したい場合は、FilePath 引数を使います。

```cmd
Invoke-Command -FilePath C:\path\to\file.ps1 -ComputerName サーバIP -Credential ユーザ名
```


以上です。



### 参考文献

- [PowerShellを使ってリモートでコマンドを実行する方法 - Qiita](https://qiita.com/awsmgs/items/8ceea2bf2d47486805f1)
- [PowerShell Enable-PSRemotingを実行するとSet-WSManQuickConfig でエラーになる場合の対処法 - 元「なんでもエンジニ屋」のダメ日記](https://nasunoblog.blogspot.com/2015/06/powershell-enable-psremoting-error-occer-public-network.html)
- [PowerShell ネットワークのカテゴリを変更する～PublicからPrivateへ - 元「なんでもエンジニ屋」のダメ日記](https://nasunoblog.blogspot.com/2014/12/powershell-how-to-change-network-category-public-to-private.html)
- [PowerShellでリモートからコマンドを実行する - Masato's IT Library](https://mstn.hateblo.jp/entry/2016/09/13/193124)
- [Enable-PSRemoting (Microsoft.PowerShell.Core) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/Microsoft.PowerShell.Core/Enable-PSRemoting?view=powershell-5.1)
- [Invoke-Command (Microsoft.PowerShell.Core) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-5.1)
