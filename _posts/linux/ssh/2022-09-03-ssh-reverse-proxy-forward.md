---
layout:        post
title:         "Linuxサーバからプロキシ経由でインターネットに接続する"
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
         |                          X
         |                          |
    +----------+     ssh     +--------------+
    | local PC | ----------> | remote Linux |
    +----------+ <---------- +--------------+
                    proxy
```
構成図は上の通りです。ローカルPCからリモートのLinuxにはSSH接続ができる状態です。


#### (0) リモートでインターネット接続できない状態からスタート
デフォルトではインターネットに接続できないです。
```cmd
~]# dnf update
Error: Failed to download metadata for repo 'rhel-8-appstream-rhui-rpms': Cannot prepare internal mirrorlist: Curl error (28): Timeout was reached for https://rhui.ap-northeast-1.aws.ce.redhat.com/pulp/mirror/content/dist/rhel8/rhui/8/x86_64/appstream/os [Connection timed out after 30000 milliseconds]

~]# curl example.com
curl: (7) Failed to connect to example.com port 80: Connection timed out
```

#### (1) ローカルでFiddlerを起動
ローカルのPCでFiddlerを起動して、プロキシがローカルの8888番ポートで動作していることを確認します（ここではFiddlerを使用していますが、お好きなプロキシを使ってください）。
```cmd
% curl localhost:8888
```
レスポンスに「To configure Fiddler as a reverse proxy instead of seeing this page, ...」のような文が含まれていれば、Fiddlerプロキシは動作しています。

なお、Fiddlerのポート番号は「歯車アイコン」>「Settings」>「Connections」から確認できます。

#### (2) リモートプロキシフォーワード
ssh接続時に `-R` オプションを指定してリモートの8888番をローカルの8888番に転送します。
```cmd
% ssh 接続先 -R 8888:127.0.0.1:8888
```

#### (3) リモートでプロキシ設定
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

#### (4) リモートでインターネットとの接続確認
curlでインターネット接続を確認します。
```bash
~]# curl example.com
```
問題なければupdateを実施します。
```bash
~]# dnf update
```

以上です。
