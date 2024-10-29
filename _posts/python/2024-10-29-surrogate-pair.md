---
layout:        post
title:         "[Python] サロゲートペアのバイト列を文字列に変換する方法"
date:          2024-10-29
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Pythonでサロゲートペアのバイト列を文字列に変換する方法について説明します。

### 文字列から作る場合

UTF-16の文字列に含まれている `DB〜DD〜` の部分をサロゲートペアとして解釈させるには、encode の第二引数に「surrogatepass」を指定します。
これを指定することで、サロゲートペアが1つの文字として扱われるようになります。

```python
"\u845B\uDB40\uDD01".encode('utf-16', 'surrogatepass').decode('utf-16')
```

### バイト列から作る場合

バイト列を decode で文字列に変換するときは、バイト列に含まれるサロゲートペアは自動的に扱われます。

```python
b"\x5B\x84\x40\xDB\x01\xDD".decode('utf-16')
b"\x5B\x84\x40\xDB\x01\xDD".decode('utf-16-le')
b"\x84\x5B\xDB\x40\xDD\x01".decode('utf-16-be')
```


実行結果：

```console
>>> "\u845B\uDB40\uDD01".encode('utf-16', 'surrogatepass').decode('utf-16')
'葛󠄁'
>>> b"\x5B\x84\x40\xDB\x01\xDD".decode('utf-16')
'葛󠄁'
>>> b"\x5B\x84\x40\xDB\x01\xDD".decode('utf-16-le')
'葛󠄁'
>>> b"\x84\x5B\xDB\x40\xDD\x01".decode('utf-16-be')
'葛󠄁'
```

以上です。


### 参考資料

- [How can I convert surrogate pairs to normal string in Python? - Stack Overflow](https://stackoverflow.com/questions/38147259/how-can-i-convert-surrogate-pairs-to-normal-string-in-python)
- [とほほの文字コード入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/charset.html)
