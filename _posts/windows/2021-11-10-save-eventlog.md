---
layout:        post
title:         "Windowsのイベントログを保存する"
date:          2021-11-10
category:      Windows
cover:         /assets/cover1.jpg
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
