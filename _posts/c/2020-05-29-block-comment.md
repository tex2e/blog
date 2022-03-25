---
layout:        post
title:         "C言語風の範囲コメントで排他的に片方のコードのみを有効にする"
date:          2020-05-29
category:      C
cover:         /assets/cover14.jpg
redirect_from: /misc/block-comment
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

2つのプログラムがあって、一方だけを有効にする範囲コメントに書き方について。

C言語風なら `//*` と `/*/` と `//*/` で囲むことで、後者のコードだけが実行され、先頭コメントを `/*` に変えることで、前者のコードだけが実行されます。

{% comment %}
```c
//*
value = 111;
/*/
value = 222;
//*/
```
{% endcomment %}

<pre class="language-sql"><code class=""><span class="token comment">//*</span>
value <span class="token operator">=</span> <span class="token number">111</span><span class="token punctuation">;</span>
<span class="token comment">/*/
value = 222;
//*/</span>
</code></pre>

```c
/*
value = 111;
/*/
value = 222;
//*/
```

SQLなら `--/*` と `/*/` と `--*/` で囲むことで、後者のコードだけが実行され、先頭コメントを `/*` に変えることで、前者のコードだけが実行されます。
(2020/6/26追記) SQLite3では問題なくできるのですが、他の環境で実際に試してみると場合によっては構文エラーで怒られてしまいます。どのSQLの実行環境でも使えるわけではないことに注意してください。

```sql
--/*
select * from table where condition
/*/
update table set col='value' where condition
--*/
```

```sql
/*
select * from table where condition
/*/
update table set col='value' where condition
--*/
```

最近のエディタを使っていれば Ctrl + / でコメントアウトできるので、この排他的な範囲コメントの技を使うことはあまりないですが、知っているとデバッグとかが少し楽になります。
