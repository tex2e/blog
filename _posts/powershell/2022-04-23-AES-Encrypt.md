---
layout:        post
title:         "PowerShellでAES暗号を利用する"
date:          2022-04-23
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellでAES暗号を利用するためのプログラム例を示します。
CBCモードでIVを使う場合と、ECBでIVを使わない場合の2通りを紹介します。

### CBCモードでAES暗号化

CBCモードで鍵を使って平文をAES暗号化する例を以下に示します。
ECBモードとの違いは、暗号化のときに IV (初期ベクタ) も生成している点です。
なお、ここでの鍵の生成は、パスワードをSHA256ハッシュ値を使用しています。

```ps1
Add-Type -AssemblyName System.Security

function GetSHA256Hash($s) {
    $sha256 = New-Object System.Security.Cryptography.SHA256Managed
    $utf8   = New-Object System.Text.UTF8Encoding
    $h = $sha256.ComputeHash($utf8.GetBytes($s))
    return $h
}

function AESEncrypt($KeyByte, $PlaintextByte) {
    $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $AES.Mode = "CBC"
    $AES.Padding = "PKCS7"
    $AES.Key = $KeyByte
    $AES.GenerateIV()
    $iv = $AES.IV
    # 暗号化オブジェクト生成
    $Encryptor = $AES.CreateEncryptor()
    # 暗号化
    $EncryptedByte = $Encryptor.TransformFinalBlock($PlaintextByte, 0, $PlaintextByte.Length)
    # オブジェクト削除
    $Encryptor.Dispose()
    $AES.Dispose()
    return $EncryptedByte, $iv
}
function AESDecrypt($KeyByte, $CiphertextByte, $IV) {
    $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $AES.Mode = "CBC"
    $AES.Padding = "PKCS7"
    $AES.Key = $KeyByte
    $AES.IV = $IV
    # 復号オブジェクト生成
    $Decryptor = $AES.CreateDecryptor()
    # 復号
    $DecryptedByte = $Decryptor.TransformFinalBlock($CiphertextByte, 0, $CiphertextByte.Length)
    # オブジェクト削除
    $Decryptor.Dispose()
    $AES.Dispose()
    return $DecryptedByte
}

# 平文
$PlaintextString = "This is a secret!"
# 平文をバイト配列にする
$PlaintextByte = [System.Text.Encoding]::UTF8.GetBytes($PlaintextString)
# パスワード
$Password = "password123"
# パスワードを鍵にする
$Key = GetSHA256Hash $Password

# AES暗号化
$CiphertextByte, $IV = AESEncrypt $Key $PlaintextByte
Write-Host "CiphertextByte: $CiphertextByte"
Write-Host "IVByte: $IV" # 初期ベクタ
Write-Host "Ciphertext: $CiphertextByte)"
Write-Host "Ciphertext(Base64): $([System.Convert]::ToBase64String($CiphertextByte))"

# AES復号
$DecryptedByte = AESDecrypt $Key $CiphertextByte $IV
# バイト配列から平文にする
$DecryptedString = [System.Text.Encoding]::UTF8.GetString($DecryptedByte)
Write-Host "Decrepted: $DecryptedString"
```

<br>

### ECBモードでAES暗号化

次に、ECBモードで鍵を使って平文をAES暗号化する例を以下に示します。
ECBモードでは IV の生成が必要ない代わりに、暗号としての安全性が低下します。
なお、ここでの鍵の生成は、パスワードをSHA256ハッシュ値を使用しています。

```ps1
Add-Type -AssemblyName System.Security

function GetSHA256Hash($s) {
    $sha256 = New-Object System.Security.Cryptography.SHA256Managed
    $utf8   = New-Object System.Text.UTF8Encoding
    $h = $sha256.ComputeHash($utf8.GetBytes($s))
    return $h
}

function AESEncrypt($KeyByte, $PlaintextByte) {
    $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $AES.Mode = "ECB"
    $AES.Padding = "PKCS7"
    $AES.Key = $KeyByte
    # 暗号化オブジェクト生成
    $Encryptor = $AES.CreateEncryptor()
    # 暗号化
    $EncryptedByte = $Encryptor.TransformFinalBlock($PlaintextByte, 0, $PlaintextByte.Length)
    # オブジェクト削除
    $Encryptor.Dispose()
    $AES.Dispose()
    return $EncryptedByte
}
function AESDecrypt($KeyByte, $CiphertextByte) {
    $AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $AES.Mode = "ECB"
    $AES.Padding = "PKCS7"
    $AES.Key = $KeyByte
    # 復号オブジェクト生成
    $Decryptor = $AES.CreateDecryptor()
    # 復号
    $DecryptedByte = $Decryptor.TransformFinalBlock($CiphertextByte, 0, $CiphertextByte.Length)
    # オブジェクト削除
    $Decryptor.Dispose()
    $AES.Dispose()
    return $DecryptedByte
}

# 平文
$PlaintextString = "This is a secret!"
# 平文をバイト配列にする
$PlaintextByte = [System.Text.Encoding]::UTF8.GetBytes($PlaintextString)
# パスワード
$Password = "password123"
# パスワードを鍵にする
$Key = GetSHA256Hash $Password

# AES暗号化
$CiphertextByte = AESEncrypt $Key $PlaintextByte
Write-Host "Ciphertext: $CiphertextByte)"
Write-Host "Ciphertext(Base64): $([System.Convert]::ToBase64String($CiphertextByte))"

# AES復号
$DecryptedByte = AESDecrypt $Key $CiphertextByte
# バイト配列から平文にする
$DecryptedString = [System.Text.Encoding]::UTF8.GetString($DecryptedByte)
Write-Host "Decrepted: $DecryptedString"
```

以上です。

### 参考文献

- [AES 256 の PowerShell 実装](http://www.vwnet.jp/windows/PowerShell/AES.htm)
- [C# で AES暗号 (共通鍵暗号) を 利用 する 方法 - galife](https://garafu.blogspot.com/2015/12/aescryptgraphy.html)
- [AesCryptoServiceProvider クラス (System.Security.Cryptography) \| Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.security.cryptography.aescryptoserviceprovider?view=net-6.0)
- [PowerShell - SHA256ハッシュ値文字列の取得 - hakeの日記](https://hake.hatenablog.com/entry/20170213/p1)
