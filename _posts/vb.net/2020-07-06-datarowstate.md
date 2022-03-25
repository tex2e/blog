---
layout:        post
title:         "行編集によるDataRowStateの変化"
date:          2020-07-06
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


DataTableの行（DataRow）を編集したときに DataRowState がどのように変化していくかについてのまとめです。

### DataRowState

DataRowState (Enum) の状態には以下のものがあります。

| 状態名 | 値 | 説明 |
|---|---|---|
| Added | 4 | DataTableに追加した後で、AcceptChanges() する前の状態
| Deleted | 8 | DataTableから削除した後の状態
| Detached | 1 | 行がDataTableに含まれていない状態（新規行作成時やDataTableから削除時）
| Modified | 16 | 行を変更した後で、AcceptChanges() する前の状態
| Unchanged | 2 | AcceptChanges() した後の状態


### 動作確認

テーブル (DataTable) の行を編集したときの、行の状態 (DataRowState) がどのように変化するか確認します。

実行コード (VB.NET)

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
        dataTable.AcceptChanges() '編集を確定させる

        '--- ここから開始 ---

        '行の追加
        dataRow = dataTable.NewRow()
        dataRow("商品名") = "ぶどう"
        dataRow("値段") = 1200D
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Detached (DataTableと繋がっていない)
        dataTable.Rows.Add(dataRow)
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Added (DataTableに追加された)

        '修正確定
        dataTable.AcceptChanges()
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Unchanged (変更なし)

        Console.WriteLine("--- 修正確定後 ---")
        Me.ShowTable(dataTable)
        '=>  --- 修正確定後 ---
        '=>    商品名 : りんご
        '=>    値段 : 800
        '=>    商品名 : みかん
        '=>    値段 : 200
        '=>    商品名 : ぶどう
        '=>    値段 : 1200
        
        '行の修正
        dataRow("値段") = 1400D
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Modified (変更あり)

        Console.WriteLine("--- 行の修正後 ---")
        Me.ShowTable(dataTable)
        '=> --- 行の修正後 ---
        '=>   商品名 : りんご
        '=>   値段 : 800
        '=>   商品名 : みかん
        '=>   値段 : 200
        '=>   商品名 : ぶどう
        '=>   値段 : 1400

        '修正取消
        dataRow.RejectChanges()
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Unchanged (変更なし)

        Console.WriteLine("--- 修正取消後 ---")
        Me.ShowTable(dataTable)
        '=> --- 修正取消後 ---
        '=>   商品名 : りんご
        '=>   値段 : 800
        '=>   商品名 : みかん
        '=>   値段 : 200
        '=>   商品名 : ぶどう
        '=>   値段 : 1200

        '行の削除
        dataTable.Rows.Remove(dataRow)
        Console.WriteLine(Me.GetRowState(dataRow)) '=> Detached (DataTableと繋がっていない状態)

        Console.WriteLine("--- 行の削除後 ---")
        Me.ShowTable(dataTable)
        '=> --- 行の削除後 ---
        '=>   商品名 : りんご
        '=>   値段 : 800
        '=>   商品名 : みかん
        '=>   値段 : 200
    End Sub

    'テーブルの内容を表示
    Sub ShowTable(ByRef dataTable As DataTable)
        For Each dataRow As DataRow In dataTable.Rows
            For Each col As DataColumn In dataTable.Columns
                Console.WriteLine("  " & col.ColumnName & " : " & dataRow(col).ToString)
            Next
        Next
        Console.WriteLine()
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

実行結果

```output
DataRowState.Detached
DataRowState.Added
DataRowState.Unchanged
--- 修正確定後 ---
  商品名 : りんご
  値段 : 800
  商品名 : みかん
  値段 : 200
  商品名 : ぶどう
  値段 : 1200

DataRowState.Modified
--- 行の修正後 ---
  商品名 : りんご
  値段 : 800
  商品名 : みかん
  値段 : 200
  商品名 : ぶどう
  値段 : 1400

DataRowState.Unchanged
--- 修正取消後 ---
  商品名 : りんご
  値段 : 800
  商品名 : みかん
  値段 : 200
  商品名 : ぶどう
  値段 : 1200

DataRowState.Detached
--- 行の削除後 ---
  商品名 : りんご
  値段 : 800
  商品名 : みかん
  値段 : 200
```

以上です。
