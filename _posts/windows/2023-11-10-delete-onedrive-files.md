---
layout:        post
title:         "OneDriveを削除してディスク容量を確保する"
date:          2023-11-10
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windows10ではストレージサービスのOneDriveが標準で入っているため、削除することでディスクの空き容量を増やすことができます。

### 1. OneDriveアンインストール

以下の手順でOneDriveをアンインストールします。

- Windowsの設定 > アプリ > アプリと機能 >「OneDrive」を選択 > アンインストール

### 2. OneDriveのキャッシュファイルを削除

アンインストールしても残る以下のフォルダを削除します（USERNAMEはユーザ名）。

- C:\Users\USERNAME\AppData\Local\Microsoft\OneDrive\

複数のログインユーザに対してまとめてOneDrive関連ファイルを削除するには、以下のPowerShellを管理者で実行すると効率よくできます。
REGEX にはユーザ名の正規表現を指定して、対象のユーザを絞ることも可能です。

```ps1
gci -Path C:\Users -Directory | where { $_ -match "REGEX" } | foreach {
    ls C:\Users\$_\AppData\Local\Microsoft\OneDrive\
    Remove-Item -Recurse -Force C:\Users\$_\AppData\Local\Microsoft\OneDrive\
}
```

大体、1ユーザにつき100MB程度のキャッシュファイルが作られるので、10ユーザで1GBくらい容量を空けることができます。

以上
