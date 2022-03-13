---
layout:        post
title:         "UUID (GUID) とは"
date:          2021-04-03
category:      Protocol
cover:         /assets/cover1.jpg
redirect_from: /misc/uuid-and-guid
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

GUIDとUUIDはどちらも一意な識別子を生成する方法ですが、
GUIDはMicrosoft社が定義・実装したもので、
UUIDは[RFC4122](https://tools.ietf.org/html/rfc4122)で定義されているものです [^rfc4122]。
基本的にはどちらも同じですが、厳密には若干仕様に違いがあります。

[^rfc4122]: [RFC 4122 - A Universally Unique IDentifier (UUID) URN Namespace](https://tools.ietf.org/html/rfc4122)

### GUIDとUUIDの違い

GUIDとUUIDの主な違いは、以下のものがあります [^1]。

1. GUIDは全ての桁が任意の16進数であるのに対して、
   UUIDはバージョンとバリアントフィールドは指定されたビットを入れないといけない
2. GUIDは出力が全て大文字でなければならない (MUST) に対して、
   UUIDは出力は小文字にすべきで、入力は大文字小文字の両方を受け付けるべき (SHOULD) 

[^1]: [Is there any difference between a GUID and a UUID? - Stack Overflow](https://stackoverflow.com/questions/246930/is-there-any-difference-between-a-guid-and-a-uuid)

### UUID

UUIDの形式は「8-4-4-4-12桁」の次のような構成をしています。Xには16進数（0～9, A～F）が入ります。ハイフンを含めて合計32文字です。

`{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}` (X = 0, ..., 9, A, ..., F)

UUIDには5つのバージョンがあり、3つ目のグループの最上位桁で表現します（例えばバージョン4のときは、`{XXXXXXXX-XXXX-4XXX-XXXX-XXXXXXXXXXXX}`）。
- UUIDバージョン1では、UUIDを生成するコンピュータのMACアドレスとナノ秒単位の時刻を使って計算します。
  このため、UUIDが作られたPCとその時刻がばれてしまいます。
- UUIDバージョン2では、ローカルのPOSIXのユーザID（UID）を計算に利用するようになりました。
- UUIDバージョン3では、URL、完全修飾ドメイン名(FQDN)、オブジェクト識別子(OIDs)、その他データから、MD5を使って導出します。
  しかし現在MD5は暗号理論的に破られているため、非推奨となっています。
- UUIDバージョン4では、疑似乱数を用いてUUIDを生成します。
- UUIDバージョン5は、バージョン3のハッシュ関数MD5をSHA-1に変更しただけで、他の部分は同じです。


UUIDの値が重複する確率は、毎秒1億個のUUIDを生成することを100年間繰り返して、ようやく50%の確率で衝突するといわれています。
ただし、この理論はUUIDが正しく生成されていることが前提で、実装に不備などがあるとこの通りにはなりません。

---
