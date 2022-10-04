---
layout:        post
title:         "Linuxサーバからプロキシ経由でyum/aptインストールをする"
date:          2022-09-03
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

リモートのLinux環境から直接インターネットに接続できない環境で、ローカルのプロキシ経由でインターネットに接続する方法について説明します。

```fig
     (internet)                 (internet)
         ^                          ^
         | :80                      X
         |                          |
    +----------+   ssh :22    +--------------+
    | local PC | ----------> | remote Linux |
    +----------+ <---------- +--------------+
                 proxy :8888
```
構成図は上の通りです。ローカルPCからリモートのLinuxにはSSH接続ができる状態です。

### (1) ローカルでプロキシサーバを起動
Windowsの場合、ローカルでFiddlerを起動して、プロキシがローカルの**8888**番ポートで動作していることを確認します（ここではFiddlerを使用していますが、お好きなプロキシを使ってください）。
なお、Fiddlerのポート番号は「歯車アイコン」>「Settings」>「Connections」から確認できます。

MacOSの場合はプロキシサーバとして squid をインストールします。デフォルトポートは**3128**番です。
```bash
% brew install squid
% brew services run squid
% curl https://example.com -x http://localhost:3128
```

以下ではプロキシサーバが 8888 番で動作しているものとします。

### (2) リモートプロキシフォーワード
ssh接続時に `-R` オプションを指定してリモートの8888番をローカルの8888番に転送します。
```bash
% ssh 接続先 -R 8888:127.0.0.1:8888
```

### (3) リモートでプロキシ設定
リモートでプロキシ接続先の環境変数を設定します。
```bash
~]# PROXY='127.0.0.1:8888'
~]# export http_proxy=$PROXY
~]# export HTTP_PROXY=$PROXY
~]# export https_proxy=$PROXY
~]# export HTTPS_PROXY=$PROXY
```
もし、ログイン時に常にプロキシ環境変数を設定したい場合は、profile.d に以下スクリプトを配置します。
```bash
~]# cat <<'EOS' > /etc/profile.d/myproxy.sh
PROXY='127.0.0.1:8888'
export http_proxy=$PROXY
export HTTP_PROXY=$PROXY
export https_proxy=$PROXY
export HTTPS_PROXY=$PROXY
EOS
```

### (4) リモートでインターネットとの接続確認
curlでインターネット接続を確認します。
```bash
~]# curl example.com
```

#### (4-1) RHEL, CentOSの場合

yumで接続先にプロキシのIPを指定します。
```bash
~]# echo 'proxy=http://127.0.0.1:3128' >> /etc/yum.conf
~]# cat /etc/yum.conf
```
```output
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
proxy=http://127.0.0.1:3128
```
さらに、yum update時の証明書チェックを無効化します。
```bash
~]# ls /etc/yum.repos.d
~]# sed -i 's/^sslverify=1/sslverify=0/g' /etc/yum.repos.d/*.repo
```
最後にyum/dnf updateを実行します。
```bash
~]# dnf update
```

#### (4-2) Ubuntuの場合
設定ファイル /etc/apt/apt.conf を以下の内容で新規作成してから、apt updateを実施します。
```bash
~]# cat <<'EOS' >> /etc/apt/apt.conf
Acquire::http::Proxy "http://127.0.0.1:8888";
Acquire::https::Proxy "http://127.0.0.1:8888";
EOS

~]# apt update
```


パッケージの update ができれば install も同様に実行できます。

以上です。
