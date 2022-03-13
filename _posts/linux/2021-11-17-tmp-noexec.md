---
layout:        post
title:         "systemctl で /tmp 内のファイルを実行不可にする"
date:          2021-11-17
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

システムに攻撃者が侵入した際に、権限昇格のために必要なファイルを /tmp に配置して実行することがあります。
ここでは systemctl を利用して /tmp ディレクトリのファイルを実行できないようにする方法について説明します。

まず始めに、systemctl の tmp.mount は初期状態で disabled になっています。
ここでは /tmp ディレクトリを noexec オプション付きでマウントするために、tmp.mount を利用します。
```bash
~]# systemctl is-enabled tmp.mount

disabled
```
必要な設定ファイルは、systemdのtmp.mountファイルをコピーして修正します。
```bash
~]# cp -vi /usr/lib/systemd/system/tmp.mount /etc/systemd/system/tmp.mount
```
/etc/systemd/system/tmp.mount ファイルを以下のように修正します。Optionsの行に「noexec」を追加します。
```conf
[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,strictatime,nodev,nosuid,noexec
```
systemdのデーモンをリロードし、tmp.mountサービスのマスクを解除して起動します。
```bash
~]# systemctl daemon-reload
~]# systemctl unmask tmp.mount
~]# systemctl --now enable tmp.mount
```
以上で、/tmp 内のファイルは実行できなくなりました。

試しに /tmp フォルダに実行ファイルを作成して実行します。
```bash
~]# cat /tmp/test.sh
#!/bin/bash
echo hello!
~]# chmod +x /tmp/test.sh
~]# ls -l /tmp/test.sh
-rwxr-xr-x. 1 root root 25 Nov 11 12:00 /tmp/test.sh
```
/tmp/test.sh を実行すると権限エラーで実行できません。/tmp フォルダは noexec でマウントされているため、ファイルの実行ができないことが確認できます。
```bash
~]# /tmp/test.sh
-bash: /tmp/test.sh: Permission denied
```
なお、/tmp では実行できないのですが、/var/tmp などに移動すれば実行することができます。
```bash
~]# cp /tmp/test.sh /var/tmp/test.sh
~]# /var/tmp/test.sh
hello!
```
以上です。


#### 参考文献
- [CIS Downloads > CentOS](https://downloads.cisecurity.org/#/)
