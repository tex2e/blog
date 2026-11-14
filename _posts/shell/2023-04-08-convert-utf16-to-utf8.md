---
layout:        post
title:         "iconvでエンコードをUTF16をUTF8に変換する"
type:          How-To
description:   "fileコマンドでUTF-16LEを判定し、iconvを使って複数テキストファイルの文字コードをUTF-8へ一括変換する手順。"
tags:          [shell, bash, iconv, utf8]
status:        stable
stale_after:   2026-04-09T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-04-09T10:12:37Z
date:          2023-04-08
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

LinuxのBashでUTF16をUTF8に変換する方法について説明します。
エンコードを変更するには iconv コマンドを使用します。

```bash
iconv -f UTF-16LE -t UTF-8 ファイル名
```

<br>

### UTF16からUTF8へ変換する

エンコーディングがUTF16のTXTファイルをまとめてUTF8に変換するには、以下のシェルスクリプトを実行します。

```bash
for filename in *.txt; do
  filetype=$(file -i $filename)
  if echo $filetype | grep 'charset=utf-16le' &>/dev/null; then
    iconv -f UTF-16LE -t UTF-8 "$filename" > "$filename.new" \
    && mv "$filename.new" "$filename"
  fi
done
```

ファイルのエンコードを特定するには、file コマンドを使用します。
file -i の結果に「charset=utf-16le」という文字列が含まれる場合のみ、iconvでエンコードを変換します。
iconvの入力が「UTF-16LE」、出力が「UTF-8」とすることで、エンコードを変換することができます。

※UTF-16LE以外のファイルを入力するとエラーになるため、if文で入力をチェックする処理を追加する必要があります。

以上です。
