---
layout:        post
title:         "nmcliコマンドでLinuxサーバの固定IPの変更をすぐに反映する"
date:          2024-11-27
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

nmcliコマンドを使うことで、nmtuiで変更したLinuxサーバの固定IPの変更をすぐに反映することができます。


まず初めに、自身のサーバのIPをGUIで変更します。
```bash
$ nmtui
```

次に、ネットワークデバイスの一覧を表示します。
```bash
$ nmcli device
```
上記でIPアドレスを変更したいネットワークデバイス名を確認してください。

最後に、指定したネットワークデバイスを有効化します。ここでIPの変更を反映させます。
ens34はデバイス名なので、各環境に合わせて変えてください。
```bash
$ nmcli device connect ens34
```

以上です。
