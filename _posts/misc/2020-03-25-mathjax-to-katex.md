---
layout:        post
title:         "JekyllでMathJaxからKaTeXに移行した"
date:          2020-03-25
category:      Misc
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

今まで MathJax というエンジンを使って $\LaTeX$ の数式を表示していましたが、記事を書いている最中に Jekyll + MathJax は非常にレスポンスが遅いので、数式のレンダリング速度を向上させるために $\KaTeX$ に移行しました。MathJax は SVG に対して、KaTeX は HTML と CSS だけで構成されているので、KaTeX の方が単純に描画速度が速いです。
以下の数式を右クリックから検証してみると、すべての要素が span で構成されていることが確認できます。

$$
\frac{\pi}{2} =
\left( \int_{0}^{\infty} \frac{\sin x}{\sqrt{x}} dx \right)^2 =
\sum_{k=0}^{\infty} \frac{(2k)!}{2^{2k}(k!)^2} \frac{1}{2k+1} =
\prod_{k=1}^{\infty} \frac{4k^2}{4k^2 - 1}
$$


### KaTeX の導入

KaTeX 導入の仕方は、まず html の head に以下のコードを追加します。

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.css" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.js" integrity="sha384-y23I5Q6l+B6vatafAwxRu/0oK/79VlbSz7Q9aiSZUvyWYIYsd+qj+o24G5ZU2zJz" crossorigin="anonymous"></script>
<!-- Automatically render math in text elements -->
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
  renderMathInElement(document.body, {
    delimiters: [
      {left: "$$", right: "$$", display: true},
      {left: "$", right: "$", display: false},
    ]
  });
});
</script>
```

1. まず、katex の CSS を読み込みます。
2. katex の本体の JavaScript を defer で読み込むことで、ページのレンダリング速度を向上させます。
3. これだけでは自動で数式を変換してくれないので、auto-render.js 拡張を読み込みます。
4. HTMLのDOMが読み込み終わったら renderMathInElement で数式のレンダリングをします。
  - オプションで、`$$` で囲んだ部分は Display モード、`$` は Inline モードを指定します。

KaTeX の設定はこれで終わりです。


### MathJax から KaTeX に移行する際の注意点

注意点は、まずそのまま移しても正しく表示されないでエラーになることがある点です。
自身のサイトで移行するときに LaTeX の数式を修正した内容の一覧をリストにしてまとめました。

- `\begin{align}` --> `\begin{aligned}` : align は aligned に変更します。
- `\def` --> `\gdef` : マクロをすべての数式で使いたい場合は `\gdef` (Global DEFine) に変更します。
- Unicode文字 --> `\text{}` : 数式内での説明は text の中に入れます。
- `\text{sample_variable}` はダメ : MathJaxではtextの中でアンダースコアが使えたのですが...
- `\tag{}` は複数回使えない : MathJaxではalign環境で複数の `\tag{}` が使えたのですが...
- `\text{#}` --> `\#` : #は生では使えないし、textの中でも使えないようになってる。
- `\begin{eqnarray}` --> `\begin{aligned}` : eqnarrayはもう古いです。

MathJax は細かいエラーに寛容でしたが、KaTeX はエラーに対して厳しくなっています。

<br>
### Jekyll で KaTeX を使う場合

Jekyll で使う場合はもう少し設定が必要です。

`_config.yml` の設定に以下を追加します。

```yaml
kramdown:
  # 数式はKaTeXでレンダリングする
  math_engine: katex
  # 数式で'が別文字に変換するのを防ぐための設定
  smart_quotes: ["apos", "apos", "quot", "quot"]
```

1. エンジンはデフォルトで mathjax になっているので、katex に変更します。
2. kramdown の影響で数式内の「' (\\u0027)」が「’ (\\u2019)」に変更されるのを防ぐために smart_quotes を指定します。これによって微分などの記号が正しく表示されます。

### Github Pages で使う場合

GitHub Pages ではセキュリティポリシーの関係で kramdown しか使えず、さらに math_engine には mathjax が強制的に使用される設定なので [^1] [^2]、JavaScript書いて何とかするしかありません。

[^1]: [GitHub PagesとJekyllについて](https://help.github.com/ja/enterprise/2.15/user/articles/about-github-pages-and-jekyll)
[^2]: [pages-gem/configuration.rb at master -- 上書きされるオプション](https://github.com/github/pages-gem/blob/master/lib/github-pages/configuration.rb#L50-L55)

```yaml
# _config.yml
kramdown:
  math_engine: mathjax # katexと書いてもGithubPagesはmathjaxに上書きする
```

html の head を以下のコードに変更します。

```js
document.addEventListener("DOMContentLoaded", function() {
  $("script[type='math/tex']").replaceWith(
    function () {
      var tex = $(this).text();
      return "<span class=\"inline-equation kdmath\">$" + tex + "$</span>";
  });

  $("script[type='math/tex; mode=display']").replaceWith(
    function () {
      var tex = $(this).text();
      tex = tex.replace('% <![CDATA[', '').replace('%]]>', '');
      return "<div class=\"equation kdmath\">$$" + tex + "$$</div>";
  });

  renderMathInElement(document.body, {
    delimiters: [
      {left: "$$", right: "$$", display: true},
      {left: "$", right: "$", display: false},
    ]
  });
});
```

kramdownが出力した `<script type='math/tex'>` の形式を JavaScript で再度 `$$` の形に戻すという何とも不毛なことをやっています。

`$` と `$$` を使うと、kramdown が書き換えてしまうので、`\( \)` と `\[ \]` を使う選択肢もありますが、`$` の方が慣れているからな...という理由でこんな感じの運用になっています。
Github Pages が kramdown の math_engine の設定を上書きしなければ、こんな面倒なことにはならないのですがね。


### 数式を表示したいページだけ KaTeX を読み込む

すべてのページで KaTeX を読み込むと、数式を使わないページの読み込み速度が落ちます。
そこで、必要なページだけ KaTeX を読み込むようにします。

まず、ページ変数に `latex: true` を設定します。

```yaml
---
title:  "タイトル"
date:   2020-02-02
...
latex:  true
---

本文
```

{% raw %}
次に、`page.latex == true` のときだけ、katex を読み込むようにします。
{% if ... %} {% endif %} の書き方の詳細は [Liquid](https://shopify.github.io/liquid/) を参照してください。
{% endraw %}

{% raw %}
```html
{% if page.latex %}
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.css" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.js" integrity="sha384-y23I5Q6l+B6vatafAwxRu/0oK/79VlbSz7Q9aiSZUvyWYIYsd+qj+o24G5ZU2zJz" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous"></script>
...
{% endif %}
```
{% endraw %}

これで、指定したページのみ KaTeX を読み込ませることができます。

以上です。

---
