---
layout:        post
title:         "[Python] 単語単位の言語モデルの作り方"
date:          2020-01-16
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

単語単位の言語モデル（$n$-gram言語モデル）とは、単語の生起確率が直前の $n-1$ 個の単語に依存するモデルです。
$n$-gram言語モデルは、Pythonライブラリの nltk を使うことで、簡単に作ることができます。
今回は MLE (Maximum Likelihood Estimator) というモデルを使って言語モデルを作成します。

まず、必要なライブラリをインストールします。

```bash
$ pip install mecab-python3
$ pip install nltk
```

次に、様々な文章（コーパス）をファイル input.txt に保存します。
文章は出来るだけ多く集めてください。
$n$-gram言語モデルを nltk で作るプログラムを以下に示します。

```python
import re
import unicodedata

import MeCab
from nltk.lm        import Vocabulary
from nltk.lm.models import MLE
from nltk.util      import ngrams

myinput = ""
with open("input.txt") as f:
    myinput = f.read()

# テキストクレンジング
myinput = re.sub(r'，．', '、。', myinput) # 全角カンマとピリオドは句読点に変換する
myinput = re.sub(r'（.+?）', '', myinput) #（）内の文は削除する
myinput = unicodedata.normalize('NFKC', myinput)
# 文を「。」で区切る
input_sentences = re.compile(r'(?<=。)').split(myinput)

tagger = MeCab.Tagger('-Owakati')
def wakati(text): # わかち書き
    return tagger.parse(text).split()

def create_language_model(sentences, N): # N-gram言語モデルの作成
    sents = []
    for sent in sentences:
        sent = wakati(sent)
        sents.append(['__BOS__'] + [word for word in sent] + ['__EOS__'])

    vocab = Vocabulary([word for sent in sents for word in sent])
    text_ngrams = [ngrams(sent, N) for sent in sents]
    lm = MLE(order=N, vocabulary=vocab)
    lm.fit(text_ngrams)
    return lm

lm = create_language_model(input_sentences, N=4)
context = ('自然', '言語', '処理') # 文脈の作成
print(context, '->')

prob_list = []
for word in lm.context_counts(lm.vocab.lookup(context)): # 文脈に続く単語一覧の取得
    prob_list.append((word, lm.score(word, context))) # 単語のその出現する確率を格納

prob_list.sort(key=lambda x: x[1], reverse=True) # 出現確率順にソート
for word, prob in prob_list:
    print('\t{:s}: {:f}'.format(word, prob))
```

今回 input.txt には、自然言語処理に関する様々な論文の抄録を保存しました。
$n-1$ 個の単語が「自然」「言語」「処理」のときに、次に来る単語の確率を表示させた実行結果は次のようになります。

```output
('自然', '言語', '処理') ->
	の: 0.200000
	技術: 0.120000
	における: 0.080000
	タスク: 0.040000
	を: 0.040000
	だけ: 0.040000
	し: 0.040000
	ツール: 0.040000
	と: 0.040000
	分野: 0.040000
	など: 0.040000
	が: 0.040000
	、: 0.040000
	応用: 0.040000
	に: 0.040000
	で: 0.040000
	する: 0.040000
	によって: 0.040000
```

結果から、今回入力したコーパスにおいて
「自然言語処理」の後に「の」と続く確率が 20%、「技術」と続く確率が 12%、「タスク」や「ツール」と続く確率が 4% などとなっていることが確認できます。
