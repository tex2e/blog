---
layout:        post
title:         "[Windows] 監査ログのログオンタイプ一覧"
date:          2021-11-06
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

### ログオンの監査ログ
WindowsのセキュリティログでイベントIDが4624が記録されるのは、アカウントが正常にログオンしたときです。
ログに記録されているログオンタイプは、サーバやPCへのログイン方法を表します。
2～11の値はそれぞれ以下の意味を表します。

| 種類 | ログオン名 | 説明
|----|--------|-------
|  **2** | **対話型** | このコンピュータへログオンした。
|  **3** | **ネットワーク** | ネットワーク経由でこのコンピュータへログオンした。
|  4 | Batch | バッチ処理により自動的にログオンした。
|  5 | サービス | サービスコントロールマネージャによりサービスが開始された。
|  7 | ロック解除 | 既存のリモートデスクトップセッションへ再接続した。
|  8 | NetworkCleartext | ユーザーがネットワーク経由でこのコンピュータへログオンした。
|  9 | NewCredentials | 呼び出し元が現在のトークンを複製し、発信接続の新しい資格情報を指定した。
| **10** | **RemoteInteractive** | ユーザーがターミナルサービスまたはリモートデスクトップを使用して、リモート操作でこのコンピュータにログオンした。
| 11 | CachedInteractive | ユーザーがこのコンピュータに保存されているネットワーク資格情報を使用して、このコンピュータにログオンしました。

ログオンタイプ値について、通常のログイン時は「2」、net useコマンドなどのネットワーク経由でログオンした場合は「3」、リモートデスクトップでログオンした場合は「10」となります。

以上です。

#### 参考文献
- [ログオン イベントの監査 (Windows 10) - Windows security \| Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/security/threat-protection/auditing/basic-audit-logon-events)
