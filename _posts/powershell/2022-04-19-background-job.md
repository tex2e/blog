---
layout:        post
title:         "[PowerShell] 処理をバックグラウンドで実行する (Start-Job)"
date:          2022-04-19
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

PowerShell で処理をバックグラウンドで実行したい場合は、Start-Job とスクリプトブロックを使用します。

#### Start-Job (ジョブの開始)
まず、Start-Job を実行すると、ジョブが作成されます。
以下の例では、10秒後に「[+] Finished (N)」という文字列を返すジョブを作成しています。
実行すると、PSRemotingJobオブジェクトが返り値として取得できるので、後で参照できるようにジョブを変数に格納しておきます。
現在のジョブ一覧は Get-Job で確認できますが、-State Running オプションを加えると現在実行中のジョブのみ表示されます。
```ps1
PS> $job1 = Start-Job { sleep 10; "[+] Finished (1)" }
PS> $job2 = Start-Job { sleep 10; "[+] Finished (2)" }

PS> Get-Job -State Running
Id     Name        PSJobTypeName   State      HasMoreData   Location    Command
--     ----        -------------   -----      -----------   --------    -------
9      Job9        BackgroundJob   Running    True          localhost    sleep 10; "[+] Finish..."
11     Job11       BackgroundJob   Running    True          localhost    sleep 10; "[+] Finish..."
```

#### Get-Job (ジョブ一覧の取得)
Get-Job は現在のジョブの一覧を確認するためのコマンドです。
オプション -Id を使用することで、指定した Id のジョブのみを表示することができます。
```ps1
PS> Get-Job -Id $job1.Id
Id     Name        PSJobTypeName   State      HasMoreData   Location    Command
--     ----        -------------   -----      -----------   --------    -------
9      Job9        BackgroundJob   Completed  True          localhost    sleep 10; "[+] Finish..."
```

#### Receive-Job (ジョブの処理結果の取得)
Receive-Job はジョブの処理結果を取得するためのコマンドです。
-Wait オプションを加えることで、対象のジョブが終了するまで待機します。
```ps1
PS> Receive-Job -Id $job1.Id,$job2.Id -Wait
[+] Finished (1)
[+] Finished (2)
```
PowerShell v3 では、Receive-Job に -AutoRemoveJob というオプションを加えることで、ジョブの結果を取得した後にジョブの削除もまとめて行います。
```ps1
PS> Receive-Job -Id $job1.Id,$job2.Id -Wait -AutoRemoveJob
[+] Finished (1)
[+] Finished (2)
PS> (Get-Job).Count
0
```

#### Remove-Job (ジョブの削除)
ジョブは完了しても、ジョブの一覧には残ります。
Receive-Job でジョブの処理結果を取得したら、Remove-Job で役割を終えたジョブを削除します。
```ps1
PS> Remove-Job -Id $job1.Id,$job2.Id
PS> Get-Job -State Completed | Remove-Job

# ジョブが削除されたか確認する
PS> Get-Job
```

#### その他
ジョブに関するコマンドレットは他にもあります。
- **Stop-Job** : ジョブを停止する
- **Suspend-Job** : ジョブを中断する
- **Resume-Job** : ジョブを再開する
- **Wait-Job** : ジョブの終了を待つ

以上です。

#### 参考文献
- 牟田口 大介 (著)『【改訂新版】 Windows PowerShell ポケットリファレンス』, 技術評論社, 2013/2/23
