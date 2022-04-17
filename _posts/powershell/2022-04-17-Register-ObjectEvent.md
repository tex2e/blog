---
layout:        post
title:         "PowerShellでファイルの更新を監視する"
menutitle:     "PowerShellでファイルの更新を監視する (Get-Content -Wait, FileSystemWatcher)"
date:          2022-04-17
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

PowerShellでファイルの更新を監視するには、Get-Content で -Wait オプションを使う方法と、FileSystemWatcher を使う方法の2通りがあります。
フォルダ下の全てを検知したい場合や、変更だけでなく作成や削除も検知したい場合は .NET の FileSystemWatcher クラスを使用します。

#### 1つのファイルの変更だけを監視する
ファイルの内容の変更 (Changed) だけを監視したい場合は、Get-Content のオプション -Wait を使うことで、新しい内容のチェックをすることができます。
```ps1
Get-Content C:\test\hoge\fuga.txt -Wait | foreach { "$(Get-Date), Changed" }
```

#### ファイルの作成・変更・削除を監視する
FileSystemWatcher には、監視するディレクトリとファイル名、サブディレクトリも監視するかの有無などを設定し、イベントリスナー (イベントハンドラ) をイベントに登録することで、変更を検知することができます。

System.IO.FileSystemWatcher に設定するパラメータは、以下のものがあります。
- Path : 監視するディレクトリのパス
- Filter : 監視するファイルのパターン
- IncludeSubdirectories : 指定したパスのサブディレクトリを監視する
- EnableRaisingEvents : コンポーネントが有効かどうかを示す値を取得する

イベントリスナーの登録 (C# の `オブジェクト.イベント += 関数` に相当する処理) は、Register-ObjectEvent で行います。

```ps1
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:\test\"  # 監視するディレクトリ
$watcher.Filter = "*.txt"  # ファイル名
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents   = $true

# イベントリスナー
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    Write-Host "$(Get-Date), $changeType, $path"
}

# イベントの登録
Register-ObjectEvent $watcher "Created" -Action $action
Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Deleted" -Action $action
Register-ObjectEvent $watcher "Renamed" -Action $action

while ($true) { sleep 1 }
```

上記の PowerShell を実行すると、まず、Register-ObjectEvent の実行結果 (PSRemotingJobオブジェクト) が出力されます。
さらに、監視対象のディレクトリ下で txt ファイルを作成したり更新したりすると、イベントリスナーの Write-Host の出力結果が表示されます。

```console
Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      329a73d6-dee...                 NotStarted    False                                ...
2      69a95e90-24e...                 NotStarted    False                                ...
3      ac2372af-bfb...                 NotStarted    False                                ...
4      dd866562-974...                 NotStarted    False                                ...

03/26/2022 18:24:06, Created, C:\test\hoge\新規 テキスト ドキュメント.txt
03/26/2022 18:24:10, Renamed, C:\test\hoge\fuga.txt
03/26/2022 18:24:19, Changed, C:\test\hoge\fuga.txt
03/26/2022 18:24:42, Changed, C:\test\hoge\fuga.txt
03/26/2022 18:24:50, Deleted, C:\test\hoge\fuga.txt
```

なお、イベントに登録するとジョブが実行され続けるので、止めるには Remove-Job でジョブを削除します。

```ps1
PS> Get-Job -State Running  # 実行中のジョブ一覧を確認する
PS> Remove-Job -Id 1 -Force
PS> Remove-Job -Id 2 -Force
PS> Remove-Job -Id 3 -Force
PS> Remove-Job -Id 4 -Force
```



以上です。

#### 参考文献
- [PowerShellでファイルの作成や編集、削除の検知・モニタリングを行う \| 俺的備忘録 〜なんかいろいろ〜](https://orebibou.com/ja/home/201702/20170226_001/)
- [FileSystemWatcher クラス (System.IO) \| Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.io.filesystemwatcher?view=net-6.0)
- [Register-EngineEvent (Microsoft.PowerShell.Utility) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/register-engineevent?view=powershell-7.2)
