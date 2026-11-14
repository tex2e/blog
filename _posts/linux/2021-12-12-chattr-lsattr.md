---
layout:        post
title:         "Linuxで消せない・編集できないファイルの作り方 (chattr)"
type:          How-To
description:   "extファイルシステムでchattrコマンドによりファイルやディレクトリへ不変属性を付与・解除し、lsattrで確認する方法を説明します。"
tags:          [linux, chattr, filesystem, hardening]
status:        stable
stale_after:   2026-11-05T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-12-03T11:01:51Z
sources:
  - id:        ref-1
    resource:  https://qiita.com/riekure/items/6def7f813ebe03dd5850
    title:     "特定のファイルをrmコマンドなどで削除できないようにする方法(chattr、lsattrコマンド) - Qiita"
  - id:        ref-2
    resource:  https://kazmax.zpp.jp/cmd/c/chattr.1.html
    title:     "chattr - コマンド (プログラム) の説明 - Linux コマンド集 一覧表"
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

### ファイル
ファイルに対してi属性を追加すると、不変 (Immutable) になり、root権限であっても、編集も削除もできなくなります。
```bash
chattr +ia test.txt  # 属性を追加
chattr -ia test.txt  # 属性を削除
```
以下は不変の属性を追加すると編集も削除もできないことを確認する例です。
```bash
~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
~]# touch /tmp/test.txt
~]# lsattr /tmp/test.txt
-------------------- /tmp/test.txt
~]# chattr +i /tmp/test.txt
~]# lsattr /tmp/test.txt
----i--------------- /tmp/test.txt        # <= 不変 (Immutable) 属性が追加された

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


### ディレクトリ
ディレクトリに対しても同様に属性の追加と削除ができます。
```bash
chattr +ia .  # 属性を追加
chattr -ia .  # 属性を削除
```

以上です。

#### 参考文献
- [特定のファイルをrmコマンドなどで削除できないようにする方法(chattr、lsattrコマンド) - Qiita](https://qiita.com/riekure/items/6def7f813ebe03dd5850)
- [chattr - コマンド (プログラム) の説明 - Linux コマンド集 一覧表](https://kazmax.zpp.jp/cmd/c/chattr.1.html)
