---
layout:        post
title:         "[Python3] Selenium で Google 翻訳する"
date:          2019-12-17
category:      Python
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

日本語を英語に翻訳する作業を Selenium と Python3 で行うプログラム例を示します。
なお、翻訳には Google 翻訳を利用しています。
必要なライブラリ (selenium, BeautifulSoup) は事前にインストールしておいてください。

```python
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import urllib.parse

class Translator:

    def __init__(self):
        self.options = Options()
        self.options.add_argument('--headless')
        self.browser = webdriver.Chrome(options=self.options)
        self.browser.implicitly_wait(3)

    def translate(self, text, dest='ja'):
        # 翻訳したい文をURLに埋め込んでからアクセスする
        text_for_url = urllib.parse.quote_plus(text, safe='')
        url = "https://translate.google.co.jp/#en/ja/{0}".format(text_for_url)
        self.browser.get(url)

        # 数秒待機する
        wait_time = 2 + len(text) / 100
        time.sleep(wait_time)

        # 翻訳結果を抽出する
        ja = BeautifulSoup(self.browser.page_source, "html.parser") \
             .find(class_="tlid-translation translation")
        return ja.text

    def quit(self):
        self.browser.quit()


translator = Translator()

ja = translator.translate('machine learning')
print(ja) # => 機械学習

ja = translator.translate('natural language processing')
print(ja) # => 自然言語処理
```

プログラムについて補足

- Selenium は Chrome を Headless モードで起動することで、ブラウザ画面を表示せずに動作させます。
- 翻訳したい文をURLに入れてアクセスします。例えば「machine learning」を翻訳したいときは「https://translate.google.co.jp/#en/ja/machine+learning」にアクセスします。
- 数秒待機するのは、短い時間に大量のアクセスをするとブロックされるのを回避するためです。
- 翻訳結果は (CSSセレクタの書き方で) `.tlid-translation.translation` に格納されるので、そこからテキストを抽出することで、翻訳結果を得ることができます。

翻訳する選択肢として [Googletrans](https://github.com/ssut/py-googletrans) を使う方法もありますが、大量にアクセスした時に Googletrans の方がブロックされやすいので、システムとして長時間回す場合は Selenium を使う方が良いと思います。ちなみにブロックされると24時間程度使えなくなるので、節度を持って利用してください。

以上です。
