---
layout:        post
title:         "[PowerShell] N日経過したファイルを削除する"
type:          How-To
description:   "PowerShellのGet-ChildItemとLastWriteTimeプロパティ、AddDaysを組み合わせて、更新から指定日数経過したファイルを削除する方法を解説します。"
tags:          [powershell, windows, file-management]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-11-11T01:53:23Z
date:          2023-11-11
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

PowerShellで最後の書き込みからN日経過したファイルを削除するには、Get-ChildItem コマンドと .LastWriteTime プロパティと日付計算 (Get-Date や .AddDays など) を組み合わせることで削除できます。

例えば、特定のフォルダ以下にある全ファイルについて、30日以上経過したファイルを削除するには、以下の PowerShell を実行します。

```ps1
Get-ChildItem -Path "C:\workspace" -Recurse -File | `
  where { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force
```

以上です。
