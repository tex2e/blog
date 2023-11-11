---
layout:        post
title:         "シェルスクリプト実行で「無効なオプション」でエラー終了する時の対処法"
date:          2023-11-12
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsでシェルスクリプトを作成し、改行コードがCR/LFのままLinuxにアップロードしてから、シェルスクリプトを実行すると「無効なオプション」もしくは「invalid option」がエラーで表示されます。

```bash
$ main.sh
: 無効なオプション
```

原因は改行コードがCR/LFになっているためです。
bashが実行するファイルは、改行コードが間違っていると、1行目のshebangの読み込み時に失敗するようです。
LFに変更すると想定通り動くようになります。

以上です。
