---
layout:        post
title:         "BashのコマンドをPowerShellで実現する"
date:          2022-04-18
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

#### cp (ファイルやフォルダのコピー)
Copy-Item のエイリアスは cp です。
```ps1
# ファイルのコピー
PS> Copy-Item コピー元パス コピー先パス
# フォルダのコピー
PS> Copy-Item コピー元パス コピー先パス -Recurse
```

#### mv (ファイルやフォルダの移動・リネーム)
Move-Item のエイリアスは mv です。
```ps1
PS> Move-Item コピー元パス コピー先パス
```

#### rm (ファイルやフォルダの削除)
Remove-Item のエイリアスは rm です。
```ps1
PS> Remove-Item パス
```

#### cat (ファイルの内容を取得する)
Get-Content のエイリアスは cat です。
```ps1
PS> Get-Content パス
```
- [PowerShellでhead, tail (Get-Content) を使う](http://localhost:4000/blog/powershell/Get-Content-TotalCount-Tail)

#### &gt; (ファイルに内容を書き込む)
```ps1
PS> Set-Content パス 書き込む内容
```
Set-Content の代わりに、リダイレクトの &gt; を使うこともできます。

#### &gt;&gt; (ファイルに内容を追加で書き込む)
```ps1
PS> Add-Content パス 書き込む内容
```
Add-Content の代わりに、リダイレクトの &gt;&gt; を使うこともできます。

#### ls (フォルダ下の要素一覧を取得する)
Get-ChildItem のエイリアスは ls や dir です。
```ps1
PS> Get-ChildItem パス
```

#### pwd (ロケーションを取得する)
Get-Location のエイリアスは pwd です。
```ps1
PS> Get-Location
```

#### cd (ロケーションを設定する)
Set-Location のエイリアスは cd です。
```ps1
PS> Set-Location パス
```

#### dirname, basename (パスを分割する)
- -Parent : 親フォルダのみを取得
- -Leaf : ファイル名のみを取得

```ps1
PS> Split-Path C:\hoge\fuga\piyo.txt -Parent
C:\hoge\fuga
PS> Split-Path C:\hoge\fuga\piyo.txt -Leaf
piyo.txt
```

#### test -e (パスが存在するかどうか確認する)
Test-Path のエイリアスはありません。
```ps1
PS> Test-Path パス
```

#### sleep (待機する)
Start-Sleep のエイリアスは sleep です。
```ps1
PS> Start-Sleep 秒数
PS> Start-Sleep -Milliseconds ミリ秒
```

#### grep (文字列検索)
- [PowerShellでgrep (Select-String) を使う](./Select-String)

#### find (ファイル名検索)
- [PowerShellでfind (Get-ChildItem) を使う](./Get-ChildItem)

以上です。
