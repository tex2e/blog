---
layout:        post
title:         "Hardening Projectで記録されたSELinuxによる拒否ログの一覧"
date:          2021-12-18
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Hardening Projectに参加した時にSELinuxを有効にした際の、監査ログ (audit.log) に記録された攻撃と思われるログを抽出して、どういう攻撃があったのかの考察をしてきます。

考察対象は私が tail -f コマンドで監視していたログのみです。
なお、ログを載せる際は type=AVC と msg=audit() の部分を省略しています。
競技時間は 9:30〜17:30 頃なのでログの時刻の範囲もそれくらいです (理不尽な競技なので、明確な競技開始宣言は存在しないです)。

### srv03 (WordPressで構築された会社TOPページ)

WordPressで構築された会社TOPページで観測した拒否ログ（攻撃）は以下のものがありました。

12:04:10 に httpd のプロセスが html ディレクトリを書き込みをしようとしたが拒否した（新規ファイルを作成する前にディレクトリの更新時間を書き込むのを拒否したときに記録されるログ。攻撃者が /var/www/html の直下にWebShellを配置しようとしたか？）。
```log
[root@srv03 ~]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { write } for  pid=1540 comm="/usr/sbin/httpd" name="html" dev="vda1" ino=3018892 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

13:05:03 に httpd のプロセスが sendmail コマンド経由で postfix の設定ファイル main.cf を読もうとしたが拒否した（攻撃者がユーザの新規登録などのメール送信が発生する処理を実施したか？既存サイトにメール送信機能があったかの詳細は不明）。
```log
[root@srv03 ~]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { read } for  pid=2491 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
```

13:17:14 に httpd がポート 3000 番とTCP通信を開始しようとしたのを拒否した（明らかに利用範囲外の不正通信のため、攻撃者が意図的に実行したと思われる）。
```log
avc:  denied  { name_connect } for  pid=1538 comm="/usr/sbin/httpd" dest=3000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:ntop_port_t:s0 tclass=tcp_socket permissive=0
avc:  denied  { name_connect } for  pid=1538 comm="/usr/sbin/httpd" dest=3000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:ntop_port_t:s0 tclass=tcp_socket permissive=0
```

<br>

### srv04 (WelCartで構築されたECサイト)

WelCartで構築されたECサイトで観測した拒否ログ（攻撃）は以下のものがありました。

11:04:53〜11:05:18 に httpd が sendmail コマンド経由で postfix の設定ファイル main.cf を読もうとしたが拒否した（ECサイトからメール送信することは問題ないと判断して、直後に `setsebool -P httpd_can_sendmail On` で対応しました）。
```log
avc:  denied  { read } for  pid=1414 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
avc:  denied  { read } for  pid=1415 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
avc:  denied  { read } for  pid=1416 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
```

11:07:49 と 12:11:45 に httpd が html ディレクトリに書き込みをしようとしたが拒否した（攻撃者が /var/www/html 直下にWebShellを配置しようとした？そして昼休み中も絶え間なく続く攻撃）。
```log
[root@srv04 ~]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { write } for  pid=1506 comm="/usr/sbin/httpd" name="html" dev="vda1" ino=3020199 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

<br>

### srv05 (osCommerceで構築されたECサイト)

osCommerceで構築されたECサイトで観測した拒否ログ（攻撃）は以下のものがありました。

11:13:55 に httpd が html ディレクトリに書き込みをしようとしたが拒否した（攻撃者が /var/www/html 直下にWebShellを配置しようとした？）。
```log
[root@srv05 ~]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { write } for  pid=1728 comm="/usr/sbin/httpd" name="html" dev="vda1" ino=3020182 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

11:23:23 に httpd が includes ディレクトリに書き込みをしようとしたが拒否した（攻撃者が何らかのPHPファイルを書き込もうとしたか？）。
```log
avc:  denied  { write } for  pid=1896 comm="/usr/sbin/httpd" name="includes" dev="vda1" ino=139961 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

