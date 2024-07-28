---
layout:        post
title:         "[Windows] CertreqコマンドでCSRファイルを作成する"
date:          2023-08-21
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

CSR（Certificate Signing Request）とは、SSL/TLS サーバー証明書を発行するための証明書署名要求のことです。
Windowsでopensslコマンドが使えないときにCSRファイルを作成するには、標準でインストールされているcertreqコマンドを使用します。
実行ファイルのパスは C:\Windows\System32\certreq.exe です。

### Certreqコマンド

certreqでCSRファイルを作成するときは、-Newオプションで、第1引数にINFファイル、第2引数に出力ファイル名を指定します。
実行するときは「**管理者権限**」で実行します。

```
CertReq.exe -New CertReq.inf MyCertReq.csr
```

### INFファイル

INFファイルには作成するCSRファイルの情報を記載します。
書き方は ini ファイルの形式です。
以下にINFファイルの例を示します。

```ini
[Version]
Signature="$Windows NT$"

[NewRequest]
; サブジェクト
Subject = "C=JP;S=Nagano;L=Nagano;O=Sample Co.,Ltd.;CN=tex2e.example.com"
; サブジェクトの区切りをセミコロン「;」とする（デフォルトだと「,」）
X500NameFlags = 0x40000000
; 秘密鍵をエクスポート可能にする
Exportable = TRUE
; 鍵のサイズ
KeyLength = 2048
; ローカルコンピュータに鍵をインポートする
MachineKeySet = True
; 証明書署名要求形式
RequestType = PKCS10
; ハッシュアルゴリズム
HashAlgorithm = sha256
; キー使用法は「データの暗号化」「デジタル署名」「キーの暗号化」「非否認」
KeyUsage = CERT_DATA_ENCIPHERMENT_KEY_USAGE | CERT_DIGITAL_SIGNATURE_KEY_USAGE | CERT_KEY_ENCIPHERMENT_KEY_USAGE | CERT_NON_REPUDIATION_KEY_USAGE
; フレンドリー名
FriendlyName = tex2e.example.com

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 ; Server Authentication（サーバ認証）
; OID=1.3.6.1.5.5.7.3.2 ; Client Authentication（クライアント認証）

[Extensions]
; サブジェクトの別名（SANs）
2.5.29.17 = {text}
_continue_ = dns=tex2e.example.com&
```

CSRファイルを作成するためのINFファイルの各項目の説明は以下の通りです。
- [NewRequest]
  - **Subject** : サブジェクト
    - CN : コモンネーム（接続するURLのFQDN）
    - O : 組織名
    - L : 市町村
    - S または ST : 都道府県
    - C : 国名
  - **X500NameFlags** : サブジェクトの区切り文字の指定方法
  - **Exportable** : 秘密鍵をエクスポート可能にする
  - **KeyLength** : 公開鍵と秘密鍵の長さ
  - **MachineKeySet** : ローカルコンピュータに鍵をインポートする
  - **RequestType** : 証明書署名要求の形式（一般的にはPKCS10）
  - **HashAlgorithm** : ハッシュアルゴリズム
  - **KeyUsage** : 鍵の使用方法。複数あるときは `CERT_DIGITAL_SIGNATURE_KEY_USAGE | CERT_KEY_ENCIPHERMENT_KEY_USAGE` のようにパイプ（論理和）でつなげる
  - **FriendlyName** : フレンドリー名。Windowsで証明書を管理しやすくするための独自項目
- [EnhancedKeyUsageExtension]
  - **OID** : 証明書の利用目的。サーバ認証またはクライアント認証のいずれかを指定
- [Extensions]
  - **2.5.29.17** : サブジェクトの別名 (SANs)。ドメイン名で指定するときは「dns=」で記載する。

以上です。


### 参考資料

- [certreq \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certreq_1)
- [X500NameFlags (certenroll.h) - Win32 apps \| Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/win32/api/certenroll/ne-certenroll-x500nameflags)
- [CertreqでCSRを作る方法-やぶろぐ](https://yabuisya.blogspot.com/2020/12/certreqcsr.html)


