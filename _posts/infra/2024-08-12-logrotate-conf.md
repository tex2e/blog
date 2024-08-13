---
layout:        post
title:         "logrotateの設定ファイル"
date:          2024-08-12
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

logrotateとは、ログファイルをローテーションし、必要に応じて圧縮などを行うシステムのことです。
以下では、LinuxにおけるLogrotateの設定方法について説明します。

logrotateの動作全般に関する設定は、/etc/logrotate.conf に記載します。

**/etc/logrotate.conf**

```conf
weekly
su root adm
rotate 4
create
include /etc/logrotate.d
```

- ログファイルをローテーションする間隔：
    - `daily` : 1日ごと
    - `weekly` : 1週間ごと
    - `monthly` : 1ヶ月ごと
- `su root adm` : admグループのrootユーザでファイル作成などの処理を行う
- `rotate 4` : 4世代分のログファイルを保存する
- `create` : ローテーションした後に新規ファイルを作成する
- `include /etc/logrotate.d` : 指定ディレクトリ下にある設定ファイルを読み込む

<br>

その他、logrotateによるログローテーションの設定例は以下の通りです。

**/etc/logrotate.d/rsyslog** (logrotateの設定例)

```conf
/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
```

- `missingok` : ローテーションするログファイルがなくてもエラーを出さない
- `notifempty` : ログファイルが空の場合はローテーションしない
- 圧縮：
    - `compress` : ローテーションしたファイルをgzipで圧縮する
    - `delaycompress` : 圧縮処理を次回ローテーション時まで遅らせる（compressとともに指定が必要）
        - 1サイクル遅らせて完全に書き込みがない状態のログファイルを圧縮することで、圧縮によるログの欠損を回避する
- 任意スクリプト実行：
    - `sharedscripts` : ログファイルを複数指定したときも、postrotate〜endscript（またはprerotate〜endscript）で指定した処理を実行する
    - `postrotate〜endscript` : ローテーション後に指定のシェルスクリプトを実行する
        - ローテーションした古いファイルにログを書き続けないように、サービスを再起動する処理を行うときなどに利用する
        - 補足：通常のログローテーションは、ファイル名の変更をしてから新規ファイル作成の順番で処理が行われて inode が変わらないため
    - `prerotate〜endscript` : ローテーション前に指定のシェルスクリプトを実行する


上記はlogrotateでよく使われる設定ですが、より詳しい説明は `man logrotate` で確認することができます。

以上です。
