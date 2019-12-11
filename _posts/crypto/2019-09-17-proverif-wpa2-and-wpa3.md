---
layout:        post
title:         "ProVerifによるWPA3プロトコルの検証"
date:          2019-09-17
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

WPA3によってWi-Fiのセキュリティが強化されました。
WPA3のプロトコルへの攻撃に対する安全性の変更点としては主に2つあります。

1. 鍵共有プロトコルがSAEになり、**オフライン攻撃**に強くなった。
2. SAEにより**前方秘匿性**が実現されたので、パスワードが漏れても過去の暗号通信は解読されない。

これらの安全性について成立するかを調べるために、WPA3プロトコルをモデル化して、ProVerifというセキュリティプロトコルの形式検証ツールを使って安全性を検証していきたいと思います。

## ProVerif

ProVerif[^ProVerif]は Dolev-Yao モデル[^Dolev-Yao]に基づく暗号プロトコルの形式的安全性検証ツールです。
暗号プロトコルを形式モデルで記述し、そのプロトコルの認証、秘匿性、前方秘匿性、中間者攻撃やオフライン攻撃への耐性などの安全性要件を検証することができます。
ProVerifではハッシュ関数や秘密/公開鍵暗号、電子署名/検証などの暗号技術は全て理想化したモデルで表現されるので、個々の暗号技術は安全であるという仮定の下で安全性検証を行います。
ProVerifにはチュートリアルのPDF[^ProVerif-Tutorial]があるので、これを参考にしながら形式モデルを記述していきます。
MacOSでOPAM経由でProVerifをインストールする方法は同サイトの「[ProVerifをMacOSにインストールする]({{ site.baseurl }}/crypto/install-proverif-on-macos)」に書きましたので参考にしてください。

### ProVerifの重要なキーワード

ProVerifの記述を見る前に書き方について簡単におさらいをしておきます。

- `free` : グローバル変数の宣言。デフォルトでは攻撃者に対してもグローバル(アクセス可能)なので、当事者間だけがアクセスできる場合は `[private]` を宣言に加えます。
- `type` : 型の宣言。標準では bitstring という型がありますが、鍵を表す型として key などを作っておくと、メッセージと鍵を区別することができるなどの利点があリマス。
- `fun` : 関数の宣言。形式モデルなので中身はなく、入力と出力の型で関数を表します。
- `reduc` : 書き換えルールによって関数を置き換えるために使います。例えば、暗号化・復号や署名・検証の関係性を表すために用います。
- `equation` : 両辺の式が等しくなることを示すために使います。例えば、Diffie-Hellman鍵共有などでクライアントとサーバの計算結果が等しいことを示すために用います。
- `event` : イベントの宣言。プロセス内ではイベントの発生を表します。
- `query attacker(var)` : **秘匿性の検証**をします。攻撃者がグローバル変数 var の内容を取得できるか検証します。
- `query event(A) ==> event(B)` : **認証の検証**をします。イベントAが発生するときは必ずイベントBが発生するか検証します。
- `query inj-event(A) ==> inj-event(B)` : **認証の検証**をします。イベントAが発生するときは必ずイベントBが発生するか検証しますが、それに加えて傍受したメッセージを再送しても認証されないかを調べる**リプレイ攻撃の検証**も行います。
- `weaksecret var` : **オフライン攻撃の検証**をします。変数 var についてオフライン攻撃か可能かどうかを検証します。
- `process` : mainプロセスの定義。
- `let` : 項の評価と値の束縛をします。変数に値を代入する操作もできますが、パターンマッチもできます。
- `new` : ランダムな値で新しい変数を定義します。つまり、乱数の生成を意味します。
- `out` : チャネルにデータを送信します。ただし受信者が存在しない場合もあります (その場合は、攻撃者もアクセスできるようにしたという意味合いが強いです)。
- `in` : チャネルからデータを受信します。受信にもパターンマッチが発生するので、複数のプロセスが in で受信している場合でも、引数の数や引数の型からどのプロセスが受信すべきデータなのか自動で決定されます。
- `!プロセス` : letで定義したプロセスを複製することを意味し、プロセスが繰り返し実行されることを表します。
- `プロセスA | プロセスB` : プロセスAとプロセスBは並列して動作することを表します。
- `(!プロセスA) | phase N; プロセスB` : 繰り返し実行されるプロセスに対して、N回目のときにプロセスBを実行します。例えば `(!client) | (!server) | phase 1; out(c, password)` と書くことで、0回目が終了した後の1回目のときにパスワード password が漏れることを表すことができ、**前方秘匿性の検証**ができます。

