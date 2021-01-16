---
layout:        post
title:         "マイナンバーカードとAPDUで通信する"
date:          2021-01-16
category:      Protocol
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

マイナンバーカードの中には公開鍵や秘密鍵があり、公開鍵を取り出したり、与えた文字列(バイト列)の署名をしたりすることができます。
実際には公開鍵の取得や署名などはAPDUコマンドによって行います。
APDUとは、ICカード (スマートカード) とICカードリーダーの間の通信をするための規格で、ISO/IEC 7816-4で定義されています。
この記事では、ICカードの中でも、公開されている仕様がほとんどないマイナンバーカードについて調査した結果について説明しています。そのため誤った情報があるかもしれませんがご了承ください。

### マイナンバーカードでできる処理

まず、マイナンバーカードでは以下の処理が実行可能です。
認証用証明書の取得以外は、暗証番号(PIN)の入力が必要です。
マイナンバーカード取得時に設定した暗証番号を使うとアクセスできるようになります。

| 処理 | AP | 認証 | 内容
|-----+----+-----+-----
| 認証用証明書の取得 | JPKI-AP |  | DER形式のバイナリデータ
| 認証用秘密鍵による署名(暗号化) | JPKI-AP | あり | 送信データに対する署名データ
| 署名用証明書の取得 | JPKI-AP | あり | DER形式のバイナリデータ
| 署名用秘密鍵による署名(暗号化) | JPKI-AP | あり | 送信データに対する署名データ
| マイナンバーの取得 | 券面入力補助AP | あり | 文字列
| 基本4情報の取得 | 券面入力補助AP | あり | UTF-8文字列

署名アルゴリズムにはsha256RSAが使われており、公開鍵と秘密鍵がペアになっていて、公開鍵は証明書の中に含まれているという形になっています。
署名はICカード側へ送ったデータを秘密鍵で暗号化してカードリーダー側に返しているだけです。


### APDUコマンド

APDUはコマンドとそのレスポンスのデータ有無の関係で4種類に分類されます。

- パターン1 : コマンドデータなし、レスポンスデータなし
- パターン2 : コマンドデータなし、レスポンスデータ**あり** (例：READ BINARY)
- パターン3 : コマンドデータ**あり**、レスポンスデータなし (例：SELECT FILE)
- パターン4 : コマンドデータ**あり**、レスポンスデータ**あり** (例：COMPUTE DIGITAL SIGNATURE)

それぞれのパターンで送信するAPDUコマンドの構造は以下のように変わります。

- パターン1 : `[CLA|INS|P1|P2]`
- パターン2 : `[CLA|INS|P1|P2| Leフィールド ]`
- パターン3 : `[CLA|INS|P1|P2| Lcフィールド | データフィールド ]`
- パターン4 : `[CLA|INS|P1|P2| Lcフィールド | データフィールド | Leフィールド ]`

APDUコマンドの内容は以下の表の通りです。

| 表記 | 長さ(バイト) | 内容
|---+---+---+---
| CLA<br>INS<br>P1<br>P2 | 1<br>1<br>1<br>1 | 命令クラス<br>命令コード<br>引数1<br>引数2 |
| Lcフィールド | 1 or 3 | データフィールドの長さ(バイト数)
| データフィールド | Lc (可変) | 送信するバイト列
| Leフィールド | 1 or 3 | 期待するレスポンスデータの長さ(バイト数)

なお、LcとLeフィールドの長さは1または3バイトですが、パターン4のときは1バイト。

今回のマイナンバーカードと通信するために使うコマンド（マイナンバーカードで使用できるコマンド）は次の4つです。
APDUコマンド一覧や全体像などは別のサイト[^1] [^2] [^3]を参照してください。

