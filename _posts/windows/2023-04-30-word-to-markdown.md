---
layout:        post
title:         "pandocでWordファイル(.docx)をMarkdownへ変換する"
date:          2023-04-30
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

Word (docx) で書かれた過去の資産をMarkdown化するには pandoc コマンドを使用します。
pandoc コマンドは別途インストールが必要です。

なお、doc ファイルの場合は Word で docx に変換する作業が必要になります。

```bash
$ pandoc -s 入力.docx --wrap=none --extract-media=media -t gfm -o 出力.md
```

以下は、Markdownへ変換する際のオプションの説明です。

- `--wrap=none`
    - 出力時のwrap（枠を超えないように複数行に折り返し指定する処理）の設定をします
    - noneを指定することで、1行を72文字で折り返す処理を無効化します
    - ※デフォルトだと勝手にwrapされてしまう
- `--extract-media=DIR`
    - 出力先のフォルダを引数で指定します
    - docxに埋め込まれたpngなどが抽出されて、指定した DIR フォルダ内に格納されます
- `-t gfm`
    - 出力形式を指定します
    - gfm (GitHub-Flavored Markdown) はGitHub形式のMarkdownで出力します
    - ※デフォルトだとPandoc形式のMarkdownになってしまう

以上です。

### 参考資料

- [Pandoc - Pandoc User’s Guide](https://pandoc.org/MANUAL.html)
- [Wordファイル(.docx)をMarkdownへ変換する](https://gist.github.com/tomo-makes/b03e910ea7095bbe2c98de5be828dfba)
