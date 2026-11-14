---
layout:        post
title:         "[Docker] compose exec時のエラー「the input device is not a TTY」の対処法"
type:          Troubleshooting
description:   "Jenkinsやcronなど非対話環境でdocker-compose execを実行した際のTTYエラーに対し、-Tオプションで擬似端末を無効化する対処法。"
tags:          [infra, docker, docker-compose, jenkins, troubleshooting]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-10-23T09:53:35Z
sources:
  - id:        ref-1
    resource:  https://hodalog.com/how-to-resolve-the-error-that-the-input-device-is-not-a-tty/
    title:     "dockerコマンドをcronで実行させたら「TTYが無いよ」と怒られた件 \\| Hodalog"
date:          2022-10-24
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /infrastructure/docker-compose-exec-error
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

docker-compose exec を Jenkins 経由で実行した際にエラー「the input device is not a TTY」の対処法について説明します。

```
+ docker-compose exec <コンテナ名> <コマンド>
the input device is not a TTY
```

### 対処法

docker-compose exec に -T オプションを追加して、疑似ターミナル割り当てを無効化します。

```bash
$ docker-compose exec -T <コンテナ名> <コマンド>
```

TTYの割り当てをやめて、標準入力を開き続けないようにすることで、cron や jenkins が docker-compose exec を実行できるようになります。

以上です。

### 参考文献
- [dockerコマンドをcronで実行させたら「TTYが無いよ」と怒られた件 \| Hodalog](https://hodalog.com/how-to-resolve-the-error-that-the-input-device-is-not-a-tty/)
