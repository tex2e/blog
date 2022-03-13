---
layout:        post
title:         "useradd, usermod によるグループへの追加"
date:          2021-05-22
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

### ユーザの追加

```bash
sudo useradd user1
```

ユーザ追加時にグループにも追加するには -G オプションを使います。

```bash
sudo useradd user1 -G docker
```

`cat /etc/passwd` で正しくユーザ追加できたか確認できます。

### グループに追加

ユーザが所属するサブグループに追加します。
`-a` を付け忘れると追加ではなく上書きになってしまうので注意。
特に sudoersのユーザはグループ追加に失敗するとsudoする権限がなくなるので要注意 (sudoというグループに所属するユーザはsudoが実行できるため。/etc/sudoers 参照)

```bash
sudo usermod -aG docker user1
```

`cat /etc/group` で正しくユーザをグループに追加できたか確認できます。


### 確認

ユーザの追加と所属が正しくできたかは `id` コマンドで確認できます。

```bash
$ id user1
uid=1002(user1) gid=1002(user1) groups=1002(user1),998(docker)
```

以上です。
