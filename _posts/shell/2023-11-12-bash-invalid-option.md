---
layout:        post
title:         "シェルスクリプト実行で「無効なオプション」でエラー終了する時の対処法"
type:          Troubleshooting
description:   "Windowsで作成したシェルスクリプト実行時にCRLF改行が原因で無効なオプションエラーが出る事象とLF変換による対処法を解説。"
tags:          [shell, bash, crlf, troubleshooting]
status:        stable
stale_after:   2026-11-11T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-11-11T01:53:02Z
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
