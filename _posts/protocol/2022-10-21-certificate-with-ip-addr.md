---
layout:        post
title:         "サーバ名がIPアドレスの場合の証明書作成 / サブジェクト代替名 (SAN) の設定方法"
date:          2022-10-21
category:      Protocol
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ローカルのサーバにIP直接アクセスでHTTPS通信する場合、証明書のサブジェクト代替名 (subjectAltName; SAN) にIPアドレスを追加することで、証明書の検証が成功するようになります。

SANを追加した証明書 (server.crt) と秘密鍵 (server.key) は以下のコマンドで作成できます。
署名要求ファイル (.csr) のサブジェクトやドメイン名・IPアドレスは適切な値に修正してから実行してください。

```bash
$ openssl genrsa -out server.key
$ openssl req -new -key server.key -out server.csr -subj "/C=JP/ST=Tokyo/L=Minato City/O=TeX2e/CN=mytest.example.com"
$ cat <<'EOS' > san.txt
subjectAltName = DNS:mytest.example.com, IP:192.168.11.2
EOS
$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt -extfile san.txt
$ openssl x509 -text -in server.crt -noout
```

- サブジェクト："/C=国名/ST=都道府県名/L=市町村名/O=組織名/CN=コモンネーム(ドメイン名)"
- サブジェクト代替名：subjectAltName = DNS:ドメイン名, IP:サーバのIPアドレス

<!-- markdown-link-check-disable -->
Webサーバ側に秘密鍵、クライアント側に証明書をインストールした状態でWebページ (例: https://192.168.11.2/) にアクセスすると証明書の検証に失敗せずに、HTTPS通信ができます。
<!-- markdown-link-check-enable-->

IPアドレスに直接アクセスする場合や、ドメイン名(FQDN)でアクセスする場合について、SANがない証明書を利用したHTTPSサーバをChromeでアクセスすると ERR_CERT_AUTHORITY_INVALID のエラーが表示され、証明書の検証に失敗します。
[RFC 2818 - HTTP Over TLS](https://datatracker.ietf.org/doc/html/rfc2818) に証明書の検証におけるドメイン名の比較にコモンネーム (Common Name; CN) ではなく、サブジェクト代替名 (Subject ALternative Name; SAN) を使うべき と書かれており、Chromeはこれに準拠した実装になったためです。

>   If a subjectAltName extension of type dNSName is present, that MUST
>   be used as the identity. Otherwise, the (most specific) Common Name
>   field in the Subject field of the certificate MUST be used. Although
>   the use of the Common Name is existing practice, it is deprecated and
>   Certification Authorities are encouraged to use the dNSName instead.
>
>   (著者訳) DNS名のsubjectAltName拡張が含まれていない場合は、コモンネームのサブジェクト名を使わなければならない。
>   ただし、コモンネームの使用は非推奨である。

コモンネームはワイルドカードの指定ができるので、ドメイン名のマッチが曖昧になります。
例えば、コモンネーム「*.example.com」はドメイン名「foo.example.com」や「bar.example.com」などにマッチします（ただし foo.bar.example.comにはマッチしない)。
コモンネームのワイルドカードを利用した、組織の管理外のドメイン名でサーバを立てることができる攻撃方法も想定されます。

IPアドレスに直接アクセスする場合は、証明書のサブジェクト代替名 (SAN) にIPアドレスを含めることで、証明書の検証が成功するようになります。

>   In some cases, the URI is specified as an IP address rather than a
>   hostname. In this case, the iPAddress subjectAltName must be present
>   in the certificate and must exactly match the IP in the URI.
>
>   (著者訳) ホスト名の代わりにIPアドレスでアクセスする場合、証明書のサブジェクト代替名 (SAN) にIPアドレスを含めなければならない。

以上です。

### 参考資料
- [RFC 2818 - HTTP Over TLS](https://datatracker.ietf.org/doc/html/rfc2818#section-3.1)
- [Chromeで使える証明書の作成方法](https://blog.sa2taka.com/post/chrome-certifificate-creation/)
