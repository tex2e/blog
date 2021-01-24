---
layout:        post
title:         "[Windows] PythonでICカードのIDmを確認する"
date:          2021-01-25
category:      Python
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

WindowsのPythonでpyscard経由でAPDUコマンドからICカードのIDmを取得する方法について説明します。

### 環境

- OS: Windows10
- カードリーダー: PaSoRi RC-S380
- ICカード
- 言語: Python3
- ライブラリ: pyscard

カードリーダーと通信するためにPaSoRi RC-S380のドライバをインストールする必要があります。
ドライバはSonyのページから「NFCポートソフトウェア」をダウンロードして、NFCPortWithDriver.exeを実行します。

[Sony Japan \| FeliCa \| 個人のお客様 \| ダウンロード \| NFCポートソフトウェア](https://www.sony.co.jp/Products/felica/consumer/download/felicaportsoftware.html)


ICカードは、Suica, Edy, nanako, マイナンバーカードなど非接触型のカードであれば何を使ってもよいです（ただし、マイナンバーカードは読み取るたびにIDmが変化します）。

WindowsにはPythonをインストールして、コマンドから py.exe が使えるようにします（WSLではUSBに接続できないので注意）。
APDUで通信するためのライブラリに pyscard を使うので、`py -m pip install pyscard` でインストールしておきます。

### プログラム

pyscardのサンプルコードを読みながら書きます。

[pyscard user’s guide — pyscard 1.9.5 documentation](https://pyscard.sourceforge.io/user-guide.html#quick-start)

APDUコマンドは GET DATA コマンドを使います。
送信するバイナリは `FF CA 00 00 00` です。

```python
from smartcard.util import toHexString
from smartcard.System import readers as get_readers
readers = get_readers()
print(readers)

conn = readers[0].createConnection()
conn.connect()

send_data = [0xFF, 0xCA, 0x00, 0x00, 0x00]
recv_data, sw1, sw2 = conn.transmit(send_data)
print(toHexString(send_data))
```

GET DATAコマンドの構造は以下の通りです。

- CLA: 0xFF ... 命令クラス FF固定
- INS: 0xCA ... 命令コード GET DATAコマンド
- P1: 0x00 ... 引数1 00固定
- P2: 0x00 ... 引数2 00固定
- Le: 0x00 ... Leフィールド 最大長

[ISO7816 part 4 section 6 with Basic Interindustry Commands (APDU level)](https://cardwerk.com/smart-card-standard-iso7816-4-section-6-basic-interindustry-commands/)

Pythonプログラムを実行して、カードのIDmが16進数文字列で出力されれば成功です。

以上です。


### 関連記事

- [マイナンバーカードとAPDUで通信して署名データ作成](../protocol/jpki-mynumbercard-with-apdu)
