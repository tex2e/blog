---
layout:        post
title:         "AlwaysInstallElevatedのレジストリ値を確認する"
date:          2021-11-11
category:      Windows
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

Windowsインストーラを実行するときにAlwaysInstallElevatedが有効だと、常にシステム特権で実行されるため、侵入者による権限昇格が容易になってしまいます。
AlwaysInstallElevatedを悪用して権限昇格が可能かを確認するためには、レジストリ値を確認します。
AlwaysInstallElevatedのレジストリ値は以下のコマンドで確認することができます。

```cmd
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

この値が有効である（値が1である）場合、msiファイルは常にSYSTEM権限で実行されるので、権限昇格に利用されてしまいます。
必要がなければ、レジストリエディタで0に修正しましょう。

以上です。