### WPA2

ProVerifでは、まず (1) WPA2の4-Way Handshakeをして共有鍵を導出し、(2) その共有鍵を用いてデータsを暗号化して送信する、ということを形式モデルとして記述します。
WPA2とWPA3の鍵共有と認証の流れは同サイトの「[WPA3 の規格と脆弱性]({{ site.baseurl }}/crypto/wifi-wpa3)」で説明していますので、そちらを参考にしてください。

```proverif
free c: channel. (* 通信に使うチャネル *)

type key.  (* 共通鍵の型 *)
type addr. (* MACアドレスの型 *)

free PMK: key [private]. (* STAとAPの事前共有鍵 *)

fun PRF(bitstring): key.             (* PRF関数 *)
fun HMAC(bitstring, key): bitstring. (* HMAC関数 *)
(* bitstring型をkey型に変換する関数 *)
fun bitstring2key(bitstring): key [data, typeConverter].

(* 共通鍵暗号 *)
fun encrypt(bitstring, key): bitstring.
reduc forall m: bitstring, k: key; decrypt(encrypt(m, k), k) = m.

(* クライアントとアクセスポイントのMACアドレス *)
free addrSTA, addrAP: addr.

(*             STA   AP    SNonce     ANonce     PTK *)
event message1(addr, addr,            bitstring).      (* APがSTAに送るとき(1) *)
event message2(addr, addr, bitstring, bitstring, key). (* STAがAPに送るとき(2) *)
event message3(addr, addr, bitstring, bitstring, key). (* APがSTAに送るとき(3) *)
event termSTA (addr, addr, bitstring, bitstring, key). (* STAが終了するとき *)
event termAP  (addr, addr, bitstring, bitstring, key). (* APが終了するとき *)

free s: bitstring [private]. (* 共有鍵GTKによって暗号化して送信するデータs *)
query attacker(s).           (* sの秘匿性の検証 *)

(* STAが終了するときはAPはメッセージ1を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termSTA(a1, a2, sn, an, PTK)) ==>
    inj-event(message1(a1, a2, an)).

(* STAが終了するときはAPはメッセージ3を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termSTA(a1, a2, sn, an, PTK)) ==>
    inj-event(message3(a1, a2, sn, an, PTK)).

(* APが終了するときはSTAがメッセージ2を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termAP(a1, a2, sn, an, PTK)) ==>
    inj-event(message2(a1, a2, sn, an, PTK)).


(* Client *)
let processSTA =
  (* message 1 *)
  in(c, ANonce: bitstring);
  new SNonce: bitstring;
  let PTK = PRF((PMK, ANonce, SNonce, addrAP, addrSTA)) in
  let A_MIC = HMAC(ANonce, PTK) in
  let S_MIC = HMAC(SNonce, PTK) in
  (* message 2 *)
  event message2(addrAP, addrSTA, SNonce, ANonce, PTK);
  out(c, (SNonce, S_MIC));
  (* message 3 *)
  in(c, (=ANonce, MIC: bitstring, msg: bitstring));
  if MIC = A_MIC then
  let GTK = decrypt(msg, PTK) in
  (* extra 1: encrypt s by GTK *)
  out(c, encrypt(s, bitstring2key(GTK)));
  event termSTA(addrAP, addrSTA, SNonce, ANonce, PTK).

(* Access Point *)
let processAP =
  new ANonce: bitstring;
  (* message 1 *)
  event message1(addrAP, addrSTA, ANonce);
  out(c, ANonce);
  (* message 2 *)
  in(c, (SNonce: bitstring, MIC: bitstring));
  let PTK = PRF((PMK, ANonce, SNonce, addrAP, addrSTA)) in
  let A_MIC = HMAC(ANonce, PTK) in
  let S_MIC = HMAC(SNonce, PTK) in
  if MIC = S_MIC then
  new GTK: bitstring;
  (* message 3 *)
  event message3(addrAP, addrSTA, SNonce, ANonce, PTK);
  out(c, (ANonce, A_MIC, encrypt(GTK, PTK)));
  (* extra 1: encrypt s by GTK *)
  in(c, msg_extra1: bitstring);
  if s = decrypt(msg_extra1, bitstring2key(GTK)) then
  event termAP(addrAP, addrSTA, SNonce, ANonce, PTK).

process
  ( (!processAP) | (!processSTA) )
```

