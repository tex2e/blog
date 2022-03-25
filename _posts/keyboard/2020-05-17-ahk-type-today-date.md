---
layout:        post
title:         "AutoHotKeyで今日の日付を入力する"
date:          2020-05-17
category:      Keyboard
cover:         /assets/cover14.jpg
redirect_from: /misc/ahk-type-today-date
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

プログラムに変更履歴を書くときなどに日付がすぐ入力できると嬉しいので、
AutoHotKeyのホットストリングという機能を使って、特定の文字を入力したときに今日の日付が入力されるようにします。

AutoHotKeyでホットストリングの書き方は以下の通りです。

```code
::特定の文字列::置き換えたい文字列
```

この例では
「ddd」と入力すると「2020/05/17」(年と月と日) に置き換わり、
「dd」と入力すると「5/17」(月と日) に置き換わります。
ただし、実際には ddd と入力した後に終了文字を入力したタイミングでホットストリングが発動します。
終了文字は、Enter, Space, Tab などがあります。

AutoHotKey.ahk

```code
::ddd::
  FormatTime,TimeString,,yyyy/MM/dd
  Send,%TimeString%
  Return
::dd::
  FormatTime,TimeString,,M/d
  Send,%TimeString%
  Return
```

AutoHotKey の FormatTime コマンドは 第1引数に結果を格納する変数、第3引数に出力書式 を指定します。

実行すると、今日の日付が簡単に入力できるようになります。

### 参考文献

- [ホットストリング - AutoHotkey Wiki](http://ahkwiki.net/Hotstrings)
- [FormatTime - AutoHotkey Wiki](http://ahkwiki.net/FormatTime)
- [AutoHotkeyで今日の日付を入力する - Sprint Life](http://sprint-life.hatenablog.com/entry/2015/03/22/214744)
