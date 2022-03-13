---
layout:        post
title:         "cpでSELinuxコンテキストもコピーする"
menutitle:     "cpでSELinuxコンテキストもコピーする (cp --preserve=context)"
date:          2021-10-24
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

ファイルやディレクトリをコピー (cp) するときにSELinuxコンテキストもコピーする方法と、移動 (mv) するときとの違いについて説明します。

#### コピー (cp) する場合のコンテキスト

通常、cp でファイルをコピーする場合、コンテキストのタイプはコピー先の親ディレクトリーから継承されます。
しかし、場合によってはSELinuxコンテキストもコピーしたい場合があります。
ファイルのSELinuxコンテキストもコピーする場合は、cpコマンドに `--preserve=context` オプションを追加して実行します。
```bash
~]# touch example.txt
~]# ls -Z example.txt
unconfined_u:object_r:admin_home_t:s0 example.txt        # <= admin_home_tタイプが付与される

~]# cp --preserve=context example.txt /var/www/html/
~]# ls -Z /var/www/html/example.txt
unconfined_u:object_r:admin_home_t:s0 /var/www/html/example.txt  # <= admin_home_tタイプのままコピーされた
```
上の例を見ると、最初にファイルを作成したときはadmin_home_tタイプでしたが、コピー先でもadmin_home_tタイプが維持されています。
ただし、semanage fcontext でルールを追加したわけではないので、あくまで一時的な設定（chconでコンテキストを設定した状態）です。
restorecon コマンドでSELinuxコンテキストをデフォルトに戻すと、example.txt のタイプは親ディレクトリ /var/www/html の httpd_sys_content_t タイプに修正されます。
```bash
~]# restorecon -R -v /var/www/html
Relabeled /var/www/html/example.txt from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0

~]# ls -Z /var/www/html/example.txt
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/example.txt
```

#### 移動 (mv) する場合のコンテキスト
補足：移動する場合はSELinuxコンテキストはそのまま維持されます。
```bash
~]# touch example2.txt
~]# ls -Z example2.txt
unconfined_u:object_r:admin_home_t:s0 example2.txt
~]# mv example2.txt /var/www/html/
~]# ls -Z /var/www/html/example2.txt
unconfined_u:object_r:admin_home_t:s0 /var/www/html/example2.txt
```
もちろん、semanage fcontext でコンテキストのルールを追加したわけではないので、restorecon コマンドを実行するとデフォルトのタイプに戻ります。

まとめると、以下のようになります。
- コピー (cp) するとき：SELinuxコンテキストは親ディレクトリのタイプを継承する
- 移動 (mv) するとき：SELinuxコンテキストはそのまま維持される

管理者権限で作成した設定ファイルなどを誤って別フォルダに移動した場合は SELinux で読み取り拒否されますが、コピーしてしまった場合は読み取られてしまいます。

以上です。

### 参考文献

- [4.10.1. ファイルおよびディレクトリーのコピー Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-maintaining_selinux_labels_#sect-Security-Enhanced_Linux-Maintaining_SELinux_Labels_-Copying_Files_and_Directories)
- [4.10.2. ファイルおよびディレクトリーの移動 Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-maintaining_selinux_labels_#sect-Security-Enhanced_Linux-Maintaining_SELinux_Labels_-Moving_Files_and_Directories)
