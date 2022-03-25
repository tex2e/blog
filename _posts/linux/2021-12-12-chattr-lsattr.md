---
layout:        post
title:         "Linuxで消せない・編集できないファイルの作り方 (chattr)"
date:          2021-12-12
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

chattrコマンドはext2/ext3/ext4ファイルシステムで拡張属性を設定するためのコマンドで、設定した属性はlsattrコマンドでのみ確認できます。

ファイルに対してi属性を付与 (chattr +i) すると、不変 (Immutable) になり、root権限であっても、編集も削除もできなくなります。
以下は不変の属性を付与すると編集も削除もできないことを確認する例です。
```bash
~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
~]# touch /tmp/test.txt
~]# lsattr /tmp/test.txt
-------------------- /tmp/test.txt
~]# chattr +i /tmp/test.txt
~]# lsattr /tmp/test.txt
----i--------------- /tmp/test.txt        # <= 不変 (Immutable) 属性が付与された

~]# rm /tmp/test.txt
rm: 通常の空ファイル 'test.txt' を削除しますか? y
rm: 'test.txt' を削除できません: 許可されていない操作です

~]# echo ok >> /tmp/test.txt
-bash: test.txt: 許可されていない操作です

~]# chattr -i /tmp/test.txt
~]# lsattr /tmp/test.txt
-------------------- /tmp/test.txt
~]# rm /tmp/test.txt
rm: 通常の空ファイル 'test.txt' を削除しますか? y
```

以上です。

#### 参考文献
- [特定のファイルをrmコマンドなどで削除できないようにする方法(chattr、lsattrコマンド) - Qiita](https://qiita.com/riekure/items/6def7f813ebe03dd5850)
- [chattr - コマンド (プログラム) の説明 - Linux コマンド集 一覧表](https://kazmax.zpp.jp/cmd/c/chattr.1.html)
