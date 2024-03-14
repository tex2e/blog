---
layout:        book
title:         "[暗号技術入門] 鍵共有・鍵交換"
date:          2024-03-06
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    false
# sitemap: false
# feed:    false
---

暗号学において、鍵確立 (key establishment) または別の呼び方で鍵交換、鍵交渉とは、共通の秘密が2つの当事者に利用可能になるプロセスまたはプロトコルであり、通常は暗号化された通信のために使用されます。鍵を確立する技術は鍵合意または鍵輸送スキームになります。

- **鍵合意**スキームでは、両当事者が共通の秘密を作るのに必要な材料を交換し合い、共通鍵を作成します。
  鍵合意スキームの例としては、Diffie-Hellman (DHKE) や楕円曲線Diffie-Hellman (ECDH) があります。
- **鍵輸送**スキームでは、当事者のうちの1つだけが共通の秘密を作成し、もう一方の当事者がそれから秘密を取得します。
  鍵輸送スキームは通常、公開鍵暗号を介して実装されます。
  例えば、RSA鍵交換では、クライアントがランダムなセッションキーを自身の秘密鍵で暗号化してサーバーに送信し、サーバーでクライアントの公開鍵を使用して復号化されます。

[**鍵交換**](https://en.wikipedia.org/wiki/Key_exchange)スキームは、他の誰もが鍵のコピーを取得できないように、2つの当事者間で暗号鍵を安全に交換します。
通常、暗号化された会話 (例：TLSハンドシェイク) の開始時に、当事者は最初に会話中に使用される暗号鍵 (共通の秘密) について交渉します。
鍵交換スキームは、インターネット上の何百万ものデバイスやサーバーによって何百回も鍵が交換されるため、現代の暗号学において非常に重要なトピックです。

**鍵交渉** (**鍵確立**) スキームは、ラップトップがWi-Fiネットワークに接続するたびやWebブラウザが `https://` プロトコルを介してWebサイトを開くたびに実行されます。
鍵交渉は、匿名鍵交換プロトコル (DHKEのような)、パスワードまたは事前共有鍵 (PSK)、デジタル証明書、または多くの要素の組み合わせに基づいて行われることがあります。一部の通信プロトコルは1度だけ共通の秘密鍵を確立し、他のものは時間の経過とともに常に秘密鍵を変更します。

**認証付き鍵交換** (AKE) は、関係する当事者のアイデンティティを認証する鍵交換プロトコルにおけるセッションキーの交換です (例：パスワード、公開鍵、デジタル証明書を介して)。
例えば、パスワードで保護されたWi-Fiネットワークに接続するとき、ほとんどの場合は、**パスワード認証付き鍵合意** (PAKE) が使用されます。
公共のWi-Fiネットワークに接続するときは匿名鍵合意が行われます。

### 鍵交換・鍵合意アルゴリズム

多くの暗号アルゴリズムが鍵交換や鍵確立のために存在します。一部は公開鍵暗号システムを使用し、他のものは単純な鍵交換スキーム (Diffie–Hellman鍵交換など) を使用します。
鍵交換には、一部はサーバー認証やクライアント認証を含みます。また、一部はパスワードを使用したり、デジタル証明書や他の認証メカニズムを使用したりします。

鍵交換スキームの例としては、[**Diffie–Hellman鍵交換**](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) (**DHKE**) や[**楕円曲線Diffie–Hellman**](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman) (**ECDH**)、[**RSA-OAEP**](https://en.wikipedia.org/wiki/Optimal_asymmetric_encryption_padding)や**RSA-KEM** (RSA鍵輸送)、[**PSK**](https://en.wikipedia.org/wiki/Pre-shared_key) (事前共有鍵)、[**SRP**](https://en.wikipedia.org/wiki/Secure_Remote_Password_protocol) (Secure Remote Password protocol)、**FHMQV** (Fully Hashed Menezes-Qu-Vanstone)、[**ECMQV**](https://www.cryptopp.com/wiki/Elliptic_Curve_Menezes-Qu-Vanstone) (Ellictic-Curve Menezes-Qu-Vanstone)、および[**CECPQ1**](https://en.wikipedia.org/wiki/CECPQ1) (量子安全鍵合意) があります。

この章では、最初の公開鍵プロトコルの1つである古典的なDiffie–Hellman鍵交換 (DHKE) スキームから説明していきます。


#### ディフィー・ヘルマン鍵交換 (DHKE) 

[**ディフィー・ヘルマン鍵交換**](https://ja.wikipedia.org/wiki/ディフィー・ヘルマン鍵共有) (DHKE) は、公開 (安全でない) チャネルを介して暗号鍵を安全に交換するための暗号化手法 (鍵合意プロトコル) であり、盗聴された通信が鍵を明らかにしないようにします。交換された鍵は後で暗号化通信に使用されます (例えば、AESのような対称暗号を使用)。
**DHKE**は最初の公開鍵プロトコルの1つであり、2つの当事者がデータを安全に交換できるようにします。したがって、当事者間の通信を嗅ぎ取ると、交換された情報が明らかになります。
ディフィー・ヘルマン (DH) 方式は匿名鍵合意スキームであり、互いに事前の知識がない2つの当事者が安全でないチャネル上で共有秘密鍵を共同で確立できるようにします。
DHKE方式は[**スニッフィング攻撃**](https://ja.wikipedia.org/wiki/スニッフィング攻撃) (データ傍受) に耐性がありますが、[**中間者攻撃**](https://ja.wikipedia.org/wiki/中間者攻撃) (攻撃者が2つの当事者間の通信を秘密裏に中継して通信内容を改竄する攻撃) には脆弱です。
**ディフィー・ヘルマン鍵交換**プロトコルは、離散対数 (古典的な[**DHKE**](https://ja.wikipedia.org/wiki/ディフィー・ヘルマン鍵共有)アルゴリズム) または楕円曲線暗号 (**ECDH**アルゴリズム) を使用して実装できます。

#### 色の混合による鍵交換

ディフィー・ヘルマン鍵交換プロトコルを説明するときは、非常に似ている概念である「色の混合による鍵交換」を使うことで、視覚的な表現があり、理解を容易にしてくれます。
そのため、まずは**色の混合**によって秘密の色を交換する方法を説明します。
色の混合鍵交換スキームの設計では、異なる色の液体があれば、色を簡単に混ぜ合わせて新しい色を得ることができますが、逆の操作は不可能と仮定します。
つまり、混合された色を元の色成分に分離する方法はありません。

以下が色の交換による秘密の色を共有する方法です。ステップごとに進めます：

- Alice と Bob は、秘密にする必要のない初期の (共有の) 色を任意に決めます (例：黄色)。
- Alice と Bob は、それぞれが秘密に保持する秘密の色を選択します (例：赤色 と シーグリーン色)。
- 最後に Alice と Bob は、お互いに共有する色と秘密の色を混ぜ合わせます (この場合、オレンジ色 と ライトスカイブルー色)。
  得られた混合色は鍵交換のために公開することができます。

色の交換の次のステップは次のとおりです：

- Alice と Bob は、お互いの混合色を公開して交換します。
  - 秘密の色を混合色から抽出 (分離) する効率的な方法がないと仮定し、混合色を知っている第三者は秘密の色を明らかにすることはできません。
- 最後に、Alice と Bob は、パートナーから受け取った色を自分の秘密の色と混ぜ合わせます。
  - 結果は最終的な色の混合 (黄褐色) であり、パートナーの色の混合と同一です。この色が安全に交換された共有鍵です。

第三者が色の交換プロセスを傍受した場合、秘密の色を特定するのは計算量的に困難です。
ディフィー・ヘルマン鍵交換プロトコルは同様の概念に基づいていますが、色の混合の代わりに離散対数とモジュラー指数を使用しています。

#### ディフィー・ヘルマン鍵交換(DHKE)プロトコル

それでは、**DHKE**プロトコルがどのように動作するかを見ていきましょう。
**DHKE**は、[**モジュラー指数法**](https://en.wikipedia.org/wiki/Modular_exponentiation)の単純な性質に基づいています：

$$
(g^a)^b \equiv (g^b)^a \pmod p
$$

ここで、$g, a, b, p$ は正の整数です。

もし、$A = g^a \mod p$ かつ $B = g^b \mod p$ があれば、$a$ や $b$ (これらは**秘密指数**と呼びます) を明かさずに $g^{a^b} \mod p$ を計算することができます。
計算理論上は、秘密指数を見つける効率的なアルゴリズムは存在しません。
つまり、以下の式から $m, g, p$ を持っているときに、式を満たす $s$ を見つけるのは困難ということです。

$$
m = g^s \mod p
$$

秘密指数 $s$ を見つける効率的 (高速) なアルゴリズムは存在しません。
これは[離散対数問題](https://en.wikipedia.org/wiki/Discrete_Logarithm_Problem_(DLP)) (DLP) として知られています。

#### 離散対数問題 (DLP) 

コンピュータサイエンスにおける**離散対数問題** (**DLP**) は、与えられた要素 $b$ と値 $a$ = $b^x$ が与えられたとき、指数 $x$ を見つける (存在する場合) 問題と定義されます。
指数 $x$ は[**離散対数**](https://en.wikipedia.org/wiki/Discrete_logarithm)と呼ばれ、すなわち $x = \log_b{(a)}$ です。要素 $a, b \in \mathbb{Z}/p\mathbb{Z}$、$p$ は素数です。

暗号学では、多くのアルゴリズムが、DLP問題の計算的困難性に依存しており、効率的なアルゴリズムが存在しない厳密に選択された群上で行われます。

### DHKEプロトコル

モジュラー指数の数学的性質に慣れたところで、**DHKEプロトコル**を説明します。
DHKEプロトコルの鍵交換プロセスの各ステップをは以下の通りです。

- AliceとBobは、2つの公開整数 $p$ と $g$ を使用することに同意します (ここで $p$ は[素数](https://en.wikipedia.org/wiki/Prime_number)であり、$g$ は[剰余の原始根](https://en.wikipedia.org/wiki/Primitive_root_modulo_n) です)。
  - 例えば、$p = 23$ かつ $g = 5$ とします。
  - 整数 $g$ と $p$ は公開され、通常はソースコード内でハードコードされた定数です。
- Aliceは秘密の整数 $a$ (例: $a = 4$) を選択し、次に $A = g^a \mod p$ を計算してBobに送信します。
  - $A$ は公開されます。これは公開チャネルを介して送信され、その傍受によって秘密指数 $a$ が明らかにされることはありません。
  - この例では、$A = 54 \mod 23 = 4$
- Bobは秘密の整数 $b$ (例: $b = 3$) を選択し、次に $B = g^b \mod p$ を計算してAliceに送信します。
  - この例では、$B = 53 \mod 23 = 10$
- Aliceは $s = B^a \mod p$ を計算します。
  - この例では、$s = 104 \mod 23 = 18$
- Bobは $s = Ab \mod p$ を計算します。
  - この例では、$s = 43 \mod 23 = 18$
- AliceとBobはこの時点で秘密の数 $s$ を共有しています。
  - $s = A^b \mod p = B^a \mod p = (g^a)^b \mod p = (g^b)^a \mod p = g^{a^b} \mod p = 18$
  - 通信路を盗聴している第三者が利用可能な数 $A$ と $B$ から共有秘密鍵 $s$ を計算することはできません。なぜなら、秘密指数 $a$ と $b$ は効率的に計算できないからです。

DHKEの最も一般的な実装 ([RFC 3526](https://tools.ietf.org/html/rfc3526)) では、基数は $g = 2$ であり、モジュラス $p$ は大きな素数 (1536 ... 8192 ビット) です。

#### DHKEプロトコルのセキュリティ

DHKEプロトコルは、[Diffie–Hellman問題](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_problem)と呼ばれる計算量的困難さに基づいています。
これは、コンピュータサイエンスでよく知られている[DLP](https://en.wikipedia.org/wiki/Discrete_Logarithm_Problem_(DLP)) (離散対数問題) の変種であり、まだ効率的なアルゴリズムが存在しない問題です。
DHKEは、非秘匿の整数の列を、安全でない公開 (盗聴可能な) チャネル (ケーブルを通る信号や空中を伝播する波など) を介して交換しますが、秘密に交換された共有プライベートキーを明らかにしません。
注意ですが、DHKEプロトコルはその古典的な形式では[**中間者攻撃**](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)に脆弱です。
ここでハッカーは、当事者間で交換されるメッセージを傍受して変更することができます。

最後に、整数 $g, p, a, p$ は通常、非常に大きな数 (1024、2048、4096ビット以上) であり、これにより[**総当たり攻撃**](https://en.wikipedia.org/wiki/Brute-force_attack)は無意味になります。


### ECDH (楕円曲線ベースのDiffie-Hellman鍵交換プロトコル)

**楕円曲線Diffie–Hellman (ECDH)**は、楕円曲線の公開鍵と秘密鍵ペアを持つ2つの当事者が、安全でないチャネルを介して共有秘密を確立する匿名鍵合意プロトコルです。
**ECDH**は、モジュラー指数計算が楕円曲線計算に置き換えられ、セキュリティが向上したクラシカルなDHKEプロトコルの変種です。

古典的なディフィー・ヘルマン鍵交換 (DHKE) アルゴリズムを示すために、Pythonで簡単なコード例を示しましょう。
まず、Pythonパッケージ `PyDHE` をインストールします：

```cmd
pip install pyDHE
```

次に、DHKEの例のコードを記述します：

```python
import pyDHE

alice = pyDHE.new()
alicePubKey = alice.getPublicKey()
print("Aliceの公開鍵:", hex(alicePubKey))

bob = pyDHE.new()
bobPubKey = bob.getPublicKey()
print("Bobの公開鍵:", hex(bobPubKey))

print("ここで公開鍵を交換します (一般的にはインターネットを介して) ")

aliceSharedKey = alice.update(bobPubKey)
print("Aliceの共有鍵:", hex(aliceSharedKey))

bobSharedKey = bob.update(alicePubKey)
print("Bobの共有鍵:", hex(bobSharedKey))

print("共有鍵が等しいか:", aliceSharedKey == bobSharedKey)
```

上記のコードを実行すると、AliceとBobの2048ビットの公開鍵が生成されて表示されます。
AliceとBobが公開鍵を交換したと仮定します (例：インターネットを介してお互いに送信)。
AliceがBobの公開鍵を受け取ったら、それを彼女の秘密鍵と組み合わせて**共有秘密** (Shared Secret) を計算できます。
同様に、BobがAliceの公開鍵を受け取ったら、それを彼の秘密鍵と組み合わせて**共有秘密**を計算できます。
上記の例からのサンプル出力は、共有秘密が常に同じ数値 (2048ビットの整数) であることを示しています：

```
Alice public key: 0xa26c2f1354a8f58abbf78172730595c4de8277962ebe92100793f99ea80f66abe5e75a14a52e86ce1c086c1ca2e1662b3900510346d848b425d34279ceea92661fb1166b9438589c0b57eb4ebb69e0c3844ebe5ad4c0e316b637d47148d69dc2387c2968c82d198114a6c0f14a605a9e85110d24a9db4f11963b9b13dc788c0538096cadffd258364c63621f6bb1a3e515d3741af4619e62452a394fab9d84be7cee255fdd7216401cafee6471b4adbb77e93f878f1bb4df633e0632522b51fe70fc154e7d3e60a69f815a4e2a84506f05b1ccfce01e873cd7dc51fba0b6eac66af1c0a7500f71af405a6c34ffd27a1239180c22fbddf8dc15d30c821c57307d
Bob public key: 0x822660dfff1af80c237402263dda9e0e417fa04547a4e36041a35a152df28b0ac66b059d9e0034c7cd58b6b7edbc8a20bf1bdc2af6534bd6f2dbcffeb9a4aa9f038461994622f786258beb8f6493594e1559e5ebf5a92ba60335f668a9ccbf8d6d87460f21d94938ac40cfd78d062571f68aa7e7fbabed4ba582e8e831288670004ae64be113a2c7b5b9a472ba4733ea4f29c1b1f30ead3729908d9bb54278a499b2c16cc62d4f330a28cdd302bf655f3d724b6d5b0655c9299ada183d8bed4e98c2f0d93339eb3c22c88c9d000de4ea3286b6be5b96e7d7cccb7b8d6a079264e155c5b25b5aca21ccfed7d21d5dce79845fe5456419504ec9c2a896448572e7
Now exchange the public keys (e.g. through Internet)
Alice shared key: 0x60d96187ae1db8e8acac7795837a2964e4972ebf666eaecfa09135371a2de5287db18c1a30f2af840f04cac42fea21e42369af5ffbeb235faa42da6bed24cd922ea4637ad146558f2d8b07b19a0084c19f041af5456a5826dd836d0c9c4f32ca0a5877da9493af36f66949e76af12e45a20b20c222a37a49b658066bd7b1f79bcf81d1083e79c62c43e3ee11f8727e798e310a2683939c06b75ab80c531743d6c03c90007ab8a36af45b3573f4e41a2a41c9fdde962493f9ed860597ee527d978e41a413d13198aaac2b27e70aac5be15fd695592350c56b6d74b3427dcf6888ee11cef4b4d8f5b3acbfbda1d9b8d7425bc9446e1a6424a929d9136590161cfe
Bob shared key: 0x60d96187ae1db8e8acac7795837a2964e4972ebf666eaecfa09135371a2de5287db18c1a30f2af840f04cac42fea21e42369af5ffbeb235faa42da6bed24cd922ea4637ad146558f2d8b07b19a0084c19f041af5456a5826dd836d0c9c4f32ca0a5877da9493af36f66949e76af12e45a20b20c222a37a49b658066bd7b1f79bcf81d1083e79c62c43e3ee11f8727e798e310a2683939c06b75ab80c531743d6c03c90007ab8a36af45b3573f4e41a2a41c9fdde962493f9ed860597ee527d978e41a413d13198aaac2b27e70aac5be15fd695592350c56b6d74b3427dcf6888ee11cef4b4d8f5b3acbfbda1d9b8d7425bc9446e1a6424a929d9136590161cfe
Equal shared keys: True
```

鍵生成プロセス中のランダム性により、出力が異なることに注意してください。
上記のコードは、[RFC 3526](https://tools.ietf.org/html/rfc3526#section-3)で指定されている2048ビットの公開鍵と秘密鍵を使用しています。
RFC 3526の異なる群 (Group) を指定することで、1536ビットから8192ビットまでの範囲でDHKEの鍵サイズを変更することができます (例：8192ビット鍵の場合は id=18)。例えば、次の2行を変更します：

```python
alice = pyDHE.new(group=18)
bob = pyDHE.new(group=18)
```

上記の変更により、8192ビットの鍵に切り替わり、計算が大幅に遅くなります。出力は次のようになります：

```
Alice public key: 0x86b2c2bda3982af803084b65d982c08f3462046d154c9ee6fb7c8dcdd4a2922b72487c46e42777ea8bbfad73ca2f340397ddc2b3ddb215891b4811fe014ae176918cc01817e4d9358e6053ed49790e224721bd14abe7cdeac10be211782d0b1a110c5968654873b1eb3e591c6e5acd0197459aac04da06620d424b327124dee4958fe49be3f44100591e8560a0e137abb9c47973e4701b3e127a05482934b3b9fdb4117365c476bb6665d867b2dd58cab72073bcb6632883fba3043b8544a4726fcd013f1676963d612f634675674de1d295e90101d9a0523ae1717eb2ea11a05e4902af572a9bfff0344c3383e8b85fa7db234927b053d098eda9fda0970c92917caa95fe4dc79376f6b8f0ee4a9682c88870c36b345049b3ef89bdcfc0f8751b02afa88b22fd5b94d33a49bcf6d262255ac18e27e96675f311b654f99fa31e060f7e2afbd888099bba072cefaab1e1c40a73845c139e3feaecee76965b71255473b485976e7f7d87e2ff61a62ddadd5f7f02e9353f5d4f091360418eb7935e83d1e6355c82feff3583725017e8b8b6148af839e3e7cfd3d549b679d9878544366676509b61b590ce25abbb440207b23fec9c04daef70590c46d720af273d6dafb34d2e5b68e24499a4b7ac254ee000712dd0e4ae72299fb103098b8d54c2c28a66e74d52db4853bb695cbff9a09f8223c55f1e2fd351d419a091cc643b3abc42a477ef6f3eb9d2913e45bcb3ba76771bccfafa85abe3cf37c42bf1baf59f122785ec47b51b45c4ba0875e6a80230c5035e45c1cf32e8b7b52ee44e2c3b06330c29f047dd5b0983ae8db34d1ca1a127d1da72d4e0244690c63af4ecf3003152a1cfaa5b4139c361cd3cc54fb7e91bdcac9bf81498da90cf249621df90947ccbece28c5befec6bf832d873e18293e7b8e9562596c4b50c61e1aff9b8d13a02df25675c5045aec14d3e83253d210ae7e6f2c62d622c7bcaf87cd6a4bb63a25d18cc0672fe3488eefb058231daf17a570382ffb56e490b1e5003284ca5a8978aa4c09d3e9a11eae379bd66fe86999c10fbe1eb6763d1b6b4f277e8347462e91f127a0f2fe8a9a16381452e3515608e950587f74e1f85b10ab32e667248f8764d90a8b92eb6bcce14cf7306fa56bc7852a0f2811651665f2121a6253e3e4bfecb12b54c8cd11a54d74346c3b9f2c8c7b71ea60fce8eb1d3badcea909b7f082e4e4a4ad4e2a501b2fd3a4c7acd48b416706dc3fbda180cec831bacd558fc15cfa3e19347bb5297ac7a4b931b6e19f9b0dfb0c07696727402c1c5215c0822776147a9a9c7c10bc04d23d6cee974fc37a32fd758cd09bff9f0b1cdd9e09734aa0abe0dc9f3a74415c411ce2b07369445d6e4929a0132db60024cf260b17fb3401beb794a5a365a3be92677fb68f60e091cb5cfc5d767290c4655d6922c2bd194671d5b
Bob public key: 0xbae8a1e6b00ee2df7996323f2d03dd650dcc19e5f2de8c77b4dcd0c611ab50e1bdd41c5d3b8060a3047616b0a2e55aee0d8211b1d7b18e996e3cd02cf3580247ca42707f73a02266beb077f50b32940c2e09f08f1906f177bb1ce3fb6c8516d2f45091aba35a1afac904e694e4c844c3603fd7c8750c15ae349486160d4ce5fce0c228c8edcd6599f0e680f6928ea7bbec0e9e3787f1476ce02692a22862df0213287dbc0864602c29314f3de68625940d4dd1ac47d506015dbfee92cda106e5f13360b7d805973b03634726e2e0905bf61736d188cd3d90f667543547496fa0d9b609320d84d09cde89ff5c1077e811664102f0c69cad41f620fb0ce9651708b8dc3caec2a78029d449e30976cbe943d39545a1a3979febbf3e890d2bb389180addcb5af1606baedc4ad2479fe840adae9a64df36de02b019ff2b639dec3234d844656ef894273e07c272fbd1c650ea853bcdc3518118bf78dc9959a83633e43a04245d563c2e948be7fa1ffa21e1bb203ae9339e5d9e7a1e0c8ba53cd3c67fc8ba63b1a266299eeb4f66810854b5780e6cb232d04350079ffc58914ec8d9b3345321c1d55ab0b87fbcd58c01d63d276497cdcfcf79615cac39af387322baeca6dd1659f4646c487dcae7a84ca77d61fdbd99e81fab7111d6396eb387497a4f914dd45ca67a2e3c026ddd12f4446397af8fe724228a9aad6e40fe6f788aae5999d60866934f81519b0f709818150b9f61a2a7f1e742423a6da12e05b30a6b4f64f93d3eacda690ad390ec6358bcfc0de052fdff8c1ede1e3ea5dff104551771d8f3f4556ef8cb64df7b9a66d56e5964dc31ab28bdacd46d7a6ea994fbb6fe302b34ffa2cb095f5a4ee9bee18ae2f6ca29f269bb55995804f9925c10a7e5e5ad3010734b01b192f047c433e04fd836e0ef77b3d6a05503e1692168c664058d5562bec8f53d3839a117e170add42aa7cd941532cbc6eb6d5f411742cc436ceb679c8f827d538ccc3064dd41b91a77d5f3e68a44b63af94c95bc93656cdc7a6e9776db02c9ada793f8a1e16315f39b664564aa676d9cc8a304aa5ab1849b49b905cc18bb798c2ac8db40a3e0533224dba5b0084ff5855cf840123b29d8738a2df891f32fd883d984b37aed8a3ffb8c121e5a4e187dc8165d3aacf7698b01dc405590c14acd22e0e2a483d71a8d28d671f1b5f3c6ea06121b4c8adc6e261720b3dcd66748659cda7ddd8db727dfbf58047386b32a3a3bb7288c85d8712a984abb68d7f364d5498c8be4e3e15b87a8b6794d9fd19e36d416344659a7c427bd1723a5d4574bb6ac9be7181045ec4c1c8d2cd6ca9c7d7187647a6637e684cb57fd16ea635c18de9845487db591db7bebd3373b5b62f623080a2e007061b0e7a481ffa53e8e6801cfa562feb8b5794b4a363d3163ebcc2f7e69d8f3334d6564a5dd1020
Now exchange the public keys (e.g. through Internet)
Alice shared key: 0x964d9b37aa16599c0ce2442f887302555e91d4adb3ae42518a573d149bbdbf31d716e100f7cab9b2c1aa1e02b6ecf770db0aa2a92b945a87c3c62764c0e44945322d358bd0b5ddc5517afbc88714c1d66bede6a209e69f66b23937bf3e2d38357a3365efe2f1624ff653adc76eccc98df66a67da7e93f4ec9ad5487412725f8ab675f3a3234ac88c8585a6232385b69cfc0a02c520609e7df5fd19814e6d10c7bb0d040bc5b4f8927db9bf006c67a797080f04aa740b6c1aa93c24c49e3bdf93b8911134fe07768b910b166516e560cbd12f3b20d293f83c6744e3bc019ba5b46e0fb50e02d7e74da46c3870027c870e4fb81f23a073355069b01feb5b1c445a6231a59f5a67a84c7334a9d635ddb33644c05a1f5f22d8e47d214d99d797660f3691bc55a616a0d2ef9c8f8845385ae808f9aef35b94e710c58691be4819a7e1db320fc933dd8eded761bfee1a021b169c734a486f46154cebceff4e47b83099080bbbb21db2c7042de10be5305901ec5f56056618ae063d1ac7e5351a0774c1ae898f64897cd41e553041f4cd3aa5786c8b998beb3ddabf6129df9207b52270a6ed48d612a1909634967d552b3216a2189904ed9f75ffa319a6d911e0a39cc0bf45cd0b0b55a90060ff642b038d12fa97125e46a1473ec50a01cd90a24af5f55f3841514a3fbe304ed9501a03bb28bed0ab23651d496748170f2f769fd997e6cd638b7267e7ee58e7f6a866f3e2ab94be5ddb675fa741d2784ea9025ab99dc639a6af90e32a1634dc9bcba5aef6e0ec6f1138cf9d170fafc6c2aee8f1c8af9a0cb1fd2b3932e7c35d87c3cde1034213fefe7495e927109cc0d0c7b4f1ee7588ae85da923c8d761241fcc98300d03a1d41a81fb716896fd2d0d4c95a416651d64568ea0b164d97fe28d0a4645cebde9038d5c376accbaaaca7f140b4ee960d85b1811bc108a33f9186521388f8addccf356bb8c03aa430f4193c1ffdd6af9e431847029b83d0379f23fd8a353fa35f1b13f5df53c243bd4bab1df6c586612145c0743f29a0b6939d6bb4082feae75ef89f04fbacefba862ff8efc216241ffffffbf55b91394a488a20c7bab19eaf2336f1785a70b2cc2f27be5054b10681e829c0958622d9e686c226e8160795190abb87da710c46e032ca314b3f3699044642c8669c72c06596fbda1be5eb502e8d51fb0f4812750e465761f5266f2ecd1537396d53c9218aa21aaeda3564241a99305f312d58fb053926e08f06c315d9877454006b6b6d8f4dd75c744d27c302617d43577f5a03577fc7b70cecf01f53445bafd0fd6f4d90cb75fa5e1da591874c4e486e1c18a3097b0c4d00a8a69306551eb8b4138b085942a3f4dfdf3ae62e510eab6ead63473db09c373a7915ccaf8c0441a8c35e1cd21be057a5a1e8203ca687c1bd89d2fe6b82f83716f3b14b7be192
Bob shared key: 0x964d9b37aa16599c0ce2442f887302555e91d4adb3ae42518a573d149bbdbf31d716e100f7cab9b2c1aa1e02b6ecf770db0aa2a92b945a87c3c62764c0e44945322d358bd0b5ddc5517afbc88714c1d66bede6a209e69f66b23937bf3e2d38357a3365efe2f1624ff653adc76eccc98df66a67da7e93f4ec9ad5487412725f8ab675f3a3234ac88c8585a6232385b69cfc0a02c520609e7df5fd19814e6d10c7bb0d040bc5b4f8927db9bf006c67a797080f04aa740b6c1aa93c24c49e3bdf93b8911134fe07768b910b166516e560cbd12f3b20d293f83c6744e3bc019ba5b46e0fb50e02d7e74da46c3870027c870e4fb81f23a073355069b01feb5b1c445a6231a59f5a67a84c7334a9d635ddb33644c05a1f5f22d8e47d214d99d797660f3691bc55a616a0d2ef9c8f8845385ae808f9aef35b94e710c58691be4819a7e1db320fc933dd8eded761bfee1a021b169c734a486f46154cebceff4e47b83099080bbbb21db2c7042de10be5305901ec5f56056618ae063d1ac7e5351a0774c1ae898f64897cd41e553041f4cd3aa5786c8b998beb3ddabf6129df9207b52270a6ed48d612a1909634967d552b3216a2189904ed9f75ffa319a6d911e0a39cc0bf45cd0b0b55a90060ff642b038d12fa97125e46a1473ec50a01cd90a24af5f55f3841514a3fbe304ed9501a03bb28bed0ab23651d496748170f2f769fd997e6cd638b7267e7ee58e7f6a866f3e2ab94be5ddb675fa741d2784ea9025ab99dc639a6af90e32a1634dc9bcba5aef6e0ec6f1138cf9d170fafc6c2aee8f1c8af9a0cb1fd2b3932e7c35d87c3cde1034213fefe7495e927109cc0d0c7b4f1ee7588ae85da923c8d761241fcc98300d03a1d41a81fb716896fd2d0d4c95a416651d64568ea0b164d97fe28d0a4645cebde9038d5c376accbaaaca7f140b4ee960d85b1811bc108a33f9186521388f8addccf356bb8c03aa430f4193c1ffdd6af9e431847029b83d0379f23fd8a353fa35f1b13f5df53c243bd4bab1df6c586612145c0743f29a0b6939d6bb4082feae75ef89f04fbacefba862ff8efc216241ffffffbf55b91394a488a20c7bab19eaf2336f1785a70b2cc2f27be5054b10681e829c0958622d9e686c226e8160795190abb87da710c46e032ca314b3f3699044642c8669c72c06596fbda1be5eb502e8d51fb0f4812750e465761f5266f2ecd1537396d53c9218aa21aaeda3564241a99305f312d58fb053926e08f06c315d9877454006b6b6d8f4dd75c744d27c302617d43577f5a03577fc7b70cecf01f53445bafd0fd6f4d90cb75fa5e1da591874c4e486e1c18a3097b0c4d00a8a69306551eb8b4138b085942a3f4dfdf3ae62e510eab6ead63473db09c373a7915ccaf8c0441a8c35e1cd21be057a5a1e8203ca687c1bd89d2fe6b82f83716f3b14b7be192
Equal shared keys: True
```

以上です。
