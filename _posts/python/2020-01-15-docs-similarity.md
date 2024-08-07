---
layout:        post
title:         "[Python] 文書のコサイン類似度を求める"
date:          2020-01-15
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex: true
# sitemap: false
# draft:   true
---

Python で scikit-learn を使った TF-IDF に基づく文書の類似度の求め方について説明します。

### 定義

コサイン類似度とは、ベクトル同士の距離の計算に使います。
コサイン類似度が1に近いほど、ベクトル同士の成す角度が小さいため、類似していることを表します。
まず、ベクトルの内積は次の式で書けます。

$$
\vec{x} \cdot{} \vec{y} = \| \vec{x} \| \| \vec{y} \| \cos \theta
$$

なので式変形すると、コサイン類似度は次の式で求められます [^1]。

$$
\cos(\theta) = \frac{\vec{x} \cdot{} \vec{y}}{\| \vec{x} \| \| \vec{y} \|}
= \frac{\sum_i x_i y_i}{\sqrt{\sum_i x_i^2} \times \sqrt{\sum_i y_i^2}}
$$

[^1]: 説明する人によっては、ベクトルの距離を $$\|\vec{x}\|$$ ではなく、L2ノルムで正規化する $$\|\vec{x}\|_2 = \sqrt{\sum_i x_i^2}$$ と書く場合もあります。どちらも同じ計算値になります。

2つの文書のコサイン類似度を求めるには次の手順で計算をします。

1. 全ての文書の単語について TF-IDF を求める。
2. 各文書の TF-IDF の値の配列（つまり、各文書のベクトル）を作る。
3. 2つの文書ベクトルのコサイン類似度を求めて、文書の類似度を求める。

TF-IDF の計算方法は他のページを参照してください。


### プログラム

実際に、文書の類似度をプログラムで計算してみます。
たとえば、3つの文書（コーパス）が次のような内容だとします。

- 文書1 :「ドキュメント集合においてドキュメントの単語に付けられる」
- 文書2 :「情報検索において単語への重み付けに使える」
- 文書3 :「ドキュメントで出現したすべての単語の総数」

これらを分かち書きしたデータを与え、TF-IDF を求めて、その結果から文書の類似度を求めることができます。

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

docs = [
    'ドキュメント 集合 において ドキュメント の 単語 に 付けられる',
    '情報検索 において 単語 へ の 重み付け に 使える',
    'ドキュメント で 出現した すべて の 単語 の 総数',
]
vectorizer = TfidfVectorizer(max_df=0.9) # tf-idfの計算
#                            ^ 文書全体の90%以上で出現する単語は無視する
X = vectorizer.fit_transform(docs)
print('feature_names:', vectorizer.get_feature_names())
print('X:')
print(X.toarray())
sim = cosine_similarity(X) # 類似度行列の作成
for from_id in range(len(docs)):
    print('doc_id:', from_id)
    for to_id in range(len(docs)):
        print('\tsim[{0}][{1}] = {2:f}'.format(
              from_id, to_id, sim[from_id][to_id]))
```

実行結果：

```output
feature_names: ['すべて', 'において', 'ドキュメント', '付けられる', '使える', '出現した', '情報検索', '総数', '重み付け', '集合']
X: （3つの文書ベクトル）
[[0.    0.34  0.68  0.45  0.    0.    0.    0.    0.    0.45]
 [0.    0.40  0.    0.    0.52  0.    0.52  0.    0.52  0.  ]
 [0.52  0.    0.40  0.    0.    0.52  0.    0.52  0.    0.  ]]
doc_id: 0
	sim[0][0] = 1.000000
	sim[0][1] = 0.138242  （文書1と文書2の類似度）
	sim[0][2] = 0.276484  （文書1と文書3の類似度）
doc_id: 1
	sim[1][0] = 0.138242  （文書2と文書1の類似度）
	sim[1][1] = 1.000000
	sim[1][2] = 0.000000  （文書2と文書3の類似度）
doc_id: 2
	sim[2][0] = 0.276484  （文書3と文書1の類似度）
	sim[2][1] = 0.000000  （文書3と文書2の類似度）
	sim[2][2] = 1.000000
```

結果から言えること：

- 文書1と文書2について、2番目の単語「において」が共通して現れるので、類似度は 0.13 となりました。
- 文書1と文書3について、3番目の単語「ドキュメント」が共通して多く現れるので、類似度は 0.27 となりました。
- 文書2と文書3について、共通して現れる単語が存在しないので、類似度は 0 となりました。

以上です。

---
