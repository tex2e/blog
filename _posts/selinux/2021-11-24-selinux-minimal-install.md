---
layout:        post
title:         "CentOS 7の最小インストールで使用可能なSELinuxコマンドの一覧"
menutitle:     "CentOS 7の最小インストールで使用可能なSELinuxコマンドの一覧 (Minimal Install)"
date:          2021-11-24
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/selinux-minimal-install
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---


CentOS 7をMinimalで最小インストールした場合に使用可能なSELinuxのコマンドを以下の表にまとめました（一部不足があります）。
最小インストールで使用可能なコマンドは「Yes」、使用不可は「No」です。

| コマンド / [パッケージ]      | パス                 | デフォルトで使用可能 |
|---------------------------+---------------------------------+---+
| chcon                     | /bin/chcon                      | Yes |
| **[policycoreutils]**     | -                               | -  |
| secon                     | /bin/secon                      | Yes |
| fixfiles                  | /sbin/fixfiles                  | Yes |
| genhomedircon             | /sbin/genhomedircon             | Yes |
| load_policy               | /sbin/load_policy               | Yes |
| restorecon                | /sbin/restorecon                | Yes |
| semodule                  | /sbin/semodule                  | Yes |
| sestatus                  | /sbin/sestatus                  | Yes |
| setfiles                  | /sbin/setfiles                  | Yes |
| setsebool                 | /sbin/setsebool                 | Yes |
| **[libselinux]**          | -                               | -  |
| sefcontext_compile        | /sbin/sefcontext_compile        | Yes |
| **[libselinux-utils]**    | -                               | -  |
| avcstat                   | /sbin/avcstat                   | Yes |
| getenforce                | /sbin/getenforce                | Yes |
| getsebool                 | /sbin/getsebool                 | Yes |
| matchpathcon              | /sbin/matchpathcon              | Yes |
| selabel_digest            | /sbin/selabel_digest            | Yes |
| selabel_lookup            | /sbin/selabel_lookup            | Yes |
| selabel_lookup_best_match | /sbin/selabel_lookup_best_match | Yes |
| selabel_partial_match     | /sbin/selabel_partial_match     | Yes |
| selinux_restorecon        | /sbin/selinux_restorecon        | Yes |
| selinuxconlist            | /sbin/selinuxconlist            | Yes |
| selinuxdefcon             | /sbin/selinuxdefcon             | Yes |
| selinuxenabled            | /sbin/selinuxenabled            | Yes |
| selinuxexeccon            | /sbin/selinuxexeccon            | Yes |
| setenforce                | /sbin/setenforce                | Yes |
| **[checkpolicy]**         | -                               | -  |
| checkmodule               | /bin/checkmodule                | No |
| checkpolicy               | /bin/checkpolicy                | No |
| sedismod                  | /bin/sedismod                   | No |
| sedispol                  | /bin/sedispol                   | No |
| **[policycoreutils-python]** | -                            | -  |
| audit2allow               | **/bin/audit2allow**            | No |
| audit2why                 | /bin/audit2why                  | No |
| chcat                     | /bin/chcat                      | No |
| sandbox                   | /bin/sandbox                    | No |
| semodule_package          | /bin/semodule_package           | No |
| semanage                  | **/sbin/semanage**              | No |
| **[policycoreutils-devel]** | -                             | -  |
| sepolicy                  | /bin/sepolicy                   | No |
| **[setools-console]**     | -                               | -  |
| findcon                   | /bin/findcon                    | No |
| sechecker                 | /bin/sechecker                  | No |
| sediff                    | /bin/sediff                     | No |
| seinfo                    | /bin/seinfo                     | No |
| sesearch                  | /bin/sesearch                   | No |
| **[setroubleshoot-server]** | -                             | -  |
| sealert                   | /bin/sealert                    | No |
| sedispatch                | /sbin/sedispatch                | No |
| setroubleshootd           | /sbin/setroubleshootd           | No |
| **[policycoreutils-newrole]** | -                           | -  |
| newrole                   | /usr/bin/newrole                | No |

<br>

#### policycoreutils-pythonをrpmファイル経由でインストールする例

インターネットに接続していない最小インストールのサーバでも、semanageやaudit2allowコマンドが使用できるように、scp経由でrpmファイルをサーバに送ってローカルインストールする方法について説明します。

まず、同じバージョンのCentOS(検証サーバ)を用意し、yum install --downloadonly で rpm ファイルのダウンロードを行います。

```bash
~]# cat /etc/centos-release
CentOS Linux release 7.9.2009 (Core)

~]# mkdir semanage
~]# yum install --downloadonly --downloaddir=./semanage policycoreutils-python
~]# ls semanage
audit-libs-python-2.8.5-4.el7.x86_64.rpm
checkpolicy-2.5-8.el7.x86_64.rpm
libcgroup-0.41-21.el7.x86_64.rpm
libsemanage-python-2.5-14.el7.x86_64.rpm
policycoreutils-python-2.5-34.el7.x86_64.rpm
python-IPy-0.75-6.el7.noarch.rpm
setools-libs-3.3.8-4.el7.x86_64.rpm

~]# tar zcvf semanage.tar.gz ./semanage
```

検証サーバで rpm ファイルを固めた .tar.gz ファイルを本番サーバに scp で転送します。

```bash
$ scp root@検証サーバIP:/root/semanage.tar.gz ./

$ scp semanage.tar.gz root@本番サーバIP:~
```

展開して yum locallinstall で rpm ファイルをローカルインストールすれば、semanage や audit2allow コマンドが使えるようになります。

```bash
~]# tar zxvf semanage.tar.gz
~]# yum localinstall ./semanage/*.rpm
```

以上です。
