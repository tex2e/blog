---
layout:        post
title:         "配列(CSV)をDataRowに変換する [VB.NET]"
date:          2020-06-20
category:      VB.NET
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

DataRowに値を格納する例として、1. 要素を一つずつDataRowに格納する例、2. 配列をDataRowに変換する例、3. CSVをDataRowに変換する例 のVB.NETプログラムを以下に示します。

```vb
Imports System
Imports System.Data

Module VBModule

    Sub Main()

        'テーブルの列を定義
        Dim columns As DataColumn() = {
            New DataColumn("商品名", System.Type.GetType("System.String")),
            New DataColumn("個数", System.Type.GetType("System.Decimal")),
            New DataColumn("料金", System.Type.GetType("System.Decimal"))
        }

        'テーブルに列を追加
        Dim dt As DataTable = New DataTable
        dt.Columns.AddRange(columns)

        'テーブルにレコード追加
        '1件目（要素を一つずつDataRowに格納する例）
        Dim newRow1 As DataRow = dt.NewRow
        newRow1("商品名") = "りんご"
        newRow1("個数") = 12
        newRow1("料金") = 2000D
        dt.Rows.Add(newRow1)
        '2件目（配列をDataRowに変換する例）
        Dim record2 As Object() = {"みかん", 6, 1000D}
        Dim newRow2 As DataRow = dt.NewRow
        newRow2.ItemArray = record2
        dt.Rows.Add(newRow2)
        '3件目（CSVをDataRowに変換する例）
        Dim record3 As String() = "いちご,8,1500".Split(",") 'カンマ区切りを配列にする
        Dim newRow3 As DataRow = dt.NewRow
        newRow3.ItemArray = record3
        dt.Rows.Add(newRow3)

        'テーブル内のレコードを表示
        For i As Integer = 0 To dt.Rows.Count - 1
            Console.WriteLine((i+1) & "件目")
            For Each col As DataColumn In dt.Columns
                Console.WriteLine("  " & col.ColumnName & " : " & dt.Rows(i)(col).ToString)
            Next
        Next
        ' => 1件目
        '      商品名 : りんご
        '      個数 : 12
        '      料金 : 2000
        '    2件目
        '      商品名 : みかん
        '      個数 : 6
        '      料金 : 1000
        '    3件目
        '      商品名 : いちご
        '      個数 : 8
        '      料金 : 1500

    End Sub

End Module
```

DataRowに値を格納する方法には `datarow("カラム名") = 値` と `datarow.ItemArray = 配列` の2通りあります。
配列の型は Object() や String() でもどちらでもOKです。

入力ファイルがCSVで、レコードの各要素の値が全て存在するときは、後者の ItemArray を使うことで簡単に配列をDataRowに変換できます。

上のコード例では、CSVを配列にするときに `Split(",")` を使っていますが、CSVの仕様では `aaa,bbb,ccc` も `"aaa","b 改行 bb","c""cc"` も正しいCSVデータなので、入力データの形式は事前に確認しておきましょう。

以上です。


### 参照

- [DataTable Class (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datatable?view=netcore-3.1)
- [DataColumn Class (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datacolumn?view=netcore-3.1)
- [DataColumnCollection Class (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datacolumncollection?view=netcore-3.1)
- [DataRow Class (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datarow?view=netcore-3.1)
- [RFC 4180 - Common Format and MIME Type for Comma-Separated Values (CSV) Files](https://tools.ietf.org/html/rfc4180)
