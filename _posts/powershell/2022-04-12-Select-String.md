---
layout:        post
title:         "PowerShellでgrep (Select-String) を使う"
date:          2022-04-12
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

PowerShellでgrepするには、Select-String (sls) コマンドレットを使います。

#### grep -r (ディレクトリ下を再帰的に検索)
Linux でディレクトリ下を再帰的ファイル内から文字列を検索するときは `grep -r 'REGEX' .` を実行しますが、同じことを PowerShell で実行したい場合は Get-ChildItem (dir) と Select-String を組み合わせて検索します。

```ps1
Get-ChildItem -Recurse | Select-String -Pattern "REGEX"
```

PowerShellで再帰的に検索するときに、特定のファイル形式のみを抽出するには `-Filter` オプションを使用します。

```ps1
Get-ChildItem -Recurse -Filter "*.java" | Select-String -Pattern "REGEX"
```

PowerShellで検索する対象フォルダを複数指定することもできます。指定するには `-Path` オプションでパスの一覧の配列を渡します。

```ps1
$TARGET_DIR = @(
    'C:\path\to\dir1\',
    'C:\path\to\dir2\',
    'C:\path\to\dir3\'
)
Get-ChildItem -Recurse -Path $TARGET_DIR | Select-String -Pattern "REGEX"
```

#### grep -v (正規表現にマッチしないものだけを表示)
パターンに一致しないものだけを表示させるときは `grep -v 'REGEX'` ですが、PowerShell では `-NotMatch` オプションを使用します。

```ps1
cat file.txt | Select-String -NotMatch "REGEX"
```

#### grep -E (正規表現で検索)
パターンを正規表現で指定するときは `grep -E 'REGEX'` ですが、PowerShell では `-Pattern` を使用します。オプションを省略した場合はデフォルトで使用されるため、Select-String ではデフォルトで正規表現を使用して検索します。

```ps1
cat file.txt | Select-String -Pattern "REGEX"
```

#### grep -i (正規表現で大文字小文字を区別)
- Linuxのgrepは、次の条件でパターンの正規表現の大文字小文字を解釈します。
    - `grep` : 大文字小文字を区別する
    - `grep -i` : 大文字小文字を区別しない
- PowerShellのSelect-Stringは、次の条件でパターンの正規表現の大文字小文字を解釈します。
    - `Select-String -CaseSensitive` : 大文字小文字を区別する
    - `Select-String` : 大文字小文字を区別しない

```ps1
cat file.txt | Select-String -Pattern "REGEX" -CaseSensitive
```

#### grep -F (通常の文字列として検索)
正規表現ではなく普通の文字列検索をするときは `grep -F STRING` ですが、PowerShell では `-SimpleMatch` オプションを使用します。

```ps1
cat file.txt | Select-String -SimpleMatch "STRING"
```

#### 文字コードを指定して検索する (Select-String -Encoding)
PowerShell では `-Encoding` オプションを使うことで、読み取るファイルのエンコードを指定できます。
適切なエンコードを指定しないと、日本語などの文字を検索するときに、マッチしなくなっていまいます。
UTF8のときは「-Encoding UTF8」、Shift-JISのときは「-Encoding Default」を指定します。
```ps1
cat file.txt | Select-String -Pattern "REGEX" -Encoding UTF8
```

#### 補足： ls (Get-ChildItem) の結果から一致するファイル名を抽出
Linuxでは `ls | grep` みたいに書けますが、PowerShellでは ls の結果は配列なので、Select-String を使うことができません。
代わりに where (Where-Object) を使用します。
例えば ls の場合、結果で得られるオブジェクトには Name というプロパティがあり、そこがファイル名を持つので、Name に対して -match で正規表現マッチしたものだけ表示するには、以下のどちらかのコマンドを使用します。
```ps1
ls | where Name -match "REGEX"

ls | where { $_.Name -match "REGEX" }
```

以上です。

#### 参考文献
- [Select-String (Microsoft.PowerShell.Utility) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/Microsoft.PowerShell.Utility/Select-String?view=powershell-7.2)
- [『Windows PowerShellクックブック』 2008/10](https://amzn.to/3PkOtKf) (p.145)
