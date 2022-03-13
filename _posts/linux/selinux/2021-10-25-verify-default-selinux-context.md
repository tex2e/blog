---
layout:        post
title:         "ファイルのデフォルトSELinuxコンテキストを確認する"
menutitle:     "ファイルのデフォルトSELinuxコンテキストを確認する (matchpathcon -V)"
date:          2021-10-25
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

ファイルやディレクトリのSELinuxコンテキストが、ポリシールールと一致しているか確認するため matchpathcon コマンドについて説明します。

SELinuxが有効な環境では mv や cp --preserve=context や chcon コマンドによって、その親ディレクトリのタイプを継承しないファイルやディレクトリが存在する場合があります。

例えば、/var/www/html は次のようなファイル構造になっているとします。
```bash
~]# find /var/www/html
/var/www/html
/var/www/html/example.txt
/var/www/html/example2.txt
/var/www/html/test
/var/www/html/test/test.html
```
/var/www/html の中身は httpd がアクセスできるように、本来は httpd_sys_content_t タイプが付与されていますが、以下のように別のタイプを持つファイルやディレクトリが混在していたとします。
```bash
~]# find /var/www/html -exec ls -dZ {} \;
system_u:object_r:httpd_sys_content_t:s0 /var/www/html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/example.txt
unconfined_u:object_r:admin_home_t:s0 /var/www/html/example2.txt
unconfined_u:object_r:admin_home_t:s0 /var/www/html/test
unconfined_u:object_r:admin_home_t:s0 /var/www/html/test/test.html
```
このとき、対象のファイルはルール通りのタイプなのか、またはそうではないのか、を調べる必要があります。
**matchpathcon** コマンドを使うことで、コンテキストがデフォルトになっているか検証することができます。
使い方は -V (Verify) オプションを付けて、対象パスを指定するだけです。
```bash
~]# matchpathcon -V /var/www/html/example.txt
/var/www/html/example.txt verified.
```
コンテキストがデフォルトと一致する場合は「verified」と表示されます。
```bash
~]# matchpathcon -V /var/www/html/example2.txt
/var/www/html/example2.txt has context unconfined_u:object_r:admin_home_t:s0, should be system_u:object_r:httpd_sys_content_t:s0
```
コンテキストがデフォルトと不一致の場合は、現在のコンテキストのデフォルトのコンテキストの両方が表示されます。

対象ディレクトリ内をすべて検証するには find コマンドと組み合わせることで、簡単に全体を検証できます。
```bash
~]# find /var/www/html -exec matchpathcon -V {} \;
/var/www/html verified.
/var/www/html/example.txt verified.
/var/www/html/example2.txt has context unconfined_u:object_r:admin_home_t:s0, should be system_u:object_r:httpd_sys_content_t:s0
/var/www/html/test has context unconfined_u:object_r:admin_home_t:s0, should be system_u:object_r:httpd_sys_content_t:s0
/var/www/html/test/test.html has context unconfined_u:object_r:admin_home_t:s0, should be system_u:object_r:httpd_sys_content_t:s0
```
対象ファイルをデフォルトのコンテキストにする場合は、restorecon コマンドを使います。
以下は /var/www/html 全体をデフォルトに戻す場合の例です。
```bash
~]# restorecon -R -v /var/www/html
Relabeled /var/www/html/example2.txt from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /var/www/html/test from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /var/www/html/test/test.html from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
```
デフォルトのコンテキストに戻したので、すべてのファイル・ディレクトリがルールと一致するようになりました。
```bash
~]# find /var/www/html -exec matchpathcon -V {} \;
/var/www/html verified.
/var/www/html/example.txt verified.
/var/www/html/example2.txt verified.
/var/www/html/test verified.
/var/www/html/test/test.html verified.
```
以上です。



### 参考文献

- [4.10.3. デフォルトの SELinux コンテキストの確認 Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-maintaining_selinux_labels_#sect-Security-Enhanced_Linux-Maintaining_SELinux_Labels_-Checking_the_Default_SELinux_Context)
