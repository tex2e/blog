---
layout:        post
title:         "PowerShellでプログレスバーを表示する"
menutitle:     "PowerShellでプログレスバーを表示する (Write-Progress)"
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
