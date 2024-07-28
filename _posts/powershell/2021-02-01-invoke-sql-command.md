---
layout:        post
title:         "[PowerShell] SQLコマンドを実行する"
date:          2021-01-31
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

PowerShellからSQL Serverに接続して、SQLコマンドを発行し、その結果を表形式で表示する方法について説明します。

まずは、以下を Invoke-SqlCommand.ps1 という名前で保存します。

```powershell
param(
    [string] $DataSource = ".\SQLEXPRESS",
    [string] $Database = "DBName",
    [Parameter(Mandatory = $true)]
    [string[]] $SqlCommand,
    [int] $Timeout = 60,
    [PSCredential] $Credential
)

Set-StrictMode -Version 3

## デフォルトはWindows認証を使用する
$authentication = "Integrated Security=SSPI;"

## 認証情報が渡されたときは、SQL認証を使用する
if ($credential) {
    $credential = Get-Credential $credential
    $plainCred = $credential.GetNetworkCredential()
    $authentication =
        ("uid={0};pwd={1};" -f $plainCred.Username,$plainCred.Password)
}

## 接続文字列の作成
$connectionString = "Provider=sqloledb; " +
                    "Data Source=$dataSource; " +
                    "Initial Catalog=$database; " +
                    "$authentication; "

## データベースへの接続
$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
$connection.Open()

foreach ($commandString in $sqlCommand) {
    $command = New-Object Data.OleDb.OleDbCommand $commandString,$connection
    $command.CommandTimeout = $timeout

    ## 実行結果の取得
    $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    [void] $adapter.Fill($dataSet)

    ## クエリから全ての行を返す
    $dataSet.Tables | Select-Object -Expand Rows
}

$connection.Close()
```

処理の流れとしては、以下の通りです。

1. 引数でデータソース、データベース名、SQLコマンドを受け取る
2. 引数で認証情報が渡されていればSQL認証、なければWindows認証でSQL Serverに接続する
3. SQLの実行結果をDataSetに格納する（詳細は .NET ドキュメントを参照）
4. DataSetを返す

Invoke-SqlCommand.ps1 を使って実際に SQL Server に接続する例は次のようになります。

```powershell
$loginUser = 'ログインユーザ名'
$loginPass = ConvertTo-SecureString 'ログインパスワード' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($loginUser, $loginPass)

$server = 'ホスト名\SQLEXPRESS'
$database = 'DB名'
$sql = 'select * from [User]'

$res = (.\Invoke-SqlCommand.ps1 $server $database $sql -Cred $cred)

$res | Format-Table
```

認証情報の作成は System.Management.Automation.PSCredential を使って作成します。
パスワードはプロンプトなどでユーザに入力させるのが最も安全ですが、自動化したいときは ConvertTo-SecureString を使って平文で保存するしかないと思います（要確認）。
最後の出力で DataSet を Format-Table で表形式にしてから表示すると出力は以下のようになります。

```
name     age
----     ---
Alice     23
Bob       45
```

プログラムとして、特定の行のある列の値だけを抽出したいときは、次のようになります。

```powershell
$res[0].age
```

以上です。


### 参考文献

- Windows PowerShell Cookbook: The Complete Guide to Scripting Microsoft's Command Shell (O'Reilly)
