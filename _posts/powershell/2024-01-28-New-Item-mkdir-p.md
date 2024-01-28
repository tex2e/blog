---
layout:        post
title:         "PowerShell で多階層のフォルダを一発で作成する (mkdir -p)"
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
