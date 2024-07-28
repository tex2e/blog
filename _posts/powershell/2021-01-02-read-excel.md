---
layout:        post
title:         "[PowerShell] Excelを読み込む"
date:          2021-01-02
category:      PowerShell
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellからExcelの内容を読み込む方法について説明します。
ExcelはCOMを介して処理を行うことができ、その識別子は Excel.Application です。
PowerShellでCOMオブジェクトを使用するには `New-Object -ComObject <識別子>` と書きます。

以下はExcelのシート1のA1の値を表示する例です。

```powershell
$excelFile = ".\test.xls"
$sheetName = "Sheet1"

$excelFile = (Get-ChildItem $excelFile).FullName
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$book = $excel.Workbooks.Open($excelFile, 0, $true)
$sheet = $book.Worksheets.Item($sheetName)

Write-Host $sheet.Cells.Item(1, 1).Text
```

- Get-ChildItem と .FullName でファイルの絶対パスを取得します。
- New-Object -ComObject でCOMオブジェクトを使用します。
- .Visible = $false でExcelを表示しないで処理を実行します。
- .Workbooks.Open(ファイル名, リンクの更新方法, 読み取り専用) でExcelを開きます[^1]。リンクの更新方法が 0 の場合は何もしません。
- .Worksheets.Item(シート名) で指定したシートを開きます。注意点として、**ExcelはSJISなので、シート名が日本語のときは、PowerShellのファイルはSJISにして**実行する必要があります[^2]。
- .Cells.Item(y座標, x座標) でセルの位置を指定します。

以上です。

---

[^1]: [Open メソッド (Excel) \| Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open)
[^2]: PowerShellのファイルを UTF-8 で保存すると、日本語のシート名が検索できないので、代わりに .Worksheets.Item(シート番号) とする方法もあります。
