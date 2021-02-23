---
layout:        post
title:         "SeleniumでGoogle翻訳を自動化する"
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
import urllib.parse
from selenium import webdriver  # pip install selenium
from selenium.webdriver.firefox.options import Options

class Translator:

    def __init__(self):
        WEBDRIVER_EXE_PATH = '/mnt/c/Apps/webdriver/geckodriver.exe'
        options = Options()
        options.add_argument('--headless')
        browser = webdriver.Firefox(executable_path=WEBDRIVER_EXE_PATH, options=options)
        browser.implicitly_wait(3)
        self._browser = browser

    def translate(self, text, dest='ja'):
        browser = self._browser

        # 翻訳したい文をURLに埋め込んでからアクセスする
        text_for_url = urllib.parse.quote_plus(text, safe='')
        url = "https://translate.google.co.jp/#en/ja/{0}".format(text_for_url)
        browser.get(url)

        # 数秒待機する
        wait_time = 2 + len(text) / 100
        time.sleep(wait_time)

        # 翻訳結果を抽出する
        ja = browser.find_element_by_css_selector("span[jsname='W297wb']")
        return ja.text

    def quit(self):
        self._browser.quit()


translator = Translator()

ja = translator.translate('machine learning')
print(ja) # => 機械学習

ja = translator.translate('natural language processing')
print(ja) # => 自然言語処理
```

プログラムについて補足

- Headless モードで起動することで、ブラウザ画面を表示せずに動作させます。
- 翻訳したい文をURLに入れてアクセスします。例えば「machine learning」を翻訳したいときは「https://translate.google.co.jp/#en/ja/machine+learning」にアクセスします。
- 数秒待機するのは、翻訳結果が表示するまでに時間がかかることがあるからです。
- 翻訳結果は (CSSセレクタで) `span[jsname='W297wb']` に格納されるので、そこからテキストを抽出することで、翻訳結果を得ることができます[^1]。

[^1]: 2019年くらいは翻訳結果を `.tlid-translation.translation` で取得できましたが、2020年の後半に確認したら `span[jsname='W297wb']` になっていました。

翻訳する選択肢として [Googletrans](https://github.com/ssut/py-googletrans) を使う方法もありますが、大量にアクセスした時に Googletrans の方がブロックされやすいので、システムとして長時間回す場合は Selenium を使う方が良いと思います。ちなみにブロックされると24時間程度使えなくなるので、節度を持って利用してください。

以上です。

---
