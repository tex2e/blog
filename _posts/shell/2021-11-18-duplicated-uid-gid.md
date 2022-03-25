---
layout:        post
title:         "UID / GID の重複を検出するためのシェルスクリプト"
date:          2021-11-18
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

UID (ユーザ識別子) は、Linuxのシステムでユーザを識別するための番号です。
また、GID (グループ識別子) はグループを識別するための番号です。
ユーザ名が異なる場合でも UID が同じ場合は、UIDが共有されて所有者も同じになるため、意図しないアクセス権限を与えてしまう可能性があります。

UIDの重複を見つけるためのシェルスクリプト (Bash)：
```bash
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x; do
  [ -z "$x" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
    echo "Duplicate UID ($2): $users"
  fi
done
```

GIDの重複を見つけるためのシェルスクリプト (Bash)：
```bash
cut -d: -f3 /etc/group | sort | uniq -d | while read x; do
  echo "Duplicate GID ($x) in /etc/group"
done
```

useraddコマンドを使うと、重複が無いように自動的に番号を割り当てます。
しかし、newusersコマンドを使うと、一括でユーザを追加できる反面、UIDが重複してしまう問題が起こる可能性があります。

```bash
~]# cat users.txt
exampleUser:x:0:0::/home/root:/bin/bash

~]# newusers users.txt
~]# cat /etc/passwd
~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
...
exampleUser:x:0:0::/home/root:/bin/bash

~]# id exampleUser
uid=0(root) gid=0(root) groups=0(root)
```
以上です。

#### 参考文献
- CIS_CentOS_Linux_8_Benchmark_v1.0.1.pdf

