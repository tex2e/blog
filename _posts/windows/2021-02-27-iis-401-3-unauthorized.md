---
layout:        post
title:         "IISのサイトでHTTPエラー401.3 Unauthorized"
date:          2021-02-27
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

IISの設定をした際に、アクセスしたら 401.3 Unauthorized のHTTPエラーが出た時の対処方法について説明します。

まず、エラー時は次のように表示されています。

```
HTTP エラー 401.3 - Unauthorized

Web サーバーにあるこのリソースに対するアクセス制御リスト (ACL) 構成または暗号化設定により、このディレクトリまたはページを表示するアクセス許可がありません。

可能性のある原因:
* Web サーバーによって認証されたユーザーにファイル システム上のファイルを開くアクセス許可がありません。
* リソースが汎用名前付け規則 (UNC) 共有に存在する場合、認証されたユーザーの共有および NTFS へのアクセス許可が不足したり、共有のアクセス許可が物理パスのアクセス許可と一致しなかったりすることがあります。
* ファイルが暗号化されています。

対処方法:
* エクスプローラーを開き、要求されているファイルのアクセス制御リスト (ACL) を確認します。Web サイトにアクセスしているユーザーからのアクセスが明示的に拒否されていないことを確認し、ファイルを開くアクセス許可があることを確認します。
* エクスプローラーを開き、共有と物理パスのアクセス制御リストを確認します。共有と物理パスでリソースへのアクセスが許可されていることを確認します。
* エクスプローラーを開き、要求されているファイルの暗号化プロパティを確認します (この設定は、プロパティの [属性] の [詳細設定] にあります)。
```

エラーの原因として一番可能性のあるのは IIS がファイルへのアクセス許可がないことです。
そこで、アクセスしたい対象のフォルダで、プロパティ→セキュリティ→編集→追加で「IUSR」を選択します。

必要に応じて「IIS_IUSRS」も追加してください（IISのバージョンによって必要or不要？）。

対象のページに再度アクセスして、Unauthorizedエラーが発生しなければ成功です。


### 参考文献

- [IIS での既定のアクセス許可とユーザー権限 - Internet Information Services \| Microsoft Docs](https://docs.microsoft.com/ja-jp/troubleshoot/iis/default-permissions-user-rights)
- [IIS でのフォルダーアクセス権限を設定する - hd 5.0](https://sk44.hatenablog.com/entry/20180808/1533699138)
