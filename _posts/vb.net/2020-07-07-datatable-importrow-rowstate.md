---
layout:        post
title:         "ImportRowしたときのRowStateの変化"
date:          2020-07-07
category:      VB.NET
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

DataTable には ImportRow(dataRow) という、別の DataTable のレコード (DataRow) をコピーして自分の DataTable に追加するメソッドがあります。
その際、元のテーブルにあった行の RowState はどうなるかというと、そのまま引き継がれます。

```vb
Imports System
Imports System.Data

Module VBModule

    Sub Main()
        Dim dataTable As DataTable
        Dim dataTable2 As DataTable
        Dim dataRow As DataRow

        'テーブル1の作成
        dataTable = New DataTable
        dataTable.Columns.Add(New DataColumn("Name", System.Type.GetType("System.String")))
        dataRow = dataTable.NewRow()
        dataRow("Name") = "Alice"
        dataTable.Rows.Add(dataRow)

        'テーブル2を作成
        dataTable2 = New DataTable
        dataTable2.Columns.Add(New DataColumn("Name", System.Type.GetType("System.String")))

        '--- Importする行がUnchangedのとき ---
        dataRow.AcceptChanges() '行の状態をUnchangedにする
        dataTable2.Clear()
        dataTable2.ImportRow(dataRow)
        Console.WriteLine("コピー元 : " + Me.GetRowState(dataTable.Rows(0)))
        Console.WriteLine("コピー先 : " + Me.GetRowState(dataTable2.Rows(0)))
        '=> コピー元 : DataRowState.Unchanged
        '=> コピー先 : DataRowState.Unchanged

        '--- Importする行がAddedのとき ---
        dataRow.AcceptChanges()
        dataRow.SetAdded() '行の状態をAddedにする
        dataTable2.Clear()
        dataTable2.ImportRow(dataRow)
        Console.WriteLine("コピー元 : " + Me.GetRowState(dataTable.Rows(0)))
        Console.WriteLine("コピー先 : " + Me.GetRowState(dataTable2.Rows(0)))
        '=> コピー元 : DataRowState.Added
        '=> コピー先 : DataRowState.Added

        '--- Importする行がModifiedのとき ---
        dataRow.AcceptChanges()
        dataRow.SetModified() '行の状態をModifiedにする
        dataTable2.Clear()
        dataTable2.ImportRow(dataRow)
        Console.WriteLine("コピー元 : " + Me.GetRowState(dataTable.Rows(0)))
        Console.WriteLine("コピー先 : " + Me.GetRowState(dataTable2.Rows(0)))
        '=> コピー元 : DataRowState.Modified
        '=> コピー先 : DataRowState.Modified
    End Sub

    '行の状態を取得
    Function GetRowState(dataRow As DataRow) As String
        Select Case dataRow.RowState
            Case DataRowState.Added
                Return "DataRowState.Added"
            Case DataRowState.Modified
                Return "DataRowState.Modified"
            Case DataRowState.Deleted
                Return "DataRowState.Deleted"
            Case DataRowState.Detached
                Return "DataRowState.Detached"
            Case DataRowState.Unchanged
                Return "DataRowState.Unchanged"
            Case Else
                Return "Unknown"
        End Select
    End Function
End Module
```

以上です。
