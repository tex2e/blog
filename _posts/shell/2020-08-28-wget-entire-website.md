---
layout:        post
title:         "wgetでサイト全体をダウンロードする"
date:          2020-08-28
category:      Shell
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---


Webサイトから全てのファイルをダウンロードするためのwgetコマンドの使い方について説明します。


### すぐに実行したい人向け

http://site/path をダウンロードしたいサイトに変更してからコマンドを実行します。

```bash
$ wget -m -p -E -k -np http://site/path/
```

### オプションについての説明

上記の省略形オプションの正式名を以下に示します。
wgetの出力を静かにしてほしいとか、ダウンロードしたくないファイル形式があるとか、wgetの動作を変更したいときはオプションを変更する必要があります。

```bash
$ wget --mirror \
       --page-requisites \
       --adjust-extension \
       --convert-links \
       --no-parent \
       --quiet --show-progress \
       --reject '*.exe,*.dmg,*.zip,*.iso' \
       http://site/path/
```

- `-m`, `--mirror`: タイムスタンプを確認して、新しいファイルのみダウンロードする
- `-p`, `--page-requisites`: ページ内の画像、CSS、JSなどもダウンロードする
- `-E`, `--adjust-extension`: text/htmlをダウンロードしたときに、URLの末尾に拡張子 (`\.[Hh][Tt][Mm][Ll]?`) がない場合、ファイル名の末尾に .html を追加して保存する。
- `-k`, `--convert-links`: リンクへの参照を相対パスに変換し、ローカル環境でもリンクを辿れるようにする
- `-np`, `--no-parent`: 指定したURLの直下にあるファイルのみダウンロードする (親ディレクトリにあるファイルは取得しない)
- `--quiet --show-progress`: 進捗を1ファイル1行で表示する
- `-R <rejlist>`, `--reject <rejlist>`: ダウンロードしないファイルの設定する。複数ある場合はカンマ区切りで設定する。

大量にリクエストを送信して、相手に攻撃されていると思われないようにするために、リクエスト間で一定時間待機する配慮も必要です。

- `-w <seconds>`, `--wait=<seconds>`: リクエスト間の待機時間(秒)を設定する
- `--random-wait`: 待機時間にランダムに0.5～1.5の範囲で掛け算した数だけ待機にする。例えば`-w`で10秒を設定すると、5秒～15秒の間でランダムな待機時間が発生する

```bash
$ wget --mirror \
       --page-requisites \
       --adjust-extension \
       --convert-links \
       --no-parent \
       --quiet --show-progress \
       --reject '*.exe,*.dmg,*.zip,*.iso' \
       --wait=2 \
       --random-wait \
       http://site/path/
```

節度を持って楽しいクローリング生活を送りましょう

以上です。