記述した形式モデルをProVerifで実行すると次のような出力が得られます。
なお、出力で一番重要な部分は RESULT を含む行なので grep で RES を含む行だけを抜き出しています。また、見やすくなるように適宜改行を入れています。

```output
$ proverif wpa2.pv | grep RES
RESULT not attacker(s[]) is true.
RESULT inj-event(termSTA(a1,a2,sn,an,PTK_23)) ==>
  inj-event(message1(a1,a2,an)) is true.
RESULT inj-event(termSTA(a1_24,a2_25,sn_26,an_27,PTK_28)) ==>
  inj-event(message3(a1_24,a2_25,sn_26,an_27,PTK_28)) is true.
RESULT inj-event(termAP(a1_29,a2_30,sn_31,an_32,PTK_33)) ==>
  inj-event(message2(a1_29,a2_30,sn_31,an_32,PTK_33)) is true.
```

結果の読み方は true で安全性があることを表し、false は安全性がないことを表しています。
それぞれの結果について一つずつ見ていきます。

1. まず `RESULT not attacker(s[]) is true.` より、データsの秘匿性については安全であることが示されました。
事前共有鍵を使って共有鍵を導出し、その共有鍵で暗号化して送信したデータは、このプロトコル形式に置いては安全であるということです。
2. 次に `RESULT inj-event(*) ==> inj-event(*) is true.` より、認証は正しく行われ、リプレイ攻撃もできないことが示されました。

この時点では攻撃方法がないです。

### WPA2 -- オフライン攻撃

オフライン攻撃とは、攻撃者が盗聴や傍受によって、パスワードのハッシュ値とハッシュアルゴリズムを知っているときに行う総当たり攻撃のことです。

それでは、WPA2のプロトコルがオフライン攻撃に弱いかどうかを検証します。
事前共有鍵 PMK を宣言した部分を次のように変更してください。

```proverif
free PMK: key [private]. (* STAとAPの事前共有鍵 *)
weaksecret PMK.          (* オフライン攻撃の検証 *)
```

これをProVerifで実行すると次の出力が得られます。

```output
$ proverif wpa2.pv | grep RES
RESULT Weak secret PMK is false.
```

この結果から、オフライン攻撃によって事前共有鍵を見つけることが可能であることがわかります。
つまりWPA2はオフライン攻撃に脆弱です。

### WPA2 -- 前方秘匿性

前方秘匿性とは、ある通信で使用した秘密鍵が漏れたとしても、過去に行った通信や未来に行う通信で暗号化したデータは復号されない特性のことです。
別の言葉で言うと、前方秘匿性を実装しているということは、通信毎に異なる秘密鍵を使うようなプロトコルを実装しているということです。

それでは次に、WPA2のプロトコルが前方秘匿性を持つかを検証します。
mainプロセスの部分を次のように変更してください。

変更前：

```proverif
process
  ( (!processAP) | (!processSTA) )
```

変更後：

```proverif
process
  ( (!processAP) | (!processSTA) | phase 1; out(c, PMK) )
```

このようにすることで、phase 0 のときは事前共有鍵PMKが漏れていない状態でWPA2プロトコルを実行し、その後の phase 1 で事前共有鍵PMKを公開チャネルcに漏らすことができます。
これを実行した結果は次のようになります。

```output
$ proverif wpa2.pv | grep RES
RESULT not attacker_p1(s[]) is false.
```

PMKを漏らすように変更する前では true だった部分が、変更したら false になりました。
つまり、鍵が漏れたら以前の通信が復号できたことを表しているので、前方秘匿性はないことがわかります。

<br>

## WPA3

次に WPA3 のプロトコルを記述していきます。WPA2の4-Way Handshakeを行う前に、SAEのハンドシェイクを行い、そこで乱数を使ったDiffie-Hellman鍵共有に似たプロトコルとして Dragonfly Key Exchange を行います。

