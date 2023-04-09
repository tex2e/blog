---
layout:        post
title:         "sedでDOM付きUTF-8からDOMを削除する"
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
