---
layout:        post
title:         "一時的にSELinuxコンテキストを変更する (chcon)"
menutitle:     "[SELinux] 一時的にSELinuxコンテキストを変更する (chcon)"
date:          2021-10-22
category:      Linux
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

SELinuxのchconコマンドを使って、一時的にSELinuxコンテキストを変更する方法について説明します。

### ファイルのコンテキスト変更 (chcon)

まずは、chconを使ったファイルのSELinuxコンテキストの変更方法についてです。
検証用に test.html を用意し、タイプを httpd_sys_content_t に変更します。
```bash
~]# ls -Z test.html
unconfined_u:object_r:admin_home_t:s0 test.html

~]# chcon -t httpd_sys_content_t test.html
~]# ls -Z test.html
unconfined_u:object_r:httpd_sys_content_t:s0 test.html
```
chcon で設定した内容は一時的なものですが、再起動しても消えることはありません。
```bash
~]# reboot
...再起動...

~]# ls -Z test.html
unconfined_u:object_r:httpd_sys_content_t:s0 test.html
```
restorecon はSELinuxコンテキストをデフォルト値に復元するためのコマンドです。
restorecon コマンドを使うと、chcon で設定した内容は消えて、コンテキストが元に戻ります。
```bash
~]# restorecon -v test.html
Relabeled /root/test.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:admin_home_t:s0
~]# ls -Z test.html
unconfined_u:object_r:admin_home_t:s0 test.html
```

### ディレクトリのコンテキスト変更 (chcon -R)

HTTPサーバが /var/www/html ではなく別のドキュメントルートを使用する場合は、ディレクトリのコンテキストを修正する必要があります。
まず、/var/www/html の代わりに /web をApacheのドキュメントルートとして使いたいとします。
```bash
~]# mkdir /web
~]# touch /web/file{1,2,3}.html
```
新しい最上位ディレクトリーを作成すると default_t タイプのラベルが付けられます。
```bash
~]# ls -dZ /web
unconfined_u:object_r:default_t:s0 /web
~]# ls -Z /web
total 0
unconfined_u:object_r:default_t:s0 file1.html
unconfined_u:object_r:default_t:s0 file2.html
unconfined_u:object_r:default_t:s0 file3.html
```
HTTPサーバがアクセスできるように、一時的に /web 以下を再帰的に httpd_sys_content_t タイプのラベルに変更します。
```bash
~]# chcon -R -t httpd_sys_content_t /web
```
変更結果：
```bash
~]# ls -dZ /web
unconfined_u:object_r:httpd_sys_content_t:s0 /web
~]# ls -Z /web
unconfined_u:object_r:httpd_sys_content_t:s0 file1.html
unconfined_u:object_r:httpd_sys_content_t:s0 file2.html
unconfined_u:object_r:httpd_sys_content_t:s0 file3.html
```
chcon によるSELinuxコンテキストの変更は一時的なものなので、restorecon で元に戻すことができます。
ディレクトリに対しては -R オプションで再帰的に適用（復元）させることができます。
```bash
~]# restorecon -R -v /web
Relabeled /web from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file1.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file2.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file3.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
```

以上です。

### 参考文献

- [4.7. SELinux コンテキスト - ファイルのラベル付け Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-selinux_contexts_labeling_files#sect-Security-Enhanced_Linux-SELinux_Contexts_Labeling_Files-Temporary_Changes_chcon)
- [永続的にSELinuxコンテキストを変更する (semanage fcontext) \| 晴耕雨読](./semanage-fcontext)
