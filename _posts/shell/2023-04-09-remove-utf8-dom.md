---
layout:        post
title:         "sedでDOM付きUTF-8からDOMを削除する"
type:          How-To
description:   "sedコマンドで先頭のバイト列xEFxBBxBFを置換し、複数テキストファイルからUTF-8のBOM（記事内表記DOM）を一括削除する方法。"
tags:          [shell, bash, sed, utf8]
status:        stable
stale_after:   2026-04-09T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-04-09T10:12:37Z
date:          2023-04-09
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

LinuxのBashでファイルからUTF-8のDOM情報を削除する方法について説明します。
テキストファイルからUTF-8のDOM情報を削除するには、sedコマンドを使用します。

```bash
sed -i '1s/^\xEF\xBB\xBF//' ファイル名
```

<br>

### UTF-8のDOM情報を削除する

複数のファイルからまとめてUTF-8のDOM情報を削除するには、以下のシェルスクリプトを実行します。

```bash
for filename in *.txt; do
  sed -i '1s/^\xEF\xBB\xBF//' "$filename"
done
```

sed でマッチした場合のみ置換されます。そのため、DOMが付いていないテキストファイルは、そのまま変わりません。

以上です。