```proverif
free c: channel. (* 通信に使うチャネル *)

type key.  (* 共通鍵の型 *)
type addr. (* MACアドレスの型 *)

free password: key [private]. (* STAとAPの事前共有鍵 *)

fun PRF(bitstring): key.             (* PRF関数 *)
fun HMAC(bitstring, key): bitstring. (* HMAC関数 *)
(* bitstring型をkey型に変換する関数 *)
fun bitstring2key(bitstring): key [data, typeConverter].

(* 共通鍵暗号 *)
fun sencrypt(bitstring, key): bitstring.
reduc forall m: bitstring, k: key; sdecrypt(sencrypt(m, k), k) = m.

(* Diffie-Hellman鍵共有 *)
type G.
type exponent.
const g: G [data].       (* 生成元g *)
fun exp(G, exponent): G. (* 離散冪乗 *)
equation forall x: exponent, y: exponent; exp(exp(g,x),y) = exp(exp(g,y),x).

(* Hunting and Pecking アルゴリズムによって生成元を求める関数 *)
fun GenPE(key, addr, addr): G.

(* クライアントとアクセスポイントのMACアドレス *)
free addrSTA, addrAP: addr.

(*             STA   AP    SNonce     ANonce     PTK *)
event beginSTA(addr, addr).                            (* STAが通信を開始するとき *)
event beginAP (addr, addr).                            (* APが通信を開始するとき *)
event message1(addr, addr,            bitstring).      (* APがSTAに送るとき(1) *)
event message2(addr, addr, bitstring, bitstring, key). (* STAがAPに送るとき(2) *)
event message3(addr, addr, bitstring, bitstring, key). (* APがSTAに送るとき(3) *)
event termSTA (addr, addr, bitstring, bitstring, key). (* STAが終了するとき *)
event termAP  (addr, addr, bitstring, bitstring, key). (* APが終了するとき *)

free s: bitstring [private]. (* 導出した共有鍵GTKによって暗号化するデータs *)
query attacker(s).           (* sの秘匿性の検証 *)

(* STAが終了するときはAPは開始していたか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termSTA(a1, a2, sn, an, PTK)) ==>
    inj-event(beginAP(a1, a2)).

(* STAが終了するときはAPはメッセージ1を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termSTA(a1, a2, sn, an, PTK)) ==>
    inj-event(message1(a1, a2, an)).

(* STAが終了するときはAPはメッセージ3を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termSTA(a1, a2, sn, an, PTK)) ==>
    inj-event(message3(a1, a2, sn, an, PTK)).

(* APが終了するときはSTAは開始していたか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termAP(a1, a2, sn, an, PTK)) ==>
    inj-event(beginSTA(a1, a2)).

(* APが終了するときはSTAがメッセージ2を送信しているか & リプレイ攻撃が可能か検証 *)
query a1: addr, a2: addr, sn: bitstring, an: bitstring, PTK: key;
  inj-event(termAP(a1, a2, sn, an, PTK)) ==>
    inj-event(message2(a1, a2, sn, an, PTK)).


(* Client *)
let processSTA =
  (* --- WPA3 SAE: Dragonfly KEX --- *)
  let P = GenPE(password, addrAP, addrSTA) in
  new randomA: exponent;
  let EA = exp(P, randomA) in
  event beginSTA(addrSTA, addrAP);
  out(c, EA);
  in(c, EB: G);
  let PMK = exp(EB, randomA) in

  (* --- WPA2 4-way handshake --- *)
  (* message 1 *)
  in(c, ANonce: bitstring);
  new SNonce: bitstring;
  let PTK = PRF((PMK, ANonce, SNonce, addrAP, addrSTA)) in
  let A_MIC = HMAC(ANonce, PTK) in
  let S_MIC = HMAC(SNonce, PTK) in
  (* message 2 *)
  event message2(addrAP, addrSTA, SNonce, ANonce, PTK);
  out(c, (SNonce, S_MIC));
  (* message 3 *)
  in(c, (=ANonce, MIC: bitstring, msg: bitstring));
  if MIC = A_MIC then
  let GTK = sdecrypt(msg, PTK) in
  (* extra 1: encrypt s by GTK *)
  out(c, sencrypt(s, bitstring2key(GTK)));
  event termSTA(addrAP, addrSTA, SNonce, ANonce, PTK).

(* Access Point *)
let processAP =
  (* --- WPA3 SAE: Dragonfly KEX --- *)
  let P = GenPE(password, addrAP, addrSTA) in
  new randomB: exponent;
  let EB = exp(P, randomB) in
  in(c, EA: G);
  event beginAP(addrSTA, addrAP);
  out(c, EB);
  let PMK = exp(EA, randomB) in

  (* --- WPA2 4-way handshake --- *)
  new ANonce: bitstring;
  (* message 1 *)
  event message1(addrAP, addrSTA, ANonce);
  out(c, ANonce);
  (* message 2 *)
  in(c, (SNonce: bitstring, MIC: bitstring));
  let PTK = PRF((PMK, ANonce, SNonce, addrAP, addrSTA)) in
  let A_MIC = HMAC(ANonce, PTK) in
  let S_MIC = HMAC(SNonce, PTK) in
  if MIC = S_MIC then
  new GTK: bitstring;
  (* message 3 *)
  event message3(addrAP, addrSTA, SNonce, ANonce, PTK);
  out(c, (ANonce, A_MIC, sencrypt(GTK, PTK)));
  (* extra 1: encrypt s by GTK *)
  in(c, msg_extra1: bitstring);
  if s = sdecrypt(msg_extra1, bitstring2key(GTK)) then
  event termAP(addrAP, addrSTA, SNonce, ANonce, PTK).

process
  ( (!processAP) | (!processSTA) )
```

