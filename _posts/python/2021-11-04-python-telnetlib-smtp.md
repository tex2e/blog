---
layout:        post
title:         "telnetコマンドの代わりにPythonのtelnetlibでメールを送信する"
date:          2021-11-04
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

LinuxにtelnetはないけどPython (3.12以下) はある環境の場合は、Pythonの標準ライブラリ「telnetlib」を使うことで、telnetでメール送信のテストをすることができます。

```bash
~]$ python3
>>> from telnetlib import Telnet
>>> with Telnet('localhost', 25) as tn: tn.interact()
helo a
mail from: root@example.local
rcpt to: test@example.local
data
subject: test
hello!
.
quit
```
以上です。

<br>

### 補足：検証環境

メール受信するためのユーザを作成します。
```bash
~]# useradd test
~]# passwd test
```
メールサーバの postfix を次のように設定します。

/etc/postfix/main.cf
```
myhostname = example.local   # メールサーバのホスト名
inet_interfaces = all        # 外部・内部からの全てのメールを受け取る
mynetworks = 127.0.0.0/8     # ローカルからのメールのみ転送する
```

postfix を起動して、25番ポートで master が動いていることを確認します。
```bash
~]# systemctl start postfix
~]# ss -talpn
State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
LISTEN  0       100           0.0.0.0:25         0.0.0.0:*      users:(("master",pid=6972,fd=16))
LISTEN  0       100              [::]:25            [::]:*      users:(("master",pid=6972,fd=17))
```
Telnetでメール送信テストをする場合は以下のコマンドを入力します。
```bash
~]$ telnet localhost 25
helo a
mail from: root@example.local
rcpt to: test@example.local
data
subject: test
hello!
.
quit
```
Telnetは入っていないけどPythonは入っている環境の場合は、Pythonの標準ライブラリtelnetlibを使います。
```bash
~]$ python3
>>> from telnetlib import Telnet
>>> with Telnet('localhost', 25) as tn: tn.interact()
...
```
SMTPのコマンドを手入力したくない場合は、Pythonでプログラムとして実行させることもできます。
```python
from telnetlib import Telnet
tn = Telnet('localhost', 25)
tn.write(b"helo a\r\n")
tn.write(b"mail from: root@example.local\r\n")
tn.write(b"rcpt to: test@example.local\r\n")
tn.write(b"data\r\n")
tn.write(b"subject: TEST\r\n")
tn.write(b"hello!\r\n")
tn.write(b".\r\n")
tn.write(b"quit\r\n")
res = tn.read_all()
print(res)
tn.close()
```
送信後に、受信したサーバの /home/test/Maildir/new/ にメール内容を含むファイルが新規作成されていれば、送信成功です。

以上です。
