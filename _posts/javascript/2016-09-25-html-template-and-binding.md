---
layout:        post
title:         "[JavaScript] テンプレートエンジンを使わないで、コードの埋め込みを行う"
date:          2016-09-25
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---


JavaScriptでテンプレートエンジンを使わないで、コードの埋め込みを行う方法について。

{% raw %}
1. テンプレートの作成 -- 所謂、複数行にわたる文字列の作成方法
2. 変数の埋め込み -- テンプレート内の `{{ }}` の中身を評価して埋め込む
{% endraw %}


テンプレートの作成
-------------------------

始めに、複数行にわたる文字列の作成方法について説明する。

### Template literal による作成

ES2015（ES6）の Template literal が使える場合は、これを使います。

{% raw %}
```js
var templateHTML = `<li>
  <ul>{{ 1 + 1 }}</ul>
  <ul><a href="{{ this.path }}">{{ this.name }}</a></ul>
</li>`
```
{% endraw %}

なお、IE11 は ES2015 にほとんど対応していないので、
どの環境でも動かせるようにするには次のやり方でテンプレートを作成します。

### Function.prototype.toString による作成

Function.prototype.toString は関数のソースコードを表す文字列（コメントも含む）
を返してくれるので、この1行目と最後の行を消した残りの行をテンプレートとして使います。

{% raw %}
```js
var templateHTML = (function () {/*
<li>
  <ul>{{ 1 + 1 }}</ul>
  <ul><a href="{{ this.path }}">{{ this.name }}</a></ul>
</li>
*/}).toString().split("\n").slice(1, -1).join("\n");
```
{% endraw %}


変数の埋め込み
-------------------------

{% raw %}
次に、テンプレート内の `{{ }}` の中身を評価して埋め込む方法について説明する。
{% endraw %}

### replace と bind と eval

{% raw %}
replaceを使って、`{{ ... }}` の中の部分を取り出します。
取り出した部分を replacer で eval し、それを置き換える文字列として返します。
この replacer は無名関数なので、bind でオブジェクトと束縛させると、
オブジェクトに定義した任意の名前が this を介してアクセスできるようになります。
{% endraw %}

{% raw %}
```js
console.log(templateHTML);
// <li>
//   <ul>{{ 1 + 1 }}</ul>
//   <ul><a href="{{ this.path }}">{{ this.name }}</a></ul>
// </li>

// 変数の埋め込み
var boundTemplateHTML =
  templateHTML.replace(/{{(.*?)}}/g, function (match, p1) {
    return eval(p1);
  }.bind({
    path: "/path/to/index.html",
    name: "index"
  }));

console.log(boundTemplateHTML);
// <li>
//   <ul>2</ul>
//   <ul><a href="/path/to/index.html">index</a></ul>
// </li>
```
{% endraw %}


まとめ
-------------------------

この方法を使うことで、テンプレートエンジンを使わなくてもテンプレートエンジンみたいなことができるようになります。
ただし、変数へのアクセスに this を使わないといけないので、
それがいやならテンプレートエンジンを使うことをお勧めします。
