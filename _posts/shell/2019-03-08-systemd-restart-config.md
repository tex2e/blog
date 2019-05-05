---
layout:        post
title:         "systemdでプロセス自動再起動"
menutitle:     "systemdのRestartでプロセス自動再起動"
date:          2019-03-08
tags:          Shell
category:      Shell
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

systemctl start でサービス起動したのに、OOM killer などによってプロセスが殺されたりすることは往々にあると思いますが、プロセスの死活監視をしてないと対策が遅れてしまうことがあります。
そこで、systemd の Restart を使ってプロセスの再起動を自動でやらせたいと思います。

systemd の Unit ファイルの \[Service] のセクションでは Restart という設定項目があり[^restart]、これを使うことでプロセスが勝手に終了しても自動でプロセスを再起動させることができます。
なお、systemctl stop のように systemd のコマンドを使って終了させた場合は再起動しません。

Restartの値は no, on-success, on-failure, on-abnormal, on-watchdog, on-abort, always のいずれかです。
基本的には always で十分だと思います。

<table rules="all" border="1">
  <thead>
    <tr>
      <th></th>
      <th>no</th>
      <th>always</th>
      <th>on-success</th>
      <th>on-failure</th>
      <th>on-abnormal</th>
      <th>on-abort</th>
      <th>on-watchdog</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Clean exit code or signal</td>
      <td> </td>
      <td>O</td>
      <td>O</td>
      <td> </td>
      <td> </td>
      <td> </td>
      <td> </td>
    </tr>
    <tr>
      <td>Unclean exit code</td>
      <td> </td>
      <td>O</td>
      <td> </td>
      <td>O</td>
      <td> </td>
      <td> </td>
      <td> </td>
    </tr>
    <tr>
      <td>Unclean signal</td>
      <td> </td>
      <td>O</td>
      <td> </td>
      <td>O</td>
      <td>O</td>
      <td>O</td>
      <td> </td>
    </tr>
    <tr>
      <td>Timeout</td>
      <td> </td>
      <td>O</td>
      <td> </td>
      <td>O</td>
      <td>O</td>
      <td> </td>
      <td> </td>
    </tr>
    <tr>
      <td>Watchdog</td>
      <td> </td>
      <td>O</td>
      <td> </td>
      <td>O</td>
      <td>O</td>
      <td> </td>
      <td>O</td>
    </tr>
  </tbody>
</table>

- no : プロセスが終了してもプロセスを再起動しません。
- on-success : プロセスが正常終了したときにプロセスを再起動します。ただし正常終了とは終了コードが 0 のときや SIGHUP, SIGINT, SIGTERM, SIGPIPE のシグナルで終了した場合のことです。
- on-failure : プロセスが異常終了したときにプロセスを再起動します。ただし異常終了とは終了コードが 0 以外のときやコアダンプなどの上記4つ以外のシグナルで終了した場合などのことです。
- on-abnormal : on-failure と似ていますが、終了コードによるプロセスの再起動はしません。
- on-abort : プロセスが上記4つ以外のシグナルで終了したときにプロセスを再起動します。
- on-watchdog : watchdogがタイムアウトしたときにプロセスを再起動します。

なお、短い時間で何回も再起動が発生すると再起動を諦める機能があります[^limit]。
具体的には StartLimitInterval の間に StartLimitBurst の回数だけ再起動が起きると、systemd は自動的に再起動するのを止めます。デフォルトでは 10 秒の間に 5 回まで再起動が行われます。

デフォルト値は /etc/systemd/system.conf に書かれています。

```
[Manager]
...
#DefaultStartLimitInterval=10s
#DefaultStartLimitBurst=5
...
```


<br>

### サンプルアプリでプロセス自動再起動

例えば、[以前]({{ site.baseurl }}/shell/create-my-systemd-service)作成した簡易Webサーバを例にプロセスの再起動を確認してみたいと思います。

まず作成した必要なファイルは以下の通りです。
再起動は `Restart=always` としています。

/etc/systemd/system/tinyhttpd

```config
[Unit]
Description=Tiny HTTPD
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python /usr/local/bin/tinyhttpd.py
Restart=always

[Install]
WantedBy=multi-user.target
```

/usr/local/bin/tinyhttpd.py

```python
#!/usr/bin/env python

import os
import sys
import SimpleHTTPServer
import SocketServer

if __name__ == "__main__":
    out = sys.stderr

    host = os.getenv("TINYHTTPD_HOST", "")
    port = os.getenv("TINYHTTPD_PORT", 8000)
    listen = (str(host), port)

    SocketServer.TCPServer.allow_reuse_address = True
    httpd = SocketServer.TCPServer(
        listen,
        SimpleHTTPServer.SimpleHTTPRequestHandler,
    )

    out.write("listen: host=%s, port=%s\n" % (host, port))
    httpd.serve_forever()
```

systemctlをリロードして、Webサーバを起動します。

```
# systemctl daemon-reload
# systemctl start tinyhttpd
```

curlで叩いてアクセスできることを確認。

```
# curl localhost:8000
```

次に ps auxw で python プロセスを確認したら `kill <PID>` で当該プロセスを殺します。
プロセスIDがわからなければ pkill を使ってもOKです。

```
# pkill -f '/usr/bin/python /usr/local/bin/tinyhttpd.py'
```

そしたら systemd のログは /var/log/messages に書かれているので、tail -f で開いて中身を確認します。

```
# tailf /var/log/messages
```

一番下に、プロセスが終了したこととプロセス再起動したことがログにあれば、自動的にプロセスが再起動したことが確認できます。

```
Mar  8 11:11:11 localhost systemd: tinyhttpd.service holdoff time over, scheduling restart.
Mar  8 11:11:11 localhost systemd: Started Tiny HTTPD.
Mar  8 11:11:11 localhost systemd: Starting Tiny HTTPD...
Mar  8 11:11:11 localhost python: listen: host=, port=8000
```

再起動した状態なら、再度 curl で叩いてもアクセスできます。

```
# curl localhost:8000
```

ps auxw で確認すると python プロセスの PID も変わっていることも確認できます。



### 参考文献

[^restart]: [Restart= -- systemd.service](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=)
[^limit]: [StartLimitIntervalSec=interval, StartLimitBurst=burst -- systemd.unit](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#StartLimitIntervalSec=interval)
