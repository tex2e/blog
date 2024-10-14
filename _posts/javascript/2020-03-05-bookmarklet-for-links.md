---
layout:        post
title:         "[ブラウザ] Markdown/HTML用のリンクを生成するブックマークレット"
date:          2020-04-25
category:      JavaScript
cover:         /assets/cover14.jpg
redirect_from:
  - /misc/bookmarklet-for-markdown-link
  - /misc/bookmarklet-for-links
comments:      true
published:     true
# sitemap: false
# draft:   true
---

ブックマークレット（bookmarklet）の追加方法は Chrome > 上部のブックマークを右クリック > ページを追加 > URLにjavascriptを書いて保存、の手順です。
使用方法は、作成したブックマークレットをクリックすると、そのページのリンクを生成して、クリップボードにコピーされます。

### タイトルとURLからMarkdown用のリンク生成

**Markdown**用のリンクを生成するブックマークレットです。

名前：page title and url (**md**)

URL：

```
javascript:!function(){var e=document.createElement("textarea"),t=document.title.replace(/\[/g,"\\[").replace(/]/g,"\\]").replace(/\</g,'\\<').replace(/>/g,'\\>').replace(/\|/g,"\\|"),c=document.URL.replace(/\(/g,"%2528").replace(/\)/g,"%2529");e.textContent="["+t+"]("+c+")",document.querySelector("body").append(e),e.select(),document.execCommand("copy"),e.remove()}();
```

リンク生成の結果：

```markdown
[JavaScript リファレンス - JavaScript \| MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference)
```

圧縮する前のオリジナルのJavaScriptは以下の通りです。

```javascript
(function() {
  var e = document.createElement("textarea");
  var title = document.title
    .replace(/\[/g, '\\[').replace(/]/g, '\\]') // escape "[]"
    .replace(/\</g, '\\<').replace(/>/g, '\\>') // escape "<>"
    .replace(/\|/g, '\\|') // escape "|"
  var url = document.URL
    .replace(/\(/g, '%2528').replace(/\)/g, '%2529'); // escape "()"
  e.textContent = '[' + title + '](' + url + ')';
  document.querySelector('body').append(e);
  e.select();
  document.execCommand("copy");
  e.remove();
})();
```

正しくリンクが貼られるように、タイトルに含まれる角括弧(`[]`)とパイプ(`|`)をエスケープし、URLに含まれる丸括弧(`()`)をエスケープする処理をしています。
また、`|` をエスケープするのは、Markdownの処理系によっては（具体的にはkramdownですが）、上手に解釈できない場合があるからです。

### タイトルとURLからHTML用のリンク生成

**HTML**用のリンクを生成するブックマークレットです。

名前：page title and url (**href**)

URL：

```
javascript:!function(){var e=document.createElement("textarea"),t=document.title,c=document.URL;e.textContent="<a href=\""+c+"\">"+t+"</a>",document.querySelector("body").append(e),e.select(),document.execCommand("copy"),e.remove()}();
```

リンク生成の結果：

```markdown
<a href="https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference">JavaScript リファレンス - JavaScript | MDN</a>
```

### タイトルとURLからテキスト用のリンク生成

**テキスト**用にリンクを生成するブックマークレットです。

名前：page title and url (**txt**)

URL：

```
javascript:!function(){var e=document.createElement("textarea"),t=document.title,c=document.URL;e.textContent=t+"\n"+c,document.querySelector("body").append(e),e.select(),document.execCommand("copy"),e.remove()}();
```

リンク生成の結果：

```markdown
JavaScript リファレンス - JavaScript | MDN
https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference
```


#### 参考文献

- [JavaScript Minifier](https://javascript-minifier.com/)
- [ブックマークレットでmarkdown用のリンクを生成する - Qiita](https://qiita.com/kyo_nanba/items/81d81164360347fb3732)
