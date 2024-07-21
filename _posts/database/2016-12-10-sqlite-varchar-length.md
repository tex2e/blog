---
layout:        post
title:         "[SQLite] VARCHAR型の文字数を制限する方法"
date:          2016-12-10
category:      Database
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /db/sqlite-varchar-length
comments:      false
published:     true
---

初めに言っておく必要がありますが、残念なことに、SQLite のテーブルのスキーマでは文字列の最大の長さを指定することはできません。
SQLiteの公式サイトにある「よくある質問」の中の、文字列型 TEXT が取り得る最大の長さについての質問と回答の原文とその意訳は以下の通りです。

> (Q) What is the maximum size of a VARCHAR in SQLite?
>
> (A) SQLite does not enforce the length of a VARCHAR. You can declare a VARCHAR(10)
> and SQLite will be happy to store a 500-million character string there.
> And it will keep all 500-million characters intact. Your content is never truncated.
> SQLite understands the column type of ”VARCHAR(N)” to be the same as ”TEXT”,
> regardless of the value of N.

> (質問) SQLite での VARCHAR の最大のサイズはいくつか?
>
> (回答) SQLite では VARCHAR の長さを強制しない。VARCHAR(10) と書いた場合でも、
> SQLite は 500 万文字まで文字列を切り取らずにそのまま格納する。
> なぜなら、SQLite は VARCHAR(N) のように N を指定したとしても、TEXT 型として解釈するからだ。

したがって、SQLite データベースのスキーマで VARCHAR(100) のように文字の長さを指定したとしても、
ただの TEXT 型として解釈するため、SQLite のスキーマで文字の長さは指定しても意味がない。

結論
----------

SQLite のテーブルのスキーマでは文字列の最大の長さを指定することはできない。

<br>

### 参考文献

- [SQLite Frequently Asked Questions](https://www.sqlite.org/faq.html#q9)