[^1]: JISCAP仕様を基にしたコマンド一覧 : [ファイル構造 -- EternalWindows](http://eternalwindows.jp/security/scard/scard08.html)
[^2]: 密着型ICカードの実装規約 : [ISO 10536 - 4章](https://www.nmda.or.jp/nmda/ic-card/iso10536/sec4.html)
[^3]: [セキュリティ / スマートカード - EternalWindows](http://eternalwindows.jp/security/scard/scard00.html)

| コマンド名 | CLS | INS | 説明 | パターン
|---+---+---
| SELECT FILE               | 00 | A4 | ファイル選択 | 3
| READ BINARY               | 00 | B0 | バイナリデータ読出し | 2
| VERIFY                    | 00 | 20 | データ照合 | 3
| COMPUTE DIGITAL SIGNATURE | 00 | 2A | 署名の作成 | 4

#### SELECT FILE

SELECT FILE は AP を選択したり、証明書やロック解除用のPINにアクセスするために使います。
マイナンバーカードで使える SELECT FILE コマンドのパラメータは以下の通りです。

- 命令クラス: 00
- 命令コード: A4
- 引数1: 選択方法1 (04: DF名で選択、02: 現在のDF直下のEF識別子で選択) [^apdu-cmd-args]
- 引数2: 選択方法2 (00: 最初のレコード) [^apdu-cmd-args]
- データ: ファイル識別子 or DF名

[^apdu-cmd-args]: 各APDUコマンドの引数の説明あり : [ISO7816 part 4 section 6 with Basic Interindustry Commands (APDU level)](https://cardwerk.com/smart-card-standard-iso7816-4-section-6-basic-interindustry-commands/)

ICカードのファイル構造はルートディレクトリを表す MD (Master File)、ディレクトリを表す DF (Dedicated File)、ファイルを表す EF (Elementary File) の3種類のファイルから構成されます。
全てファイルですが、役割としては MD, DF はディレクトリと同じです。

#### READ BINARY

READ BINARY は選択したファイルのバイナリデータを読み取るためのコマンドです。
READ BINARY コマンドのパラメータは以下の通りです。

- 命令クラス: 00
- 命令コード: B0
- 引数1,2: オフセット値（バイト数）。先頭から読み取る場合は 00 00 を指定する
- Leフィールド: 読み取るバイト数

Leフィールドの長さが、1バイトのときは 0x00～0xFF が読み取るバイト長の値が格納されます (0x00を指定すると256バイトを指定したことになります)。
3バイトのときは1バイト目が0x00で2～3バイト目に読み取るバイト長の値が格納されます。

#### VERIFY

VERIFY は入力したパスワードと、ICカード内にあるデータ（ファイル）と比較して、その結果によってセキュリティステータスを更新します。
セキュリティステータスを更新していないとアクセスできないデータがあるときには、まず VERIFY コマンドを使います。
VERIFY コマンドのパラメータは以下の通りです。

- 命令クラス: 00
- 命令コード: 20
- 引数1: 00 (固定値)
- 引数2: 80 (最上位ビットが1: 特定のDF/EFのパスワード、0: カードのパスワード) [^apdu-cmd-args]
- Lcフィールド: パスワードの長さ
- データ: パスワード

#### COMPUTE DIGITAL SIGNATURE

署名はICカード側へ送ったデータを秘密鍵で暗号化し、カードリーダー側に返しています。
COMPUTE DIGITAL SIGNATURE コマンドのパラメータは以下の通りですが、引数などに関してはマイナンバーカードだけの特別仕様になっていると思われます。

- 命令クラス: 80 (一般的には 00) [^apdu-compute-digital-signature]
- 命令コード: 2A
- 引数1,2: 00 80 (一般的には 9E 9A 固定) [^apdu-compute-digital-signature]
- Lcフィールド: 署名対象データの長さ
- データ: 署名対象データ
- Leフィールド: 署名結果データの長さ

[^apdu-compute-digital-signature]: マイナンバーカードで使えるものとは異なるが、COMPUTE DIGITAL SIGNATUREのコマンドについて説明あり : [JISX6319-3:2011 ＩＣカード実装仕様－第３部：共通コマンド](https://kikakurui.com/x6/X6319-3-2011-01.html)


## マイナンバーカードとお話する

ここからは、APDUコマンドの組み立てと、レスポンスデータとの関係などを、処理手順に沿って説明していきます。

### 証明書の取得

マイナンバーカードでできることの一つにカード内の証明書の取得があります。

「認証用証明書」を取得する手順は次の通りです。

1. 公的個人認証APを選択する (DF)
    - DF名：`D3 92 F0 00 26 01 00 00 00 01`
2. 認証用証明書を選択する (EF)
    - ファイル識別子：`00 0A`
3. DER証明書のデータを読み取る

以下は、送受信するデータの内容です。`> 00 00` が送信、`< 00 00` が受信を表しています。

```code
# SELECT FILE: 公的個人認証AP
> 00 A4 04 0C 0A D3 92 F0 00 26 01 00 00 00 01
< 90 00

# SELECT FILE: 認証用証明書
> 00 A4 02 0C 02 00 0A
< 90 00

# READ BINARY: 最初の4バイトを読み取り、証明書のバイト長を得る
> 00 B0 00 00 04
< 30 82 06 1F 90 00

# READ BINARY: 証明書全体のデータを読み取る (最初の4バイトを除いた残り 0x061F バイト)
> 00 B0 00 04 00 06 1F
< 30 82 ...証明書のデータ... 90 00
```

レスポンスデータについて

- `90 00` は正常終了
- 証明書はDER形式で保存されており、TLV（Tag-Length-Value）方式になっています。
  証明書の先頭 `30 82 06 1F` を見ると、以下の情報が確認できます。
  - \[A] 1バイト目は 30 (Tag: BMP String)
  - \[B] 2バイト目は 82 ですが、最上位ビットが1なので、最上位ビットを除いた値（例では2）がデータ長を表すフィールドの長さ
  - \[C] \[B]より、3～4バイト目がデータ長（例では 0x061F = 1567）
  - \[D] \[C]より、5～1571バイト目がデータ


一方で「署名用証明書」を取得する手順は次の通りです。

1. 公的個人認証APを選択する (DF)
    - DF名：`D3 92 F0 00 26 01 00 00 00 01`
2. 署名用PINを選択する (EF)
    - ファイル識別子: `00 1B`
3. 署名用パスワードを入力してセキュリティステータスを更新する
4. 署名用証明書を選択する (EF)
    - ファイル識別子：`00 01`
5. DER証明書のデータを読み取る

署名用証明書には氏名と住所などの個人情報が記載されているため、PINの入力によるロック解除が必要になります。

```code
# SELECT FILE: 公的個人認証AP
> 00 A4 04 0C 0A D3 92 F0 00 26 01 00 00 00 01
< 90 00

# SELECT FILE: 署名用PIN
> 00 A4 02 0C 02 00 1B
< 90 00

# VERIFY: 署名用PIN (パスワード=123456)
> 00 20 00 80 06 31 32 33 34 35 36
< 90 00

# SELECT FILE: 署名用証明書
> 00 A4 02 0C 02 00 01
< 90 00

# READ BINARY: 最初の4バイトを読み取り、証明書のバイト長を得る
> 00 B0 00 00 04
< 30 82 06 CA 90 00

# READ BINARY: 証明書全体のデータを読み取る (最初の4バイトを除いた残り 0x06CA バイト)
> 00 B0 00 04 00 06 CA
< 30 82 ...証明書のデータ... 90 00
```

### 認証用秘密鍵による署名

マイナンバーカードでできることでもっとも重要なことにカード内の秘密鍵での署名があります。
証明書と同様に秘密鍵も認証用と署名用があります。

「認証用秘密鍵」で署名する手順は次の通りです。

1. 公的個人認証APを選択する (DF)
    - DF名：`D3 92 F0 00 26 01 00 00 00 01`
2. 認証用PINを選択する (EF)
    - ファイル識別子: `00 18`
3. 認証用パスワードを入力してセキュリティステータスを更新する
4. 認証用秘密鍵を選択する (EF)
    - ファイル識別子: `00 17`
5. 対象データを送って署名する

```code
# SELECT FILE: 公的個人認証AP
> 00 A4 04 0C 0A D3 92 F0 00 26 01 00 00 00 01
< 90 00

# SELECT FILE: 認証用PIN
> 00 A4 02 0C 02 00 18
< 90 00

# VERIFY: 認証用PIN (パスワード=1234)
> 00 20 00 80 04 31 32 33 34
< 90 00

# SELECT FILE: 認証用秘密鍵
> 00 A4 02 0C 02 00 17
< 90 00

# COMPUTE DIGITAL SIGNATURE
> 80 2A 00 80 33 ...対象データ... 00
< ...署名結果... 90 00
```

同様に「署名用秘密鍵」で署名する手順は次の通りです。

1. 公的個人認証APを選択する (DF)
    - DF名：`D3 92 F0 00 26 01 00 00 00 01`
2. 認証用PINを選択する (EF)
    - ファイル識別子: `00 1B`
3. 認証用パスワードを入力してセキュリティステータスを更新する
4. 認証用秘密鍵を選択する (EF)
    - ファイル識別子: `00 1A`
5. 対象データを送って署名する

```code
# SELECT FILE: 公的個人認証AP
> 00 A4 04 0C 0A D3 92 F0 00 26 01 00 00 00 01
< 90 00

# SELECT FILE: 署名用PIN
> 00 A4 02 0C 02 00 1B
< 90 00

# VERIFY: 認証用PIN (パスワード=123456)
> 00 20 00 80 06 31 32 33 34 35 36
< 90 00

# SELECT FILE: 署名用秘密鍵
> 00 A4 02 0C 02 00 1A
< 90 00

# COMPUTE DIGITAL SIGNATURE
> 80 2A 00 80 33 ...対象データ... 00
< ...署名結果... 90 00
```

#### DigestInfo の作成方法

認証用・署名用の両方で、送信する対象データは ASN.1 形式で DigestInfo という名前の構造を使用します。
RFC 2315 を読むと DigestInfo は次の構造になっています[^rfc2315]。

```
DigestInfo ::= SEQUENCE {
  digestAlgorithm DigestAlgorithmIdentifier,
  digest Digest }

Digest ::= OCTET STRING

DigestAlgorithmIdentifier ::= AlgorithmIdentifier
```

[^rfc2315]: [RFC 2315 - PKCS #7: Cryptographic Message Syntax Version 1.5](https://tools.ietf.org/html/rfc2315)

また、RFC 5280 を読むと AlgorithmIdentifier の構造について書かれています[^rfc5280]。

```
AlgorithmIdentifier  ::=  SEQUENCE  {
     algorithm               OBJECT IDENTIFIER,
     parameters              ANY DEFINED BY algorithm OPTIONAL  }
```

[^rfc5280]: [RFC 5280 - Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile](https://tools.ietf.org/html/rfc5280)

これらをまとめると、DigestInfo の構造は次のようになっています。

```code
DigestInfo ::= SEQUENCE {
  SEQUENCE {
    algorithm   OBJECT IDENTIFIER,
    parameters  ANY DEFINED BY algorithm OPTIONAL
  }
  digest  OCTET STRING
}
```

次に、ハッシュ値を求めるときはSHA256を使うようにするので、SHA256 アルゴリズムの OID = 2.16.840.1.101.3.4.2.1 をバイト列に変換した `60 86 48 01 65 03 04 02 01` を使用します（[OIDとバイト列の変換方法](./oids) 参照）。

RFC 5754 を読むと[^rfc5754]、SHA256 のパラメータはNULL必須で、DERエンコーディングのサンプルを見ることができるので、これも参考にします。
最終的に、DERエンコードされたDigestInfoは次のような感じになります。

[^rfc5754]: [RFC 5754 - Using SHA2 Algorithms with Cryptographic Message Syntax](https://tools.ietf.org/html/rfc5754#section-2)

```
30 31 30 0D 06 09 60 86 48 01 65 03 04 02 01 05
00 04 20 22 D6 28 B5 3B C6 B3 56 F5 91 3E 98 C5
A3 BC 8A E1 A5 BE 91 C2 91 68 02 35 8E 0E C2 BC
FE 71 E7
```

データの読み方は次のようになります。

- `30 31` ... 49バイトの文字列 (BMP String)
  - `30 0D` ... 13バイトの文字列 (BMP String)
    - `06 09` ... 9バイトのOID
      - `60 86 48 01 65 03 04 02 01` ... SHA256
    - `05 00` ... 0バイトのNULL
  - `04 20` ... 32バイトの文字列 (OCTET STRING)
    - `22 D6 28 ... FE 71 E7` ... 署名対象ファイルのハッシュ値(SHA256)


上のデータを COMPUTE DIGITAL SIGNATURE の署名対象データ部分に入れてあげることで、OpenSSLなどで検証可能な署名が作成されます。

#### OpenSSLによる検証

1. 署名するファイルを target.txt とします。
2. 署名するファイルのハッシュ値を求めます。
3. DigestInfoを作成します。
4. COMPUTE DIGITAL SIGNATUREコマンドを実行して、レスポンスデータをファイル target.txt.sig に保存します。
5. READ BINARYなどで署名用証明書を読み取ってファイル sig-cert.pem に保存します。
6. 署名用証明書 sig-cert.pem から公開鍵を取り出してファイル sig-pub.pem に保存します。
7. OpenSSLのコマンド `openssl dgst -verify sig-pub.pem -signature target.txt.sig target.txt` を実行します。
8. 「Verified OK」と表示されれば検証成功です。


### マイナンバー (個人番号) の取得

マイナンバーカードには公的個人認証APとは別に、券面入力補助APがあり、これを使うことでマイナンバー (個人番号) の取得ができます。
マイナンバー取得手順は次のようになります。

1. 券面入力補助APを選択する (DF)
    - DF名：`D3 92 10 00 31 00 01 01 04 08`
2. 券面入力補助用PINを選択する (EF)
    - ファイル識別子: `00 11`
3. 券面入力補助用パスワードを入力してセキュリティステータスを更新する
4. マイナンバーファイルを選択する (EF)
    - ファイル識別子: `00 01`
5. 対象データを送って署名する

```code
# SELECT FILE: 券面入力補助AP (DF)
> 00 A4 04 0C 0A D3 92 10 00 31 00 01 01 04 08
< 90 00

# SELECT FILE: 券面入力補助用PIN (EF)
> 00 A4 02 0C 02 00 11
< 90 00

# VERIFY: 券面入力補助用PIN (パスワード=1234)
> 00 20 00 80 04 31 32 33 34
< 90 00

# SELECT FILE: マイナンバー (EF)
> 00 A4 02 0C 02 00 01
< 90 00

# READ BINARY: マイナンバー読み取り（4～15バイト目が個人番号）
> 00 B0 00 00 00
< FF 10 0C 30 31 32 33 34 35 36 37 38 39 30 31 FF FF 90 0
```


### 基本4情報の取得

基本4情報とは「氏名」「住所」「生年月日」「性別」の4つの情報のことです。
これも券面入力補助APを使うことで取得できます。
基本4情報の取得手順は次のようになります。

1. 券面入力補助APを選択する (DF)
    - DF名：`D3 92 10 00 31 00 01 01 04 08`
2. 券面入力補助用PINを選択する (EF)
    - ファイル識別子: `00 11`
3. 券面入力補助用パスワードを入力してセキュリティステータスを更新する
4. 基本4情報ファイルを選択する (EF)
    - ファイル識別子: `00 02`
5. 対象データを送って署名する

```code
# SELECT FILE: 券面入力補助AP (DF)
> 00 A4 04 0C 0A D3 92 10 00 31 00 01 01 04 08
< 90 00

# SELECT FILE: 券面入力補助用PIN (EF)
> 00 A4 02 0C 02 00 11
< 90 00

# VERIFY: 券面入力補助用PIN (パスワード=1234)
> 00 20 00 80 04 31 32 33 34
< 90 00

# SELECT FILE: 基本4情報 (EF)
> 00 A4 02 0C 02 00 02
< 90 00

# READ BINARY: 基本4情報の読み取り（3バイト目のデータ長のみ）
> 00 B0 00 02 01
< 68 90 0

# READ BINARY: 基本4情報の読み取り（3 + 0x68）
> 00 B0 00 00 71
< FF 20 62 DF 21 08 ...ヘッダー... DF 22 0F ...名前...
  DF 23 39 ...住所... DF 24 08 ...生年月日... DF 25 01 性別 90 0
```


以上です。

### 参考文献

- [pyscard user’s guide — pyscard 1.9.5 documentation](https://pyscard.sourceforge.io/user-guide.html#quick-start)
- [LudovicRousseau/pyscard: pyscard smartcard library for python](https://github.com/LudovicRousseau/pyscard)
- [マイナンバーカード検証#1 - まえおき - Qiita](https://qiita.com/gebo/items/6a334b5453817a587683)
- [マイナンバーカード検証#2 - 利用者証明用電子証明書 - Qiita](https://qiita.com/gebo/items/fa35c1f725f4c443f3f3)
- [/docs/man1.0.2/man1/openssl-dgst.html](https://www.openssl.org/docs/man1.0.2/man1/openssl-dgst.html)
- [JPKIReader/JPKIReader.cs at 03e60ba26d7220f824bdb5a8e9cbdfaa735ae774 · gebogebogebo/JPKIReader](https://github.com/gebogebogebo/JPKIReader/blob/03e60ba26d7220f824bdb5a8e9cbdfaa735ae774/Source/JPKIReader/JPKIReader/JPKIReader.cs)


---
