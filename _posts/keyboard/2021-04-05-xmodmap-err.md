---
layout:        post
title:         "Xmodmap実行時にunable to open display<br>がでたときの解決方法"
titlemenu:     "Xmodmap実行時にunable to open displayがでたときの解決方法"
date:          2021-04-04
category:      Keyboard
cover:         /assets/cover1.jpg
redirect_from: /keyboard/xmodmap-error
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Kali LinuxでXmodmapの設定を適用するために `xmodmap ~/.Xmodmap` と実行したら、「xmodmap:  unable to open display 'localhost:0.0'」というエラーが出たので、そのときの対処法について説明します。

対処方法は簡単で、環境変数 LIBGL_ALWAYS_INDIRECT=1 を設定してから xmodmap を実行するだけで解決しました。

.bashrc や .zshrc で環境変数の設定をしてから、Xmodmapの設定を適用させましょう。

```bash
if [[ -f "$HOME/.Xmodmap" ]]; then
  export DISPLAY=:0.0
  export LIBGL_ALWAYS_INDIRECT=1
  xmodmap "$HOME/.Xmodmap" &> /dev/null
fi
```

以上です。


### 参考文献

- [WSL2でのError: Can't open display問題の解決 - Qiita](https://qiita.com/Engr_Coal33/items/6aabb6932b53bd43b843)