記述した形式モデルをProVerifで実行すると次の結果が得られます。

```output
$ proverif wpa3.pv | grep RES
RESULT not attacker(s[]) is true.
RESULT inj-event(termSTA(a1,a2,sn,an,PTK_52)) ==>
  inj-event(beginAP(a1,a2)) is true.
RESULT inj-event(termSTA(a1_53,a2_54,sn_55,an_56,PTK_57)) ==>
  inj-event(message1(a1_53,a2_54,an_56)) is true.
RESULT inj-event(termSTA(a1_58,a2_59,sn_60,an_61,PTK_62)) ==>
  inj-event(message3(a1_58,a2_59,sn_60,an_61,PTK_62)) is true.
RESULT inj-event(termAP(a1_63,a2_64,sn_65,an_66,PTK_67)) ==>
  inj-event(beginSTA(a1_63,a2_64)) is true.
RESULT inj-event(termAP(a1_68,a2_69,sn_70,an_71,PTK_72)) ==>
  inj-event(message2(a1_68,a2_69,sn_70,an_71,PTK_72)) is true.
```

この時点では秘匿性や認証に対する攻撃は見つかりませんでした。

### WPA3 – オフライン攻撃

次に WPA3 がオフライン攻撃に耐性があるかを検証します。
事前共有鍵 password を宣言している行のところを、次のように変更します。

```proverif
free password: key [private]. (* STAとAPの事前共有鍵 *)
weaksecret password.          (* オフライン攻撃の検証 *)
```

これで実行すると weak secret is true となります。
なお、true は安全であることを意味します。

```
$ proverif wpa3.pv | grep RES
RESULT Weak secret password is true (bad not derivable).
```

これにより、WPA3はオフライン攻撃に強いことが確認できました。

### WPA3 – 前方秘匿性

続いて、WPA3の前方秘匿性について検証していきます。
オフライン攻撃の検証で使用した `weaksecret password.` は一旦コメントアウトした上で、mainプロセスを次のように変更してください。

```
process
  ( (!processAP) | (!processSTA) | phase 1; out(c, password) )
```

これで実行すると not attacker(s) is true となります。
true は安全であることを意味します。

```
$ proverif wpa3.pv | grep RES
RESULT not attacker_p1(s[]) is true.
```

よって、WPA3は鍵が漏れた場合でも、それ以前の暗号化した通信データは復号することができないことがわかり、前方秘匿性を持っていることが確認できました。



-----

### 参考文献

[^ProVerif]: [B.Blanchet(Project leader), "ProVerif: Cryptographic protocol verifier in the formal model"](https://prosecco.gforge.inria.fr/personal/bblanche/proverif/)
[^ProVerif-Tutorial]: [B.Blanchet, B.Smyth, and V.Cheval, "ProVerif 2.00: Automatic Cryptographic Protocol Verifier, User Manual and Tutorial"](https://prosecco.gforge.inria.fr/personal/bblanche/proverif/manual.pdf)
[^Dolev-Yao]: [D.Dolev and A.Yao, "On the Security of Public Key Protocols," IEEE Transactions on Information Theory, Vol.29(2), pp.198–208, 1983.](https://www.cs.huji.ac.il/~dolev/pubs/dolev-yao-ieee-01056650.pdf)
