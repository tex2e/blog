---
layout:        post
title:         "[VB.NET] DataTableから条件に合う行だけを更新する"
date:          2020-07-05
category:      VB.NET
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

DataTableから条件に合う行を選択するには .Select("where句の内容") と書きます。
また、.Select で抽出した結果は元のDataTableと同じ参照を持っているため、選択した行の内容を変更すると、元のDataTableにも変更が反映されます。

```vb
Imports System
Imports System.Data

Module VBModule

    Sub Main()
        Dim dataTable As DataTable
        Dim dataRow As DataRow

        'テーブルの列を定義
        Dim columns As DataColumn() = {
            New DataColumn("商品名", System.Type.GetType("System.String")),
            New DataColumn("値段", System.Type.GetType("System.Decimal"))
        }

        'テーブルに列を追加
        dataTable = New DataTable
        dataTable.Columns.AddRange(columns)

        'テーブルに行を追加
        dataRow = dataTable.NewRow()
        dataRow("商品名") = "りんご"
        dataRow("値段") = 800D
        dataTable.Rows.Add(dataRow)
        dataRow = dataTable.NewRow()
        dataRow("商品名") = "みかん"
        dataRow("値段") = 200D
        dataTable.Rows.Add(dataRow)
        dataRow = dataTable.NewRow()
        dataRow("商品名") = "ぶどう"
        dataRow("値段") = 1200D
        dataTable.Rows.Add(dataRow)

        '値段の高い商品の名前に「高級」を付け加える
        Dim dataRows = dataTable.Select("値段 >= 800")
        For Each dataRow As DataRow In dataRows
            dataRow("商品名") = "高級" + dataRow("商品名")
        Next

        'テーブルの内容を表示
        For Each dataRow In dataTable.Rows
            Console.WriteLine("---")
            For Each col As DataColumn In dataTable.Columns
                Console.WriteLine("  " & col.ColumnName & " : " & dataRow(col).ToString)
            Next
        Next
    End Sub
    
End Module
```

出力結果：

```output
---
  商品名 : 高級りんご
  値段 : 800
---
  商品名 : みかん
  値段 : 200
---
  商品名 : 高級ぶどう
  値段 : 1200
```

以上です。
