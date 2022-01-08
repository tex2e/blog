---
layout:        post
title:         "systemd のユニットファイルの作り方"
date:          2019-03-05
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/create-my-systemd-service
comments:      true
published:     true
---

主に CentOS 7 での systemd のユニットファイルの作り方についてです。
自作サービスが定義できるので、`systemctl start myservice` のような使い方ができるようになります。

/usr/lib/systemd/system/ はパッケージが提供するサービスのファイルを配置する場所で、
/etc/systemd/system/ はシステム管理者がサービスのファイルを配置する場所です。
自作のサービスを作りたい場合は /etc/systemd/system/ の下にファイルを配置します。

参考までに Apache HTTP Server のサービスファイル
/usr/lib/systemd/system/httpd.service の内容は次の通りです。

```command
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

自作のユニットファイルは /etc/systemd/system/multi-user.target.wants/*name*.service に記述していきます。

### ユニットファイルの構造

ユニットファイルは特に3つの部分で構成されます。

#### \[Unit]
ユニットの種類によらない一般的なオプションの設定
  - Description : このユニットの説明。systemctl status の時に表示される
  - Documentation : このユニットについてのドキュメントのURI
  - After : このユニットの前に起動するユニット[^note1]
  - Before : このユニットの後に起動するユニット[^note1]
  - Requires : このユニットが依存するユニット。前のユニットの起動が失敗したら起動しない[^note1]
  - Wants : このユニットが依存するユニット。前のユニットの起動が失敗しても起動する[^note1]
  - Conflicts : 指定したユニットと一緒に起動しない

#### \[Service]
サービスに関する設定。
  - Type : プロセスの起動方法。各方法は以下の6通り。
    「起動完了」は次のユニットが実行可能であることを意味する。
    - simple ... デフォルト。プロセスが起動した時点で起動完了
    - forking ... フォークして親プロセスが終了した時点で起動完了
    - oneshot ... simple と似ているが、次のユニットを実行する前に自身のプロセスを終了する
    - dbus ... D-Bus を使うプロセスで、D-Bus の接続名を見つけると起動完了
    - notify ... simple と似ているが、sd_notify() 関数で起動完了のメッセージを受け取ったときに起動完了
    - idle ... simple と似ているが、他のジョブが終了するまで待機する（シェルへの出力が混ざらないようにするため）
  - ExecStart : 起動時に実行するコマンド
  - ExecStop : 停止時に実行するコマンド
  - ExecReload : リロード時に実行するコマンド
  - Restart : プロセスが停止したとき、プロセス再起動の条件。各条件は以下の4つ
    - always ... 常に再起動する
    - no ... 再起動しない
    - on-success ... 終了コードが0で再起動する
    - on-failure ... 終了コードが0以外で再起動する
  - RestartSec : 再起動するまでの待ち時間（秒）

#### \[Install]
インストール時の設定
  - Alias : enable時にここで指定された名前のユニットのシンボリックリンクを作成する
  - RequiredBy : enable時にこのユニットの.requiredディレクトリにリンクを作成する[^note2]
  - WantedBy : enable時にこのユニットの.wantsディレクトリにリンクを作成する[^note2]
  - Also : enable/disable時に同時にenable/disableするユニット


より詳細な説明はマニュアルがあるのでそちらを参照してください。
- ユニットのマニュアルを読みたいときは `man systemd.unit` コマンドを実行する
- サービスのマニュアルを読みたいときは `man systemd.service` コマンドを実行する


### 自作ユニットファイルの作成

1. まず実行ファイルを用意します（bash でも python でも何で書かれてあっても良い）
2. ユニットファイルを /etc/systemd/system/name.service に作成します。nameはサービス名に置き換えます。
3. ユニットファイルに設定を書き込みます。
   ネットワーク関連のサービスなら network.target のユニットが起動した後に実行するので、
   以下のユニット設定例のようになります。

    ```
    [Unit]
    Description=service_description
    After=network.target

    [Service]
    ExecStart=path_to_executable
    Type=forking
    PIDFile=path_to_pidfile

    [Install]
    WantedBy=default.target
    ```

4. 自作サービスを実行するには、まずリロードをする必要があります。

    ```command
    systemctl daemon-reload
    systemctl start name.service
    ```

ユニットファイルの作成例がRHELの公式に書かれているので参考までに。


### サンプルアプリケーション

ここでは簡単なWebサーバをsystemctlで動かしたいと思います。

まず、ユニットファイル /etc/systemd/system/tinyhttpd.service は次のように定義します。

```
[Unit]
Description=Tiny HTTPD
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python /usr/local/bin/tinyhttpd.py

[Install]
WantedBy=multi-user.target
```

実行するアプリケーション（簡易Webサーバ）のプログラムは /usr/local/bin/tinyhttpd.py に配置して、内容は次のようにしました。

```python
#!/usr/bin/env python2

import os
import sys
import SimpleHTTPServer
import SocketServer

if __name__ == "__main__":
    out = sys.stderr

    host = os.getenv("TINYHTTPD_HOST", "")
    port = os.getenv("TINYHTTPD_PORT", 8000)
    listen = (str(host), port)
    httpd = SocketServer.TCPServer(
        listen,
        SimpleHTTPServer.SimpleHTTPRequestHandler,
    )

    out.write("listen: host=%s, port=%s\n" % (host, port))
    httpd.serve_forever()
```

systemctlをリロードして、Webサーバを起動します。
必要に応じて firewall のポート 8000 を開けるか、firewall無効にするなどしてください。

```command
systemctl daemon-reload
systemctl start tinyhttpd
```

curlで叩いてレスポンスがあれば成功です。

```command
curl localhost:8000
```

最後にWebサーバの停止します。

```command
systemctl stop tinyhttpd
```

以上です。

---

[^note1]: ユニットの起動順（After と Before）と依存関係（Wants と Requires）はそれぞれ独立した機能であるが、ほとんどの場合は After と Before で事足りる。
[^note2]: WantedBy と RequiredBy の違いは、ユニットの Wants と Requires の起動失敗時の挙動と同じ
