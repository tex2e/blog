---
layout:        post
title:         "wgetでWebサイトを巡回してリンク切れを確認する"
date:          2019-05-25
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

wget でWebサイトを巡回してリンク切れになっているリンクを見つける方法について。
以下のオプションをつけてサイトに wget すると、リンク切れのページがログの末尾に一覧で表示されます。

```command
wget --spider -o wget.log -e robots=off --wait 1 -r -p http://www.example.com
```

それぞれのオプションの意味は以下の通りです。

- `--spider` : ページをダウンロードして保存しない
- `-o wget.log` : 全てのログを wget.log に出力する
- `-e robots=off` : robots.txt を無視する[^wgetrc_commands]
- `--wait 1` : ページ取得ごとに行う待機時間
- `-r` : 再帰的にページを取得する
- `-p` : ページの表示に必要な CSS や画像なども全て取得する

リンク切れのリンクが見つかれば、wget.log の末尾に次のようなメッセージと共に、リンク切れの一覧が表示されます。

```log
Found 2 broken links.

http://www.example.com/hoge.html
http://www.example.com/hoge.css
```

もし、ローカル環境 (localhost) で建てているサーバに対してリンク切れチェックをする場合は、waitオプションは削除した方が高速に確認することができます。

```command
wget --spider -o wget.log -e robots=off -r -p http://localhost:4000/
```

以上です。


-----

[^wgetrc_commands]: wget のオプション -e で指定するコマンドの一覧は公式のドキュメント [GNU Wget 1.20 Manual -- 6.3 Wgetrc Commands](https://www.gnu.org/software/wget/manual/wget.html#Wgetrc-Commands) に書かれています。
