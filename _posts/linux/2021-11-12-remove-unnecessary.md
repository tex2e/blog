---
layout:        post
title:         "不要なWebコンテンツファイルを削除する"
date:          2021-11-12
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Webコンテンツで不要なファイルを必要以上に公開していないかを調べるためのfindを使った簡易コマンドについて説明します。

以下のようにfindコマンドを利用して、Webコンテンツ内の不要なファイルや接続元IPを制限する必要があるファイルを見つけます。
```
find /var/www -name '*readme*' -o -name '*README*' -o -name '*admin*' -o -name '*install*' -o -name '*db*' -o -name '*dump*' -o -name '*tmp*' -o -name '*phpinfo*' -o -name '*config*' -o -name '*shell*' | grep -e 'readme\|README\|admin\|install\|db\|dump\|tmp\|phpinfo\|config\|shell'
```
- readme / README : CMSのバージョン情報が書かれている可能性あり
- admin : 管理者用のログイン画面
- install : インストールコマンドなどが書かれている可能性あり
- db / dump : データベースのダンプファイル
- tmp : 一時ファイルから編集中や編集前の設定・ソースコードが閲覧される可能性あり
- phpinfo : PHPの設定内容が書かれている可能性あり
- config : 設定ファイルが閲覧される可能性あり

内容を確認し、必要がなければ削除 (rm や mv) や権限を変更（chown と chmod など）します。

以上です。
