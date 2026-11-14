---
layout:        post
title:         "[PowerShell] 進捗を表すプログレスバーを表示する (Write-Progress)"
type:          How-To
description:   "PowerShellのWrite-Progressコマンドレットと-PercentCompleteオプションを使ってコンソール上に進捗バーを表示する方法を紹介します。"
tags:          [powershell, write-progress, console]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-04-15T10:49:11Z
sources:
  - id:        ref-1
    resource:  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress?view=powershell-7.2
    title:     "Write-Progress (Microsoft.PowerShell.Utility) - PowerShell \\| Microsoft Docs"
date:          2022-04-16
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

PowerShellでプログレスバーを表示するには、Write-Progress コマンドレットを使います。
-PercentComplete で 1〜100 の数字を指定することで、進捗を表現します。

```ps1
$title = "Process in Progress"
for ($i = 1; $i -le 100; $i++) {
    Write-Progress -Activity $title -Status "$i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 200
}
```

プログレスバーは、コンソールの上部に出力されます。

<figure>
<img src="{{ site.baseurl }}/media/post/powershell/Write-Progress.png" width=650px />
<figcaption>Write-Progress の出力</figcaption>
</figure>

以上です。

#### 参考文献
- [Write-Progress (Microsoft.PowerShell.Utility) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress?view=powershell-7.2)
