---
layout:        post
title:         "SELinuxによるアクセス拒否ログを見つける"
menutitle:     "SELinuxによるアクセス拒否ログを見つける (audit.log, messages)"
date:          2021-11-03
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

SELinuxのアクセス拒否のログは /var/log/audit/audit.log や /var/log/messages に出力されます。
SELinuxに関するログを見つけるには「SELinux is preventing」や「denied」で抽出します。

#### /var/log/audit/audit.log

/var/log/audit/audit.log には「denied」というメッセージとともにアクセス拒否ログが出ます。
```bash
~]# grep "denied" /var/log/audit/audit.log
```
ログ記録例：
```
type=AVC msg=audit(0000000000.639:792): avc:  denied  { read } for  pid=4635 comm="cat" name="example.txt" dev="dm-0" ino=33575049 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:admin_home_t:s0 tclass=file permissive=0
```

#### /var/log/messages

/var/log/messages には「SELinux is preventing」というメッセージとともにエラーが出ます。
```bash
~]# grep "SELinux is preventing" /var/log/messages
```
ログ記録例：
```
localhost setroubleshoot[4637]: SELinux is preventing /usr/bin/cat from read access on the file example.txt. For complete SELinux messages run: sealert -l e9c5f189-8574-4467-8c68-6d4c7b79b6bd
```

#### tail -f

アクセス拒否ログを監視する場合は、tail -f と grep を組み合わせて実行します。

```bash
~]# tail -f /var/log/audit/audit.log | grep "denied"
~]# tail -f /var/log/messages | grep "SELinux is preventing"
```

以上です。
