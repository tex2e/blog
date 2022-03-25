---
layout:        post
title:         "DataRow変更前後の値をDataRowVersionで取得する"
date:          2020-06-21
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

DataRow変更前と変更後の値を設定して、DataRowVersionで変更前後の値を取得する方法 (VB.NET) について説明します。

追加した値を元の値として設定するには dt.AcceptChanges()、値の変更をしたいときは dr.BeginEdit() ＆ dr.EndEdit() を使います。

DataRowの変更前後の値を取得するには DataRow.Item\[String, DataRowVersion] を使います。

```vb
Imports System
Imports System.Data

Module VBModule

    Sub Main()

        'テーブルの列を定義
        Dim columns As DataColumn() = {
            New DataColumn("商品名", System.Type.GetType(System.String)),
            New DataColumn("個数", System.Type.GetType(System.Decimal)),
            New DataColumn("料金", System.Type.GetType(System.Decimal))
        }

        'テーブルに列を追加
        Dim dt As DataTable = New DataTable
        dt.Columns.AddRange(columns)

        'テーブルにレコード追加
        Dim record1 As Object() = {"みかん", 6, 500D}
        Dim newRow1 As DataRow = dt.NewRow
        newRow1.ItemArray = record1
        dt.Rows.Add(newRow1)

        '現在の値を Original として設定する
        dt.AcceptChanges()

        '変更したい値を Current として設定する
        newRow1.BeginEdit() 'Propose として設定開始
        newRow1("商品名") = "りんご"
        newRow1("料金") = 1000D
        newRow1.EndEdit() 'Propose を Current に変換して設定する

        'テーブル内のレコードを表示
        Dim dr As DataRow = dt.Rows(0)
        Console.WriteLine("Before")
        For Each col As DataColumn In dt.Columns
            Console.WriteLine("  " & col.ColumnName & " : " & 
                dr(col, DataRowVersion.Original).ToString)
        Next
        Console.WriteLine("After")
        For Each col As DataColumn In dt.Columns
            Console.WriteLine("  " & col.ColumnName & " : " & 
                dr(col, DataRowVersion.Current).ToString)
        Next
        ' => Before
        '      商品名 : みかん
        '      個数 : 6
        '      料金 : 500
        '    After
        '      商品名 : りんご
        '      個数 : 6
        '      料金 : 1000
    End Sub

End Module
```



### 参照

- [DataRowVersion Enum (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datarowversion?view=netcore-3.1)
- [DataRow.Item\[\] Property (System.Data) \| Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.data.datarow.item?view=netcore-3.1#System_Data_DataRow_Item_System_String_System_Data_DataRowVersion_)
