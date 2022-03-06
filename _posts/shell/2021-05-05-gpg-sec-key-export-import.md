---
layout:        post
title:         "GPG秘密鍵を別PCに移動させる"
date:          2021-05-05
category:      Shell
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

PC移行作業でGPG秘密鍵も移動させる（エクスポート＆インポート）ときの手順です。

### 移行元PC

移行元PCのgpgで秘密鍵をエクスポートします。

```bash
$ gpg -a --export-secret-key mymail@example.com > sec.pem
```

### 移行先

エクスポートした秘密鍵を移行先PCでインポートします。

```bash
$ gpg --import sec.pem
$ gpg --list-key
/c/Users/myname/.gnupg/pubring.kbx
---------------------------------
pub   ed25519 2018-10-26 [C]
      F38F3A06B593ED8881D8934D402F552C68EFB93F
uid           [ unknown] myname <mymail@example.com>
sub   rsa4096 2018-10-26 [SEA]
```

インポートした秘密鍵の公開鍵の信用値をunknownから最大の「5」に変更します。

```bash
$ gpg --edit-key mymail@example.com

Secret key is available.

sec  ed25519/402F552C68EFB93F
     created: 2018-10-26  expires: never       usage: C
     trust: unknown       validity: unknown
ssb  rsa4096/38A3BCAF7168C0C3
     created: 2018-10-26  expires: never       usage: SEA
[ unknown] (1). myname <mymail@example.com>

gpg> trust
sec  ed25519/402F552C68EFB93F
     created: 2018-10-26  expires: never       usage: C
     trust: unknown       validity: unknown
ssb  rsa4096/38A3BCAF7168C0C3
     created: 2018-10-26  expires: never       usage: SEA
[ unknown] (1). myname <mymail@example.com>

Please decide how far you trust this user to correctly verify other users keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5   # <== 「5」と入力
Do you really want to set this key to ultimate trust? (y/N) y   # <== 「y」と入力

sec  ed25519/402F552C68EFB93F
     created: 2018-10-26  expires: never       usage: C
     trust: ultimate      validity: unknown
ssb  rsa4096/38A3BCAF7168C0C3
     created: 2018-10-26  expires: never       usage: SEA
[ unknown] (1). myname <mymail@example.com>
Please note that the shown key validity is not necessarily correct
unless you restart the program.

gpg> quit   # <== 「quit」と入力
```

#### Gitコマンドで署名

以下はGPGをGitのタグの署名で使う人向けの設定です。

署名時に使用する秘密鍵を指定する。

```bash
$ git config --global user.signingkey F38F3A06B593ED8881D8934D402F552C68EFB93F
```

署名付きタグの作成する（パスフレーズの入力が必要）。

```bash
$ git tag -s 2021.05 -m '2021.05' dafc828
```

タグをpushする。

```bash
$ git push origin 2021.05
```


### 参考文献

- [Git Bash for Windows で構築する GitHub・GnuPG の環境（自分用メモ） - Qiita](https://web.archive.org/web/20201101014836/https://qiita.com/sprout2000/items/e67053e09380c2227500)
- [GnuPGのコマンド](https://web.archive.org/web/20190511014248/http://www.nina.jp/server/windows/gpg/commands.html)
- [Git - 作業内容への署名](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E4%BD%9C%E6%A5%AD%E5%86%85%E5%AE%B9%E3%81%B8%E3%81%AE%E7%BD%B2%E5%90%8D)
- [git tagの使い方まとめ - Qiita](https://qiita.com/growsic/items/ed67e03fda5ab7ef9d08)
