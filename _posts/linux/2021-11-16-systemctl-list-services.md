---
layout:        post
title:         "systemctlで有効・無効なサービス一覧を表示する"
type:          How-To
description:   "systemctl list-unit-filesとgrepを組み合わせて、起動時に有効化または無効化されているサービス一覧を表示する方法を説明します。"
tags:          [linux, systemd, systemctl]
status:        stable
stale_after:   2026-09-17T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-12T23:47:50Z
sources:
  - id:        ref-1
    resource:  https://amzn.to/3rkScj9
    title:     "サーバ構築研究会『CentOS8で作るネットワークサーバ構築ガイド』2020/8"
date:          2021-11-16
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

systemctlで有効・無効なサービス一覧を表示するには「systemctl list-unit-files -t service」コマンドを実行します。

また、起動時に有効化されるサービスの一覧は以下のコマンドで表示できます。
```bash
~]# systemctl list-unit-files -t service | grep enabled
```
起動時には無効化されるサービスの一覧は以下のコマンドで表示できます。
```bash
~]# systemctl list-unit-files -t service | grep disabled
```
以上です。


### 参考文献

- [サーバ構築研究会『CentOS8で作るネットワークサーバ構築ガイド』2020/8](https://amzn.to/3rkScj9) (p.827)
