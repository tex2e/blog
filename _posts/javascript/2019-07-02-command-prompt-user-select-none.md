---
layout:        post
title:         "コマンド例の「$」の部分をコピペさせない"
menutitle:     "Webページでコマンド例の「$」の部分をコピペさせない"
date:          2019-07-02
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: 
  - /blog/command-prompt-user-select-none
  - /misc/command-prompt-user-select-none
comments:      true
published:     true
---

Webページで <code><span style="user-select: none">$ </span>command args</code> のようにコマンド例を示すときに `$` をコピペさせないようにする方法について説明します。
加えて、Prism.js で `$` をコピペさせない設定方法も紹介します。

結論から言うと、`$` の部分を user-select: none にします。
何もしていないHTMLでは以下のように書きますが、これでは `$` も選択できるので、コピーされてしまいます。

- HTMLソース

  ```html
  <pre><code>$ command args</code></pre>
  ```

- 実際の表示のされ方 (`$` の部分は選択できます)

  <pre><code>$ command args</code></pre>

そこで `$ ` の部分を span で囲んでスタイルを user-select: none にします。
こうすることで、`$` は選択できなくなり、コピーされなくなります。

- HTMLソース

  ```html
  <pre><code><span style="user-select: none">$ </span>command args</code></pre>
  ```

- 実際の表示のされ方 (`$` の部分が選択できません)

  <pre><code><span style="user-select: none">$ </span>command args</code></pre>


### Prism.js で \$ をコピペさせない

Webページで表示させるプログラムのシンタックスハイライトに Prism.js を使っている場合は、`$` の部分を token として認識させることで簡単に、user-select: none を適用させることができます。

bash の行頭にある `$` を選択できないようにするには次のHTMLを使います。

```html
<link rel="stylesheet" href="path/to/prism.css">
<script src="path/to/prism.js"></script>

<!-- token の追加 -->
<script type="text/javascript">
  Prism.languages.bash.prompt = /^\$ /m;
</script>

<!-- token に対するスタイルの設定 -->
<style>
  .token.prompt {
    user-select: none;
  }
</style>
```

正規表現 `/^\$ /m` について、オプション m を指定すると、行頭 `^` のマッチングが、文字列の先頭だけでなく、各行の行頭にもマッチするようになります。これにより、各行の行頭にある `$` だけを token として取り出すことができます。

取り出した token は <span class="token prompt"> タグが付けられるので、CSSで .token.prompt のスタイルを user-select: none にします。

結果は以下の通りです。コピーするときのUXがいい感じになりました。行頭の `$` は選択できませんが、変数名などは選択できることが確認できると思います。

```bash
$ echo hello world
$ echo $PATH
```

ちなみに元ネタは @junya さんのツイートです[^1]。

### Prism.js で PS> をコピペさせない

2021/10追記：PowerShellのプロンプトである `PS>` を選択できないようにするには、次のJavaScriptを追加します。

```js
Prism.languages.insertBefore('powershell', 'function', {
  'prompt': /^PS> /m,
})
```

PowerShellの字句解析でPromptの部分「PS>」もtokenにするためのプログラムです。
デフォルトだとPSがfunctionと判定されるので、insertBeforeでfunctionの解析を前に先に評価するようにする必要があります。

以上です。

-----

[^1]: Webページで &quot;＄ command args&quot; みたいなコマンド例をユーザーにコピペさせる際に、&quot;＄&quot; の部分 user-select: none しておくとUXがいい感じになるのか 📝  -- ᴊᴜɴʏᴀ oɢᴜ®ᴀ @junya
