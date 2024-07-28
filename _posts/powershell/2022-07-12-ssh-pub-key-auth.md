---
layout:        post
title:         "[PowerShell] コンソールでSSH公開鍵認証をする"
date:          2022-07-12
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windows10のPowerShellコンソールで、ssh接続に公開鍵を利用する方法について説明します。
なお、最新のWindows10には OpenSSH が標準でインストールされています。

### SSH鍵生成と公開鍵のサーバへの登録

PowerShellで鍵生成と公開鍵の配布：

```ps1
PS> $myUser='root'
PS> $myHost='192.168.xx.xx'
PS> ssh-keygen
PS> scp $HOME\.ssh\id_rsa.pub $myUser@${myHost}:/tmp
PS> ssh $myUser@$myHost
```

サーバ接続後：

```bash
~]# mkdir -p ~/.ssh
~]# chmod 700 ~/.ssh
~]# cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
~]# chmod 600 ~/.ssh/authorized_keys
~]# exit
```

### SSH接続

`-i` オプションで秘密鍵を指定して、SSH公開鍵認証を利用する。

```ps1
PS> ssh -i $HOME\.ssh\id_rsa $myUser@$myHost
```

以上です。
