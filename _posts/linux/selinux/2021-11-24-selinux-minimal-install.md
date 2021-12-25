---
layout:        post
title:         "CentOS 7の最小インストールで使用可能なSELinuxコマンドの一覧"
date:          2021-11-24
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


CentOS 7をMinimalで最小インストールした場合に使用可能なSELinuxのコマンドを以下の表にまとめました（一部不足があります）。
最小インストールで使用可能なコマンドは「OK」、使用不可は「NG」です。

| コマンド / [パッケージ]      | パス                 | 最小インストール<br>で使用可能 |
|---------------------------+---------------------------------+---+
| chcon                     | /bin/chcon                      | OK |
| **[policycoreutils]**     | -                               | -  |
| secon                     | /bin/secon                      | OK |
| fixfiles                  | /sbin/fixfiles                  | OK |
| genhomedircon             | /sbin/genhomedircon             | OK |
| load_policy               | /sbin/load_policy               | OK |
| restorecon                | /sbin/restorecon                | OK |
| semodule                  | /sbin/semodule                  | OK |
| sestatus                  | /sbin/sestatus                  | OK |
| setfiles                  | /sbin/setfiles                  | OK |
| setsebool                 | /sbin/setsebool                 | OK |
| **[libselinux]**          | -                               | -  |
| sefcontext_compile        | /sbin/sefcontext_compile        | OK |
| **[libselinux-utils]**    | -                               | -  |
| avcstat                   | /sbin/avcstat                   | OK |
| getenforce                | /sbin/getenforce                | OK |
| getsebool                 | /sbin/getsebool                 | OK |
| matchpathcon              | /sbin/matchpathcon              | OK |
| selabel_digest            | /sbin/selabel_digest            | OK |
| selabel_lookup            | /sbin/selabel_lookup            | OK |
| selabel_lookup_best_match | /sbin/selabel_lookup_best_match | OK |
| selabel_partial_match     | /sbin/selabel_partial_match     | OK |
| selinux_restorecon        | /sbin/selinux_restorecon        | OK |
| selinuxconlist            | /sbin/selinuxconlist            | OK |
| selinuxdefcon             | /sbin/selinuxdefcon             | OK |
| selinuxenabled            | /sbin/selinuxenabled            | OK |
| selinuxexeccon            | /sbin/selinuxexeccon            | OK |
| setenforce                | /sbin/setenforce                | OK |
| **[checkpolicy]**         | -                               | -  |
| checkmodule               | /bin/checkmodule                | NG |
| checkpolicy               | /bin/checkpolicy                | NG |
| sedismod                  | /bin/sedismod                   | NG |
| sedispol                  | /bin/sedispol                   | NG |
| **[policycoreutils-python]** | -                            | -  |
| audit2allow               | /bin/audit2allow                | NG |
| audit2why                 | /bin/audit2why                  | NG |
| chcat                     | /bin/chcat                      | NG |
| sandbox                   | /bin/sandbox                    | NG |
| semodule_package          | /bin/semodule_package           | NG |
| semanage                  | /sbin/semanage                  | NG |
| **[policycoreutils-devel]** | -                             | -  |
| sepolicy                  | /bin/sepolicy                   | NG |
| **[setools-console]**     | -                               | -  |
| findcon                   | /bin/findcon                    | NG |
| sechecker                 | /bin/sechecker                  | NG |
| sediff                    | /bin/sediff                     | NG |
| seinfo                    | /bin/seinfo                     | NG |
| sesearch                  | /bin/sesearch                   | NG |
| **[setroubleshoot-server]** | -                             | -  |
| sealert                   | /bin/sealert                    | NG |
| sedispatch                | /sbin/sedispatch                | NG |
| setroubleshootd           | /sbin/setroubleshootd           | NG |

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
