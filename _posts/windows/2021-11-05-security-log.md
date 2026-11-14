---
layout:        post
title:         "[Windows] セキュリティログで注目すべきイベントID"
type:          Reference
description:   "Windowsイベントビューアーのセキュリティログで監視・調査時に注目すべきログオンやプロセス作成、タスク登録等のイベントID一覧。"
tags:          [windows, security-log, event-log, security]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-06T14:33:42Z
date:          2021-11-05
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsの イベントビューアー(eventvwr.msc /s)＞Windowsログ＞セキュリティ で見ることができるセキュリティログで注目すべきイベントIDには以下のものがあります。

| イベントID | 説明
|------|----
| **4624** | アカウントが正常にログオンしました。
| 4672 | 新しいログオンに特権が割り当てられました。
| 4688 | 新しいプロセスが作成されました。
| **4697** | サービスがシステムにインストールされました。
| **4698** | スケジュールされたタスクが作成されました。
| **4702** | スケジュールされたタスクがアップデートされました。
| 4768 | Kerberos 認証チケット (TGT) が要求されました (ADサーバ)。
| 4769 | Kerberos サービス チケットが要求されました (ADサーバ)。
| 5140 | ネットワーク共有オブジェクトにアクセスしました。
| 5145 | クライアントに必要なアクセスを付与できるかどうかについて、ネットワーク共有オブジェクトがチェックされました。

以上です。
