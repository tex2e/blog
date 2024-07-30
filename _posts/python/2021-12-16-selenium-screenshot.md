---
layout:        post
title:         "[Python] Seleniumでスクリーンショットを撮りPDFにまとめる"
date:          2021-12-16
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

全てのページのスクリーンショットを撮ってPDFにまとめるために、SeleniumとImageMagicを使って情報収集・保存した時の覚書です。

この記事では Python + Selenium で実施します。MacOSの場合、追加でインストールが必要なものは以下の通りです。
```bash
brew install geckodriver
pip install -U selenium
```

### Seleniumでスクリーンショット撮影

Python + Selenium で各ページのスクリーンショットを撮影するためのプログラムは以下の通りです。
「対象サイト」「メールアドレス」「パスワード」の部分は適切な文字列に変えてください。
実行前に「開始ページ」「終了条件」が正しいか確認してから実行してください。

```python
import os
import time
import random
from selenium import webdriver
from selenium.webdriver.common.by import By

driver = webdriver.Firefox()
driver.set_window_size(1230, 1765)

# 保存先パスの生成
def get_filepath(num):
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "img", "screen%03d.png" % num)

# 開始ページ #################################
page = 0
############################################
driver.get('https://example.com/page=%d' % page)  # 対象サイト
time.sleep(5)

# 対象サイトにログイン (指定IDに対してキーボード入力)
driver.find_element(By.ID, "email-field").send_keys("test@example.com")  # メールアドレス
driver.find_element(By.ID, "password-field").send_keys("P@ssw0rd")  # パスワード

# 対象画面まで遷移するためのクリック処理 (指定CSSに対してクリック)
driver.find_element(By.CSS_SELECTOR, ".article .target_button").click()
time.sleep(1)

while True:
    # スクリーンショット撮影
    driver.save_screenshot(get_filepath(page))

    page += 1
    # 終了条件 ##################################
    if page >= 100: break
    ############################################

    time.sleep(random.randrange(30, 60*2)) # 1ページ毎に30秒〜2分待機
    if page % 10 == 0:
        time.sleep(random.randrange(60*5, 60*10)) # 10ページ毎に追加で5分〜10分待機

    # 次のページへ遷移
    driver.find_element(By.CSS_SELECTOR, ".next_button").click()

driver.quit()
```

サイトによっては、ロボット的なアクセスを続けると reCAPTCHA を答えさせられるので、アクセス間の待機時間を適切に設定してください。

### スクリーンショットの範囲切り取り

次に、スクリーンショットの範囲切り取り（トリミング）を ImageMagick の convert コマンドを使って、bashで実行します。
使用するオプションは -crop で「幅x高さ+X座標+Y座標」を指定します。
```bash
#!/bin/bash
for i in {000..123}; do
    image_from=$(printf "./img/screen%03d.png" $i)
    image_to=$(printf "./img-crop/screen%03dc.png" $i)
    if [[ -e "$image_from" ]] && [[ ! -e "$image_to" ]]; then
        echo "[*] $image_from => $image_to"
        convert "$image_from" -crop 2050x2900+230+230 "$image_to"
    fi
done
```

### スクリーンショットのサイズ変更

画像のサイズが大きすぎる場合は、再び convert コマンドを使って、サイズの幅と高さを調整します。
使用するオプションは -resize で「幅x高さ」を指定します。
```bash
#!/bin/bash
for i in {000..123}; do
    image_from=$(printf "./img-crop/screen%03dc.png" $i)
    image_to=$(printf "./img-resize/screen%03dcr.png" $i)
    if [[ -e "$image_from" ]] && [[ ! -e "$image_to" ]]; then
        echo "[*] $image_from => $image_to"
        convert "$image_from" -resize 1033x1462 "$image_to"
    fi
done
```

### 画像からPDFへの変換

画像からPDFへの変換する際も convert コマンドを使います。
使い方は「convert 入力画像ファイル名 出力PDFファイル名」です。
```bash
#!/bin/bash
FROM_DIR=./img-resize
convert $FROM_DIR/screen*.png Textbook.pdf
```

最後に PDF を開いて、文字が読める程度になっていれば完了です。

以上です。
