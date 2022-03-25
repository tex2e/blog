---
layout:        post
title:         "systemctlで disabled かつ start しているサービスを調べる"
date:          2021-12-05
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

システムを再起動するときに、自動起動に設定されていないサービスがあると大変なので、起動しているのに自動起動の設定がされていないサービスを探す方法について説明します。

systemctlでシステム起動時はサービス起動しない (disabled) が、現在は稼働 (start) しているサービスを見つけるためのコマンドは以下の通りです。
コマンドを実行して緑色になっている部分があれば、disabed かつ start しているサービスです。
```bash
~]# systemctl list-unit-files -t service | grep disabled \
  | grep -v '@' | awk '{print $1}' | xargs systemctl status
```
それぞれのコマンドの説明は以下の通りです。
- `systemctl list-unit-files -t service` : 全サービスを表示する
- `| grep disabled` : システム起動時に起動しないサービスだけ表示
- `| grep -v '@'` : httpd@.service のような末尾に @ があるものは除外して表示
- `| awk '{print $1}'` : サービス名のみ表示
- `| xargs systemctl status` : サービスの状態を表示

必要に応じて `systemctl enabled サービス名` で自動起動に登録してから再起動します。

以上です。
