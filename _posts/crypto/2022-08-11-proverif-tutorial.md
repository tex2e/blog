---
layout:        post
title:         "ProVerif入門"
date:          2022-08-10
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap: false
# feed:    false
---

ProVerifの使い方について[ProVerifのユーザマニュアル](https://bblanche.gitlabpages.inria.fr/proverif/manual.pdf)に沿って説明します。

### インストール

インストール方法については別記事で説明しています：<br>
[\[Monterey\] ProVerifをMacOSにインストールする \| 晴耕雨読](./install-proverif-on-macos-2)

### 実行方法

ファイルの拡張子は .pv です。
実行時は `proverif ファイル名.pv` で実行します。

### ProVerifの基本的な検証の書き方

ファイル（hello.pv）：
```pv
(* Hello World Script *)

free c:channel.

free Foo:bitstring [private].
free Bar:bitstring [private].

query attacker(Foo).
query attacker(Bar).

process
  out(c, Bar);
  0
```

- 書き方：
    - コメントは `(* comments *)` の形式です。
    - 文の末尾には `.` を書きます。
    - `free c:channel.` は通信チャネルcです。
    - `free 変数名:bitstring.` はビット文字列です。この変数に攻撃者はアクセスできます。
    - `free 変数名:bitstring [private].` はビット文字列です。この変数に攻撃者はアクセスできません。
    - `process` はmain関数となる部分で、処理の流れを書きます。それぞれの処理は `;` で区切ります。
        - `out(c, Bar)` は通信チャネルcに変数Barの値を送信します。通信チャネルが `[private]` でない場合、out した変数は攻撃者からアクセスできるようになります。
        - `0` はプロセスの終了を表します。省略可能です。
- 検証：
    - `query attacker(変数名).` は攻撃者が*変数名*にアクセスできるか検証します。

実行方法：
```bash
$ proverif test.pv
```

実行結果：
```
Query not attacker(Foo[]) is true.
Query not attacker(Bar[]) is false.
```

- 攻撃者は変数Fooにアクセスできません。
- 攻撃者は変数Barにアクセスできます（not〜 is falseで2重否定されていることに注意）。

### eventを使った実行有無の検証

```pv
free c:channel.

free Foo:bitstring [private].
free Bar:bitstring [private].

event evFoo.
event evBar.
query event(evFoo) ==> event(evBar).

process
  out(c, Bar);
  in(c, x:bitstring);
  if x = Foo then
    event evFoo;
    event evBar;
    0
  else
    event evBar;
    0
```

- 書き方：
    - `event イベント名.` はイベントの宣言をします。
    - process:
        - `in(c, x:bitstring)` は通信チャネルcからメッセージを受信し、型をビット文字列として変数xに格納します。
        - `if 〜 then 〜 else 〜` は条件分岐です。条件文の `=` は比較演算子です。
        - `event イベント名` はイベントを実行します。
- 検証：
    - `query A ==> B` はAがtrueのとき、Bがtrueかどうかを検証します。
    - `query event(E1) ==> event(E2)` はイベントE1が実行されたとき、イベントE2が実行されるかどうか検証します。
      例では、入力が改竄されずにxがBarの場合はelse句が実行され、改竄されてxがFooの場合はthen句が実行されます。
      そのため、イベントevFooが実行されるときは必ずイベントevBarが実行されるため、結果はtrueになります。

実行結果：
```
Query event(evBar) ==> event(evFoo) is true.
```
- イベントevBarが実行されたとき、イベントevFooが実行されます。


### 暗号プリミティブの定義

共通鍵暗号は以下のように実装します。
```pv
(* Symmetric Encryption *)
type key.
fun senc(bitstring,key):bitstring. (* Enc *)
reduc forall m:bitstring,k:key;
      sdec(senc(m,k),k) = m.       (* Dec *)
```
- `key` は共通鍵の型
- `senc(bitstring,key)` は共通鍵による暗号化関数
- `sdec(bitstring,key)` は共通鍵による復号関数

公開鍵暗号は以下のように実装します。
```pv
(* Asymmetric Encryption *)
type skey.                           (* private key *)
type pkey.                           (* public key *)
fun pk(skey):pkey.                   (* Get pkey from skey. *)
fun aenc(bitstring, pkey):bitstring. (* Enc *)
reduc forall m:bitstring,k:skey;
      adec(aenc(m,pk(k)),k) = m.     (* Dec *)
```
- `skey` は秘密鍵の型
- `pkey` は公開鍵の型
- `pk(skey)` は秘密鍵から公開鍵を取得する関数
- `aenc(bitstring,pkey)` は公開鍵による暗号化関数
- `adec(bitstring,skey)` は秘密鍵による復号関数

署名・検証は以下のように実装します。
```pv
(* Digital Signatures *)
type sskey.                            (* private signing key *)
type spkey.                            (* public signing key *)
fun spk(sskey): spkey.                 (* Get spkey from sskey. *)
fun sign(bitstring,sskey):bitstring.   (* Sign *)
reduc forall m:bitstring, k:sskey;
      getmess(sign(m,k)) = m.          (* Get message from signed message. *)
reduc forall m:bitstring,k:sskey;
      checksign(sign(m,k),spk(k)) = m. (* Verify *)
```
- `sskey` は署名用秘密鍵
- `spkey` は署名用公開鍵
- `spk(sskey)` は署名用秘密鍵から署名用公開鍵を取得する関数
- `sign(bitstring,sskey)` はメッセージを署名する関数
- `getmess(bitstring)` は署名からメッセージを取得する関数
- `checksign(bitstring,spkey)` は署名を検証する関数


### サンプルプロトコル

以下のプロトコルでは、クライアントAとサーバBは、以下の手順で鍵kを共有して暗号化通信を行います。
```
A -> B: pk(skA)
B -> A: aenc(sign((pk(skB),k),skB),pk(skA))
A -> B: senc(s,k)
```

しかし、このプロトコルは中間者攻撃に脆弱です。Aが公開鍵を渡す相手がBではなくIの場合、不正な鍵を共有されてしまいます。
```
A -> I: pk(skA)
I -> B: pk(skI)
B -> I: aenc(sign((pk(skB),k),skB),pk(skI))
I -> A: aenc(sign((pk(skB),k),skB),pk(skA))
A -> B: senc(s,k)
```

このサンプルプロトコルをProverifで実装して、メッセージsは攻撃者が取得できるか検証すると、以下のようになります。
```pv
(* Sample Handshake *)

free c:channel.

free s:bitstring [private].
query attacker(s).

(* ...暗号プリミティブの定義は省略... *)

let clientA(pkA:pkey, skA:skey, pkB:spkey) =
    (* 1 *)
    out(c, pkA);
    (* 2 *)
    in(c, x:bitstring);
    let y = adec(x, skA) in
    let (=pkB, k:key) = checksign(y, pkB) in
    (* 3 *)
    out(c, senc(s,k)).

let serverB(pkB:spkey, skB:sskey) =
    (* 1 *)
    in(c, pkX:pkey);
    new k:key;
    (* 2 *)
    out(c, aenc(sign((pkB,k), skB), pkX));
    (* 3 *)
    in (c, x:bitstring);
    let z = sdec(x, k) in
    0.

process
    new skA:skey;
    new skB:sskey;
    let pkA = pk(skA) in out(c,pkA);
    let pkB = spk(skB) in out(c,pkB);
    ( (!clientA(pkA,skA,pkB)) | (!serverB(pkB,skB)) )
```

- `new` は実行毎に異なる値を作成していることを表すキーワードです
- `let 関数名(引数) =` はプロセスを定義します
- `let 変数名 = 式 in` は値を変数にバインドします
- `process`
  - `プロセスA | プロセスB` はプロセスAを実行した後に、プロセスBを実行します
  - `!プロセスA | !プロセスB` はプロセスAを並列で実行した後に、プロセスBを並列で実行します。つまり、プロセスAとBは並列実行されます。

実行結果：
```
Query not attacker(s[]) is false.
```

- 攻撃者は変数sにアクセスできます（not 〜 is falseの2重否定に注意）

攻撃手法をグラフ化する：
```bash
$ proverif -graph . handshake.pv
```

<figure>
<img src="{{ site.baseurl }}/media/post/crypto/proverif-sample-handshake.png" />
<figcaption>ProVerifによる検証結果</figcaption>
</figure>

以上です。


### 参考文献
- [ProVerif: Cryptographic protocol verifier in the formal model](https://bblanche.gitlabpages.inria.fr/proverif/)
