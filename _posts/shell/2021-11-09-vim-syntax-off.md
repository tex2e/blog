---
layout:        post
title:         "[Vim] シンタックスハイライトを暗い背景色に合わせる"
date:          2021-11-09
category:      Shell
cover:         /assets/cover14.jpg
redirect_from: /linux/vim-syntax-off
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellのsshコマンドを利用して、Linuxに入った後にvimを使うと、シンタックスハイライトの色がPowerShellのデフォルト背景色と一致して読みにくくなる現象があるので、その時のvimの設定を修正するための方法について説明します。

vimで開いた後に、以下を入力するとシンタックスハイライトを無効化します。
無効化すると文字色が白になります。
```
:syntax off
```

もしくは、暗い背景色に合わせてシンタックスハイライトを見やすいものに変更します。
```
:set background=dark
```

vimを起動する毎に :set background=dark と入力するのが面倒な場合は、vimrc ファイルに設定を記述しておきます。
```bash
cat <<EOS >> ~/.vimrc
set background=dark
EOS
```

以上です。
