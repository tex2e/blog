---
layout:        post
title:         "[Windows] ローカルのAdministratorsグループに所属するアカウントの確認"
type:          How-To
description:   "コマンドプロンプトのnet localgroup administratorsでローカル管理者グループ所属アカウントを確認し不要ユーザを削除する方法を解説。"
tags:          [windows, cmd, administration, security]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T07:38:55Z
date:          2021-11-18
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

WindowsのローカルのAdministratorsグループに所属するアカウントの一覧を表示するには「net localgroup administrators」をコマンドプロンプトに入力します。

```cmd
> net localgroup administrators

エイリアス名     administrators
コメント         コンピューター/ドメインに完全なアクセス権があります。

メンバー
-------------------------------------------------------------------------------
Administrator
Domain Admins
Enterprise Admins

コマンドは正常に終了しました。
```
管理者ユーザを削除するには、
設定＞アカウント＞他のユーザ から対象のアカウントを選択して削除します。

以上です。

