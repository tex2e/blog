---
layout:        post
title:         "Markdown用のリンクを作るbookmarklet"
date:          2020-03-05
category:      Misc
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Markdownで書いているときに他のページへのリンクを作るブックマークレットが便利なので、メモとして残しておきます。

Markdown用のリンクを作ってクリップボードにコピーするJS：

```javascript
(function() {
  var e = document.createElement("textarea");
  var title = document.title
    .replace(/\[/g, '\\[').replace(/]/g, '\\]') // escape "[]"
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

ワンライナーにして、ブックマークレットに保存するもの：

```javascript
javascript:!function(){var e=document.createElement("textarea"),t=document.title.replace(/\[/g,"\\[").replace(/]/g,"\\]").replace(/\|/g,"\\|"),c=document.URL.replace(/\(/g,"%2528").replace(/\)/g,"%2529");e.textContent="["+t+"]("+c+")",document.querySelector("body").append(e),e.select(),document.execCommand("copy"),e.remove()}();
```

正しくリンクが貼られるように、タイトルに含まれる角括弧(`[]`)とパイプ(`|`)をエスケープし、URLに含まれる丸括弧(`()`)をエスケープする処理をしています。

`|` をエスケープするのは、Markdownの処理系によっては（具体的にはkramdownですが）、上手に解釈できない場合があるからです。

#### 参考文献

- [JavaScript Minifier](https://javascript-minifier.com/)
- [ブックマークレットでmarkdown用のリンクを生成する - Qiita](https://qiita.com/kyo_nanba/items/81d81164360347fb3732)
