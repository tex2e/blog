---
layout:        post
title:         "PowerShellの出力を色付けする"
menutitle:     "PowerShellの出力を色付けする (Write-Host)"
date:          2022-04-15
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap: false
# feed:    false
---

PowerShellで色の付いた文字を出力するには、Write-Host コマンドの -ForegroundColor や -BackgroundColor オプションを使用します。

### 文字色
以下は、色の出力を確認するためのスクリプト例です。
```ps1
$colors = @'
Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow Gray
DarkGray Blue Green Cyan Red Magenta Yellow White
'@ -split "\s"

foreach ($color in $colors) {
    Write-Host $color -ForegroundColor $color
}
```
実行すると以下のように色付けされます。
<figure>
<img src="{{ site.baseurl }}/media/post/powershell/Write-Host-ForegroundColor.png" width=450px />
<figcaption>ForegroundColor による文字色の設定</figcaption>
</figure>

<br>

### 背景色
以下は、背景色の出力を確認するためのスクリプト例です (上記の続きです)。
```ps1
foreach ($color in $colors) {
    Write-Host $color -BackgroundColor $color
}
```
実行すると以下のように色付けされます。
<figure>
<img src="{{ site.baseurl }}/media/post/powershell/Write-Host-BackgroundColor.png" width=450px />
<figcaption>BackgroundColor による背景色の設定</figcaption>
</figure>

<br>

### エラー/成功/失敗メッセージを出力するための関数
色の出力を使って、エラーや成功・失敗のメッセージの色を変えることで、コンソールを読みやすくすることができます。
以下は、メッセージ色付け用の関数の例です。
```ps1
function Write-Error($msg) {
    Write-Host "[" -NoNewline
    Write-Host "!" -NoNewline -ForegroundColor Red
    Write-Host "] " -NoNewline
    Write-Host $msg
}

function Write-Success($msg) {
    Write-Host "[" -NoNewline
    Write-Host "+" -NoNewline -ForegroundColor Green
    Write-Host "] " -NoNewline
    Write-Host $msg
}

function Write-Failed($msg) {
    Write-Host "[" -NoNewline
    Write-Host "-" -NoNewline -ForegroundColor Red
    Write-Host "] " -NoNewline
    Write-Host $msg
}

Write-Error "Test text"
Write-Success "Test text"
Write-Failed "Test text"
```
実行すると以下のようになります。
<figure>
<img src="{{ site.baseurl }}/media/post/powershell/Write-Host-Error-Success-Failed.png" width=450px />
</figure>

以上です。

#### 参考文献
- [Write-Host (Microsoft.PowerShell.Utility) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host?view=powershell-7.2)
