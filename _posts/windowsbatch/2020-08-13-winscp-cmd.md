---
layout:        post
title:         "コマンドからWinSCPでファイルダウンロード"
date:          2020-08-13
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

WindowsのコマンドラインでWinSCP.exeを実行する方法についての備忘録です。
コマンドを使うことで、バッチファイルでWinSCPを介したファイルのアップロード＆ダウンロードが自動化できるので便利です。

以下は、WinSCPでファイルダウンロードする例です。

```cmd
> C:\path\to\WinSCP.exe /console /command ^
  "option batch on" ^
  "option confirm off" ^
  "open ユーザ名@ホスト名" ^
  "get /path/to/*.dll C:\tmp\" ^
  "close" ^
  "exit"
```

コマンドラインの説明：

- `C:\path\to\WinSCP.exe` : WinSCP.exe を絶対パスから実行します。実行パスは各環境に合わせてください。
- `/console` : コンソールモードでWinSCPを起動します。
- `/command` : WinSCP起動直後に実行するコマンドを指定できます。

WinSCPのコマンドの説明：

- `option batch on` : 再接続などの確認ダイアログで自動的に「いいえ」を選択します。
- `option confirm off` : ファイルの上書き時に確認ダイアログを無効にします。
- `open` : 指定したホストに接続します。書き方はsshと基本的に同じで `ユーザ名@ホスト名` と書きます。パスワードを平文で保存しても良い場合は `ユーザ名:パスワード@ホスト名` と書きます。ローカルのLANであれば、ホスト名の代わりにIPアドレスを指定します。
- `get 取得ファイル 保存先` : ファイルをダウンロードします。ワイルドカードによるファイルの選択 `*.txt` も可能です。
- `close` : セッションを閉じます (openと対になるコマンド)。
- `exit` : コンソールモードを終了します (デバッグ時は省略したりします)。

ダウンロードは `get` コマンドですが、アップロードは `put` コマンドを使います。
書き方は `put ファイル アップロード先` です。


社内のテストサーバーから、いつも決まったデータを取得したいとき・アップロードしたいときとかはローカルにパスワードを平文で保存していても大きな問題はないので、`open ユーザ名:パスワード@アドレス` と書くことでパスワード入力する手間が省けて、より自動化がはかどると思います。

以上です。




### 参考

- [コマンドリファレンス - WinSCP Wiki - WinSCP - OSDN](https://osdn.net/projects/winscp/wiki/script_commands#option)
- [Scripting and Task Automation :: WinSCP](https://winscp.net/eng/docs/scripting)
