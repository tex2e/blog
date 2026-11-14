---
layout:        post
title:         "[Windows] イベントログを保存する"
type:          How-To
description:   "Windowsのイベントビューアーで期間フィルターを適用したセキュリティログをevtx形式および日本語表示情報付きで保存する手順を解説。"
tags:          [windows, event-log, security-log]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-07T23:30:00Z
date:          2021-11-10
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

Windowsのイベントログは、以下の手順で保存することができます。

1. 「イベントビューアー(eventvwr.msc /s)」＞「Windows ログ」＞「セキュリティ」を選択する
2. 「現在のログをフィルター」を選択し、「ログの日付」で採取したいログの期間を指定後、「OK」ボタンを押下し、フィルターを適用する
3. 「Windowsログ」＞「セキュリティ」を右クリック＞「すべてのイベントを名前を付けて保存」を選択する
4. 「*.evtx」形式で保存する
5. 「表示情報」で「日本語」を選択し保存する
6. evtxファイルとLocaleMetaDataフォルダが作成されたことを確認する
7. ログ確認時は evtx ファイルをダブルクリックする

以上です。
