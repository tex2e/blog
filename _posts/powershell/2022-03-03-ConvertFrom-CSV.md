---
layout:        post
title:         "[PowerShell] ConvertFrom-CSVでタブ区切り (TSV) をforeachで1行ずつ処理する"
date:          2022-03-03
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

PowerShell の ConvertFrom-CSV コマンドレットでタブ区切り文字列の TSV データを foreach で順番に処理していくプログラムの書き方について説明します。

まず、TSVの文字列をヒアドキュメントの中に貼り付けます。
元のデータは Excel などからコピーしてくることを想定しています。
ヒアドキュメントは、変数展開する `@" 〜 "@` と、変数展開しない `@' 〜 '@` の2種類がありますが、入力文字列はTSVなので、展開しないシングルクォートの方を使います。

そして、TSVのヒアドキュメントを ConvertFrom-CSV コマンドレットに渡します。
ConvertFrom-CSV のオプションは -Header と -Delimiter を指定します。
-Header は各列の名前を付けるためのオプションで、各列のカラム名を配列 `@('col1', 'col2', ...)` で指定します。
-Delimiter は区切り文字を指定するオプションで、タブを PowerShell のエスケープ文字列であるバッククォートを使って <code>`t</code> と指定します。

TSVの文字列を1行ずつ処理して、表示するプログラム例を以下に示します。

```powershell
$list = @'
1	TitleA	URL1
2	TitleB	URL2
3	TitleC	URL3
'@ | ConvertFrom-CSV -Header @('number', 'title', 'url') -Delimiter "`t"

foreach ($row In $list) {
    Write-Output("{0:d3}) {1}: {2}" -f ($row.number -as [int]), $row.title, $row.url)
}
```

実行結果は以下のようになります。

```
001) TitleA: URL1
002) TitleB: URL2
003) TitleC: URL3
```

Import-CSV コマンドレットだとTSVをファイルに保存する際のエンコードを気にする必要がありますが、プログラム内にTSVを埋め込むことでエンコードの心配は不要になります。

以上です。

### 参考文献
- [ConvertFrom-Csv (Microsoft.PowerShell.Utility) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/Microsoft.PowerShell.Utility/ConvertFrom-Csv?view=powershell-7.2)
