---
layout:        post
title:         "[Python] defaultdictの使い方"
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

Pythonのdefaultdictは、キーが存在しない時に自動的に初期値が設定される辞書型オブジェクトです。
初期値として0が設定される defaultdict(int) や空のリストが設定される defaultdict(list) などがよく使われます。

### defaultdict(int)

以下は、初期値として0が設定される defaultdict(int) の使い方の例です。

```python
from collections import defaultdict
score = defaultdict(int)

print(score['太郎'])  # => 0

score['花子'] = 100
print(score['花子'])  # => 100
```

### defaultdict(list)

以下は、初期値として空のリストが設定される defaultdict(list) の使い方の例です。

```python
from collections import defaultdict
group_menbers = defaultdict(list)

print(group_menbers['Aグループ'])  # => []

group_menbers['Bグループ'].append('太郎')
group_menbers['Bグループ'].append('花子')
print(group_menbers['Bグループ'])  # => ['太郎', '花子']
```

通常の辞書型 (dict) よりも、キーの存在確認が不要になる分、使いやすいと思います。

以上です。
