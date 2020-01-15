---
layout:        post
title:         "Unicodeの正規化とテキストのクレンジング"
date:          2020-01-13
category:      Python
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Unicodeで書かれたテキストは、全角や半角などの文字が混在している場合があり、データベースに入力するときに統一させたいときなどにUnicodeの正規化が必要になります。
Unicodeの正規化をすることで、文字の使用が統一されてトラブルが少なくなるメリットがあります。

### Unicodeの正規化

Pythonには unicodedata という標準ライブラリがあり、これを利用すれば一発でUnicodeを正規化することができます。

```python
import unicodedata

text = '①：１２３㌔バイトのﾃｷｽﾄﾃﾞｰﾀを，ＣＬＥＡＮＳingする。'
print("Before:", text)
text = unicodedata.normalize('NFKC', text)
print("After: ", text)
# => Before: ①：１２３㌔バイトのﾃｷｽﾄﾃﾞｰﾀを，ＣＬＥＡＮＳingする。
# => After:  1:123キロバイトのテキストデータを,CLEANSingする。
```

英数字と記号は「全角から半角に」変換され、日本語は「半角から全角に」変換されます。

### 一部の全角記号は変換しない

しかし、場合によっては変換して欲しくないときがあります。
たとえば、MeCabでは形態素解析するときに、半角の記号が入力されると、その記号を「名詞,サ変接続」と判断してしまう現象がおきます。

```console
$ echo "（テスト）" | mecab
(		名詞,サ変接続,*,*,*,*,*
テスト	名詞,サ変接続,*,*,*,*,テスト,テスト,テスト
)		名詞,サ変接続,*,*,*,*,*
```

なので丸括弧 () や感嘆符 ! は全角に戻してあげないと MeCab は正しく形態素解析できません。

```console
$ echo "（テスト）" | mecab
（		記号,括弧開,*,*,*,*,（,（,（
テスト	名詞,サ変接続,*,*,*,*,テスト,テスト,テスト
）		記号,括弧閉,*,*,*,*,）,）,）
```

特定の文字だけは変換させない（変換したものを元に戻す）には str.maketrans で変換テーブルを作って、文字列.translate(変換テーブル) で変換します。
Python で書くと以下のようになります。

```python
import unicodedata

text = 'ＣＬＥＡＮＳingするけど（全角記号！）はそのままにする。'
print("Before:", text)

text = unicodedata.normalize('NFKC', text)
tr = str.maketrans(dict(zip('()!', '（）！')))
text = text.translate(tr)
print("After: ", text)
# => Before: ＣＬＥＡＮＳingするけど（全角記号！）はそのままにする。
# => After:  CLEANSingするけど（全角記号！）はそのままにする。
```

以上です。
