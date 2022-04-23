---
layout:        post
title:         "PowerShellで複数ファイルを一つにまとめる"
date:          2022-04-20
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

PowerShellで複数ファイルを一つにまとめるには、複数ファイルを Get-Content で表示して、その内容を Set-Content で一つのファイルにまとめて書き込みます。
Set-Content を使うことで、エンコードが UTF-8 や SJIS であってもそのままのエンコードでファイルが作成されるため、文字化けしなくなります。

```ps1
PS> Get-Content *.csv | Set-Content output.txt
```

Get-Content は cat と省略でき、Set-Content は sc と省略できるので、短く書く場合は以下のようなコマンドになります。

```ps1
PS> cat *.csv | sc output.txt
```

#### 補足：リダイレクト `>` を使うと文字化けする
テキストの内容が ASCII だけの場合は、リダイレクトの `>` を使っても問題ありません。
しかし、ファイルのエンコードが UTF-8 や SJIS だと、結果のファイルは文字化けしてしまいます。
```ps1
PS> Get-Content *.csv > output.txt
```

#### ソートしてから保存する
文字列のソートは Sort-Object (sort) コマンドレットを使います。
Get-Content と Set-Content の間のパイプラインに Sort-Object を入れても、UTF-8 や SJIS はそのままのエンコードでファイルに保存されます。
```ps1
PS> Get-Content *.csv | Sort-Object | Set-Content output.txt
PS> cat *.csv | sort | sc output.txt
```

#### ソートして重複を取り除いてから保存する
ソートした後に重複を取り除いてファイルに保存する場合は、Sort-Object の後に Get-Unique します。
```ps1
PS> Get-Content *.csv | Sort-Object | Get-Unique | Set-Content output.txt
PS> cat *.csv | sort | gu | sc output.txt
```

以上です。
