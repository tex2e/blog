---
layout:        post
title:         "lsofでファイルを開いているプログラムを特定する"
date:          2022-10-29
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

Linuxのlsofコマンドはファイルを開いているプログラムを特定するためのコマンドです。

引数に対象のファイルを指定して、開いているプログラムを特定します。
```bash
$ lsof /var/log/bad.log
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF  NODE NAME
badlog.py 639 ubuntu    3w   REG  259,1     9346 67701 /var/log/bad.log
```

プログラムのプロセスID (PID) から、開いているファイルの一覧の取得もできます。
```bash
$ lsof -p 639
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
badlog.py 639 ubuntu  cwd    DIR  259,1     4096 258156 /home/ubuntu
badlog.py 639 ubuntu  rtd    DIR  259,1     4096      2 /
badlog.py 639 ubuntu  txt    REG  259,1  5905480   6925 /usr/bin/python3.10
badlog.py 639 ubuntu  mem    REG  259,1    27002   3963 /usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache
badlog.py 639 ubuntu  mem    REG  259,1   353616   6305 /usr/lib/locale/C.utf8/LC_CTYPE
badlog.py 639 ubuntu  mem    REG  259,1  3048928   6314 /usr/lib/locale/locale-archive
badlog.py 639 ubuntu  mem    REG  259,1  2216304   3693 /usr/lib/x86_64-linux-gnu/libc.so.6
badlog.py 639 ubuntu  mem    REG  259,1   108936   4076 /usr/lib/x86_64-linux-gnu/libz.so.1.2.11
badlog.py 639 ubuntu  mem    REG  259,1   194872   4796 /usr/lib/x86_64-linux-gnu/libexpat.so.1.8.7
badlog.py 639 ubuntu  mem    REG  259,1   940560   3696 /usr/lib/x86_64-linux-gnu/libm.so.6
badlog.py 639 ubuntu  mem    REG  259,1   240936   3690 /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
badlog.py 639 ubuntu    0r   CHR    1,3      0t0      5 /dev/null
badlog.py 639 ubuntu    1u   REG  259,1        0   6917 /tmp/#6917 (deleted)
badlog.py 639 ubuntu    2u   REG  259,1        0   6917 /tmp/#6917 (deleted)
badlog.py 639 ubuntu    3w   REG  259,1    11124  67701 /var/log/bad.log
```

サブディレクトリ以下の全てのファイルを対象にして、ファイルを開いているプログラムを特定する場合は `+D` オプションを使用します。
```bash
$ lsof +D /home/ubuntu
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
sadagent 542 ubuntu  cwd    DIR  259,1     4096 524987 /home/ubuntu/agent
sadagent 542 ubuntu  txt    REG  259,1 11397096 524988 /home/ubuntu/agent/sadagent
sadagent 542 ubuntu    3w   REG  259,1      211 524989 /home/ubuntu/agent/sadagent.txt
```

lsofはファイルだけでなくネットワークソケットを開いているプログラムも特定することができます。
しかし、ss コマンドで `sudo ss -talpn` で調査した方が読みやすいと個人的には思います。
```bash
$ lsof -i
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sadagent 542 ubuntu    7u  IPv6  16857      0t0  TCP *:6767 (LISTEN)
gotty    557 ubuntu    6u  IPv6  17488      0t0  TCP *:http-alt (LISTEN)
gotty    557 ubuntu    7u  IPv6  18947      0t0  TCP ip-172-31-35-60.us-east-2.compute.internal:http-alt->ip-172-31-16-109.us-east-2.compute.internal:51902 (ESTABLISHED)
```

ss コマンドでネットワークソケットを開いているプログラムを特定する例：
```bash
$ sudo ss -talpn
State    Recv-Q   Send-Q   Local Address:Port   Peer Address:Port   Process
LISTEN   0        4096     127.0.0.53%lo:53          0.0.0.0:*       users:(("systemd-resolve",pid=433,fd=14))
LISTEN   0        128            0.0.0.0:22          0.0.0.0:*       users:(("sshd",pid=626,fd=3))
LISTEN   0        4096                 *:6767              *:*       users:(("sadagent",pid=534,fd=7))
LISTEN   0        511                  *:80                *:*       users:(("apache2",pid=769,fd=4),("apache2",pid=768,fd=4),("apache2",pid=643,fd=4))
LISTEN   0        4096                 *:8080              *:*       users:(("gotty",pid=552,fd=6))
LISTEN   0        128               [::]:22             [::]:*       users:(("sshd",pid=626,fd=4))
```

以上です。

### 参考文献
- [【 lsof 】コマンド――オープンしているファイルを一覧表示する：Linux基本コマンドTips（298） - ＠IT](https://atmarkit.itmedia.co.jp/ait/articles/1904/18/news033.html)
- [SadServers - Troubleshooting Linux Servers](https://sadservers.com/scenarios) / "Saint John": what is writing to this log file?
