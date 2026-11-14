---
layout:        post
title:         "[PowerShell] 多階層のフォルダを一発で作成する (mkdir -p)"
type:          How-To
description:   "PowerShellのNew-Itemに-ItemType Directoryと-ErrorAction SilentlyContinueを指定し、mkdir -p相当の多階層フォルダを作成する方法を説明します。"
tags:          [powershell, windows, directory, new-item]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-01-28T03:59:38Z
sources:
  - id:        ref-1
    resource:  https://stackoverflow.com/questions/47357135/powershell-equivalent-of-linux-mkdir-p
    title:     "powershell equivalent of linux \"mkdir -p\"? - Stack Overflow"
date:          2024-01-28
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

PowerShellでLinuxの mkdir -p と同じことをするには、New-Item コマンドレットで実現でき、引数に -ItemType Directory でディレクトリとして作成され、-ErrorAction SilentlyContinue で存在済みのフォルダであってもエラーしないようにすることができます。

コマンド実行例は以下の通りです。

```ps1
New-Item ".\path\to\dir" -ItemType Directory -ErrorAction SilentlyContinue
```

以上です。

### 参考資料
- [powershell equivalent of linux "mkdir -p"? - Stack Overflow](https://stackoverflow.com/questions/47357135/powershell-equivalent-of-linux-mkdir-p)
