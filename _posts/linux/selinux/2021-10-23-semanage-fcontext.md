---
layout:        post
title:         "永続的にSELinuxコンテキストを変更する (semanage fcontext)"
menutitle:     "永続的にSELinuxコンテキストを変更する (semanage fcontext)"
date:          2021-10-23
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SELinuxで semanage コマンドを使って永続的にSELinuxコンテキストを変更する方法について説明します。

### ファイルのコンテキスト変更 (-a)

まず、検証用に /etc/file1 ファイルを作成します。/etc 直下に作ったファイルは etc_t タイプのラベルが付けられます。
```bash
~]# touch /etc/file1
~]# ls -Z /etc/file1
unconfined_u:object_r:etc_t:s0 /etc/file1
```
続いて、/etc/file1 のルールに samba_share_t タイプを追加します。
-a は新しいレコードを追加するオプションで、-t はタイプを指定します。
```bash
~]# semanage fcontext -a -t samba_share_t /etc/file1
```
ルールの一覧（-lオプション）から、上記のルールが登録されたことを確認します。
```bash
~]# semanage fcontext -l | grep file1
/etc/file1         all files          system_u:object_r:samba_share_t:s0
```
しかし、ルールを追加しただけでは、ファイルにSELinuxコンテキストは適用されません。
```
~]# ls -Z /etc/file1
unconfined_u:object_r:etc_t:s0 /etc/file1
```
SELinuxコンテキストをデフォルト値に戻す restorecon コマンドを使って、設定をファイルに反映させます。
```bash
~]# restorecon -v /etc/file1
Relabeled /etc/file1 from unconfined_u:object_r:etc_t:s0 to unconfined_u:object_r:samba_share_t:s0
```
restorecon で設定が反映されました。
```bash
~]# ls -Z /etc/file1
unconfined_u:object_r:samba_share_t:s0 /etc/file1
```

### ディレクトリのコンテキスト変更 (-a)

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
HTTPサーバがアクセスできるように、永続的に /web 以下を再帰的に httpd_sys_content_t タイプのラベルに変更するためのルールを追加します。
ルールの条件には Perl と互換性のある正規表現 (PCRE) を使ってタイプを適用するディレクトリを指定します。
ディレクトリは必ず絶対パスで指定してください。
```bash
~]# semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'
```
ルールの一覧 (-lオプション) に、上記のルールが登録されたことを確認します。
```bash
~]# semanage fcontext -l | grep /web
/web(/.*)?          all files          system_u:object_r:httpd_sys_content_t:s0
```
ルールを追加しただけでは、まだディレクトリにSELinuxコンテキストは適用されていません。
最後に restorecon を使って、設定をルール通りに元に戻す（自分で設定したルールを反映させる）作業を行います。
```bash
~]# restorecon -R -v /web
Relabeled /web from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /web/file1.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /web/file2.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /web/file3.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
```
restorecon で設定が反映されました。
```bash
~]# ls -dZ /web
unconfined_u:object_r:httpd_sys_content_t:s0 /web
~]# ls -Z /web
unconfined_u:object_r:httpd_sys_content_t:s0 file1.html
unconfined_u:object_r:httpd_sys_content_t:s0 file2.html
unconfined_u:object_r:httpd_sys_content_t:s0 file3.html
```

### 追加したルールの削除 (-d)

コンテキストのルールを削除するには -d オプションを使い、ルールで使われている正規表現を指定します。
```bash
~]# semanage fcontext -d '/etc/file1'
~]# semanage fcontext -d '/web(/.*)?'
```
ルールを削除しただけではコンテキストが反映されないので、restorecon で設定を反映させます。
```bash
~]# restorecon -v /etc/file1
Relabeled /etc/file1 from unconfined_u:object_r:samba_share_t:s0 to unconfined_u:object_r:etc_t:s0
~]# restorecon -R -v /web
Relabeled /web from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file1.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file2.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
Relabeled /web/file3.html from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:default_t:s0
```

以上です。


### 参考文献

- [4.7. SELinux コンテキスト - ファイルのラベル付け Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-selinux_contexts_labeling_files#sect-Security-Enhanced_Linux-SELinux_Contexts_Labeling_Files-Persistent_Changes_semanage_fcontext)
- [一時的にSELinuxコンテキストを変更する (chcon) \| 晴耕雨読](./selinux-chcon)