11:30:26 に httpd が configure.php、rss_86380e70026c8af52c338ac98e375a04.cache、rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache ファイルを作成しようとしたが拒否した（攻撃者がフレームワークの設定を書き換えようとしたか？、さらにRSSの機能を悪用してRCE攻撃をしようとしたか？）。
```log
avc:  denied  { write } for  pid=2006 comm="/usr/sbin/httpd" name="configure.php" dev="vda1" ino=139945 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2006 comm="/usr/sbin/httpd" name="rss_86380e70026c8af52c338ac98e375a04.cache" dev="vda1" ino=139948 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2006 comm="/usr/sbin/httpd" name="rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache" dev="vda1" ino=140835 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
```

11:30:51 に httpd が大量の書き込みをしようとしたが拒否した（install.phpのようなWeb経由で環境を構築する仕組みによって攻撃者が環境構築を試みた？）。
ログは長いので、ファイル名とディレクトリ名だけを抽出したログを [Hardening Projectの競技中にSELinuxが書き込みを拒否したファイルとディレクトリの一覧](https://gist.github.com/tex2e/c093a4a42e59f5521a573745eb7e2851) で公開しています。
```log
avc:  denied  { write } for  pid=2009 comm="/usr/sbin/httpd" name="configure.php" dev="vda1" ino=139945 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2009 comm="/usr/sbin/httpd" name="rss_86380e70026c8af52c338ac98e375a04.cache" dev="vda1" ino=139948 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2009 comm="/usr/sbin/httpd" name="rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache" dev="vda1" ino=140835 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2007 comm="/usr/sbin/httpd" name="checkout_payment_address.php" dev="vda1" ino=3019340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2007 comm="/usr/sbin/httpd" name="account_password.php" dev="vda1" ino=3019467 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
...
avc:  denied  { write } for  pid=2097 comm="/usr/sbin/httpd" name=".htpasswd_oscommerce" dev="vda1" ino=3023863 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=2097 comm="/usr/sbin/httpd" name=".htpasswd_oscommerce" dev="vda1" ino=3023863 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
```

12:17:49 に httpd が html ディレクトリに書き込みをしようとしたが拒否した（攻撃者が /var/www/html 直下に WebShell などPHPファイルを作成しようとしたか？）。
```log
avc:  denied  { write } for  pid=2547 comm="/usr/sbin/httpd" name="html" dev="vda1" ino=3020182 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

13:26:45 に httpd が再び configure.php、rss_86380e70026c8af52c338ac98e375a04.cache などを作成しようとしたが拒否した。
```log
avc:  denied  { write } for  pid=3377 comm="/usr/sbin/httpd" name="configure.php" dev="vda1" ino=139945 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=3377 comm="/usr/sbin/httpd" name="rss_86380e70026c8af52c338ac98e375a04.cache" dev="vda1" ino=139948 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=3377 comm="/usr/sbin/httpd" name="rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache" dev="vda1" ino=140835 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=3382 comm="/usr/sbin/httpd" name="images" dev="vda1" ino=3019638 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

15:44:04 に httpd が再び images ディレクトリに書き込みをしようとしたが拒否した（攻撃者が画像以外のWebShellのようなファイルをアップロードしたか？、もしくは正規ユーザによる画像追加だったか）。
```log
avc:  denied  { write } for  pid=5652 comm="/usr/sbin/httpd" name="images" dev="vda1" ino=3019638 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

15:46:04 に httpd が画像ファイル shop2-1.png を新規作成しようとしたが拒否した。これはチームメンバーによる商品画像のアップロードで正規のアクセスであったので、アップロードの瞬間だけ一時的にSELinuxを無効化して対応した。
```log
[root@srv05 images]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { add_name } for  pid=5736 comm="/usr/sbin/httpd" name="shop2-1.png.png" scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { add_name remove_name } for  pid=5675 comm="/usr/sbin/httpd" name="shop2-1.png" dev="vda1" ino=3024934 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { write } for  pid=5675 comm="/usr/sbin/httpd" name="shop2-1.png" dev="vda1" ino=3024934 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
^C
[root@srv05 images]# setenforce 0
[root@srv05 images]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { add_name remove_name } for  pid=5652 comm="/usr/sbin/httpd" name="shop2-1.png" dev="vda1" ino=3024934 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=1
avc:  denied  { unlink } for  pid=5652 comm="/usr/sbin/httpd" name="shop2-1.png" dev="vda1" ino=3024934 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=1
^C
[root@srv05 images]# setenforce 1
```

16:04:11 に httpd が再び configure.php、rss_86380e70026c8af52c338ac98e375a04.cache などを作成しようとしたが拒否した。
```log
avc:  denied  { write } for  pid=7180 comm="/usr/sbin/httpd" name="configure.php" dev="vda1" ino=139945 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=7180 comm="/usr/sbin/httpd" name="rss_86380e70026c8af52c338ac98e375a04.cache" dev="vda1" ino=139948 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=7180 comm="/usr/sbin/httpd" name="rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache" dev="vda1" ino=140835 scontext=system_u:system_r:httpd_t:s0 
```

17:15:46 に httpd が再び configure.php、rss_86380e70026c8af52c338ac98e375a04.cache などを作成しようとしたが拒否した。
```log
avc:  denied  { write } for  pid=12009 comm="/usr/sbin/httpd" name="configure.php" dev="vda1" ino=139945 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=12009 comm="/usr/sbin/httpd" name="rss_86380e70026c8af52c338ac98e375a04.cache" dev="vda1" ino=139948 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
avc:  denied  { write } for  pid=12009 comm="/usr/sbin/httpd" name="rss_d9a966ba3c3261d2b4a0bddc2faa12ca.cache" dev="vda1" ino=140835 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
```

<br>

### srv06 (ZenCartで構築されたECサイト)

ZenCartで構築されたECサイトで観測した拒否ログ（攻撃）は以下のものがありました。

11:43:15〜11:44:04 に httpd が sendmail コマンド経由で postfix の設定ファイル main.cf を読み込もうとしたのを拒否した（サービスに必要な処理と判断して、直後に `setsebool -P httpd_can_sendmail On` で対応しました）。
```log
avc:  denied  { read } for  pid=2971 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
avc:  denied  { read } for  pid=2972 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
avc:  denied  { read } for  pid=2973 comm="sendmail" name="main.cf" dev="vda1" ino=133340 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:postfix_etc_t:s0 tclass=file permissive=0
```

16:07:00 に httpd が logs ディレクトリ内を読み込もうとしたのを拒否した（ZenCartの脆弱性を利用して「/var/www/**/logs」にあるログ出力内容を閲覧しようとしたか？）。
```log
[root@srv06 pki_hardening]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { read } for  pid=3991 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
avc:  denied  { read } for  pid=4158 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
```

16:14:08 に httpd が再び logs ディレクトリ内を読み込もうとしたのを拒否した。
```log
avc:  denied  { read } for  pid=6832 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
avc:  denied  { read } for  pid=9777 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
```

16:25:23 に httpd が images ディレクトリに書き込みをしようとしたのを拒否した（画像アップロードでWebShellを配置しようとしたか？または正規ユーザによる画像アップロードか）。
```log
avc:  denied  { write } for  pid=10879 comm="/usr/sbin/httpd" name="images" dev="vda1" ino=3019794 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

16:32:34 に httpd が再び logs ディレクトリ内の読み取りと images ディレクトリへの書き込みを試みたので拒否した。
```log
denied  { read } for  pid=13444 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
denied  { read } for  pid=13444 comm="/usr/sbin/httpd" name="logs" dev="vda1" ino=3019637 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_log_t:s0 tclass=dir permissive=0
denied  { write } for  pid=13444 comm="/usr/sbin/httpd" name="images" dev="vda1" ino=3019794 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

<br>

### srv09 (Nginxで構築されたギャラリーページ)

Nginxで構築されたギャラリーページで観測した拒否ログ（攻撃）は以下のものがありました。

（srv09はサーバ堅牢化の優先度が低かったので、14:40からSELinuxを有効化しました）

14:50:46〜16:18:48 に php-fpm が views ディレクトリに書き込みをしようとしたのを拒否した（個別ページへのアクセス時に発生していたので、正規のアクセスを拒否していた模様）。
```log
avc:  denied  { write } for  pid=824 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { write } for  pid=1708 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { write } for  pid=823 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { write } for  pid=824 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

16:22:20 に個別ページが正しく閲覧できるように、一瞬だけSELinuxを無効化してアクセスしてみたところ、PHPファイル 956d80fe72aa75471b26cf5d1d9288915cfb75f6.php が作成されました（このファイルが本当に必要なPHPなのかという調査まではできませんでした）。
```log
[root@srv09 Filesystem]# setenforce 0
[root@srv09 Filesystem]# tail -f /var/log/audit/audit.log | grep denied
avc:  denied  { write } for  pid=1708 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=1
avc:  denied  { add_name } for  pid=1708 comm="php-fpm" name="956d80fe72aa75471b26cf5d1d9288915cfb75f6.php" scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=1
avc:  denied  { create } for  pid=1708 comm="php-fpm" name="956d80fe72aa75471b26cf5d1d9288915cfb75f6.php" scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=1
avc:  denied  { write } for  pid=1708 comm="php-fpm" path="/var/www/hd/storage/framework/views/956d80fe72aa75471b26cf5d1d9288915cfb75f6.php" dev="vda1" ino=3029964 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=1
^C
[root@srv09 Filesystem]# setenforce 1
```

17:06:29 に php-fpm が views ディレクトリに書き込みしようとしたのを拒否しました（SELinuxの有効化が遅かったので攻撃者に侵害済みだったのかもしれませんが）。
```log
avc:  denied  { write } for  pid=824 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
avc:  denied  { write } for  pid=822 comm="php-fpm" name="views" dev="vda1" ino=3029121 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

<br>

### srv02 (内部向けのフルリゾルバ)

内部向けのフルリゾルバですが、外部からSSHを許可しており、かつ想定外のユーザが存在していたことにより、攻撃者に侵入されていました。

13:50 頃に srv02 に SSH ログインできないことに私が気が付きました。

13:59:27 に (1) sshd がプロセスを起動しようとするがドメイン遷移ルールと不一致で拒否、(2) systemd が systemd-logind ファイルの内容からサービスを起動しようとしたのを拒否、(3) sshd が unconfined_t のプロセスを起動しようとするがドメイン遷移ルールと不一致で拒否、(4) sshd が /usr/bin/bash プロセスを起動しようとするがドメイン遷移ルールと不一致で拒否した（この結果、SSHログインが拒否される状態となりました。sshd サービスが改竄されていたか？）。
```log
avc:  denied  { dyntransition } for  pid=7198 comm="sshd" scontext=system_u:system_r:kernel_t:s0 tcontext=system_u:system_r:sshd_net_t:s0 tclass=process permissive=0
pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:kernel_t:s0 msg='avc:  denied  { start } for auid=n/a uid=0 gid=0 cmdline="/usr/lib/systemd/systemd-logind" scontext=system_u:system_r:kernel_t:s0 tcontext=system_u:system_r:kernel_t:s0 tclass=service  exe="/usr/lib/systemd/systemd" sauid=0 hostname=? addr=? terminal=?'
avc:  denied  { dyntransition } for  pid=8128 comm="sshd" scontext=system_u:system_r:kernel_t:s0 tcontext=unconfined_u:unconfined_r:unconfined_t:s0 tclass=process permissive=0
avc:  denied  { transition } for  pid=8132 comm="sshd" path="/usr/bin/bash" dev="vda3" ino=100664377 scontext=system_u:system_r:kernel_t:s0 tcontext=unconfined_u:unconfined_r:unconfined_t:s0 tclass=process permissive=0
```
SSHログインできないのは、競技のレギュレーションに違反すると判断し、終了の5分前頃にSELinuxを無効化して対応しました。

以上です。
