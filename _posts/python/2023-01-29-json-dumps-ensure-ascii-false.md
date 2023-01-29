---
layout:        post
title:         "[Python] json.dumps()で日本語が\\uXXXXになるときの対処法"
date:          2023-01-29
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

json.dumps()で日本語が\\uXXXXになるときの対処法について説明します。

PythonにはJSONを扱うための組み込みライブラリ `json` が存在します。
しかし、デフォルトでは、json.dump（ファイルに出力する関数）やjson.dumps（文字列として出力する関数）を使用すると、Unicode文字列は`\uXXXX`形式でエンコードされてしまいます。

```python
import json
print(json.dumps({'項目名': '値'}))
# => '{"\\u9805\\u76ee\\u540d": "\\u5024"}'
```

対処法として、引数に `ensure_ascii=False` を追加すると、日本語のまま出力されます。

```python
print(json.dumps({'項目名': '値'}, ensure_ascii=False))
# => '{"項目名": "値"}'
```

以上です。
