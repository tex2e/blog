---
layout:        post
title:         "SUID/SGIDファイルをfindコマンドで見つける"
date:          2021-11-13
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

利便性のために sudo を使わずに管理者権限で実行したいファイルには SUID や SGID が設定されています。

- SUIDファイルを実行すると、ファイル所有者の権限で実行される
- SGIDファイルを実行すると、ファイルの属するグループの権限で実行される

sudo を使わなくても管理者権限として実行できることは、利便性が上がる反面、攻撃者による権限昇格に利用される場合もあります。

SUIDファイルやSGIDファイルを見つけ出すには、以下のコマンドを実行します。

```cmd
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
```

他の環境と比較して通常とは異なるファイルが見つかれば内容を確認し、システム運用に不要な場合は削除やSUID・GUIDのフラグを外します。

以上です。

