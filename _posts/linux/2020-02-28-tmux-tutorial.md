---
layout:        post
title:         "tmuxの使い方"
date:          2020-02-28
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

ターミナルマルチプレクサ tmux を使うと、1つのssh接続で複数のシェルを立ち上げられる。
さらに、ssh中にネットワークが切断されても、プロセスはサーバ側で動き続けるので、再開することができる。


### tmux 使用時にネットワークを切断してみる

sshで接続する。

```bash
$ ssh local1
```

tmuxをインストールする。

```bash
$ sudo yum install tmux
```

tmuxを起動する。

```bash
$ tmux
```

1秒ごとにカウントアップする処理を実行する。

```bash
$ c=0; while true; do c=$(expr $c + 1); echo $c; sleep 1; done
1
2
3
...
```

突然接続を切るために、端末のウィンドウを閉じる。
「このウィンドウで実行中のプロセスを終了しますか」と警告されるが、そのまま終了する。

再度sshで接続する。

```bash
$ ssh local1
```

起動中のプロセスを確認する。1秒ごとにカウントアップする処理が残っていることがわかる。

```bash
$ px auxwf
...
root      3887  0.0  0.0  22348  1800 ?        Ss   19:07   0:00 tmux
root      3888  0.0  0.1 115440  2036 pts/1    Ss   19:07   0:00  \_ -bash
root      4258  0.0  0.0 107952   356 pts/1    S+   19:10   0:00      \_ sleep 1
```

作業中の全てのウィンドウに戻る。

```bash
$ tmux attach
...
214
215
216
```

ネットワークが切断されてもプロセスは動き続けていることが確認できる。

<br>
### コマンド上でのセッション操作

| 操作 | コマンド
|---|---|
| **セッションの作成** | `tmux`, `tmux new`
| 名前を付けて作成 | `tmux new -s mysession`
| セッションの削除 | `tmux kill-session -t mysession`
| 現在のセッション以外を削除 | `tmux kill-session -a`
| **セッションの一覧表示** | `tmux ls`
| **セッションを再開** | `tmux attach`、`tmux a`
| 名前指定でセッションを再開 | `tmux attach -t mysession`、`tmux a -t mysession`

### セッション操作 (Sessions)

| 操作 | キーボード |
|---|---|
| セッションの一覧表示と選択 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>s</kbd> (Select)
| **セッションから離脱** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>d</kbd> (Detach)
| セッション名の変更 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>$</kbd>

### ウィンドウ操作 (Windows)

| 操作 | キーボード |
|---|---|
| **ウィンドウの作成** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>c</kbd> (Create)
| **ウィンドウの切り替え** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>n</kbd> (Next)、<kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>p</kbd> (Previous)
| ウィンドウの一覧選択 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>w</kbd> (Window)
| ウィンドウの移動 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>0-9</kbd>
| 以前のウィンドウに移動 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>l</kbd> (Latest)
| ウィンドウ名の変更 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>,</kbd>

### ペイン操作 (Panes)

| 操作 | キーボード |
|---|---|
| **左右分割** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>%</kbd>
| **上下分割** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>"</kbd>
| **ペインを閉じる** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>X</kbd> (Exit)
| 次のペインに移動 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>o</kbd>
| **ペイン間の移動** | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>矢印</kbd>
| 以前のペインに移動 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>;</kbd>
| レイアウトの変更 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>Space</kbd>
| ペインを移動 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>{</kbd>、<kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>}</kbd>
| ペインの最大化/元に戻す | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>z</kbd> (Zoom)
| ペインをウィンドウ化 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>!</kbd>
| ペイン番号の表示 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>q</kbd>
| ペイン番号の表示と選択 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>q</kbd>, <kbd>0-9</kbd>

### コピーモード (Copy Mode)

`setw -g mode-keys vi` で vi モードの操作にする。

| 操作 | キーボード |
|---|---|
| コピーモード開始 | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>[</kbd>
| コピーモード終了 | <kbd>q</kbd>
| コピー開始位置決定 | <kbd>Space</kbd>
| コピー開始位置決定 | <kbd>Enter</kbd>
| カーソル移動 | <kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd>
| 貼り付け | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>]</kbd>

### その他 (Misc)

| 操作 | キーボード |
|---|---|
| コマンドモードに切り替え | <kbd>Ctrl</kbd>+<kbd>b</kbd>, <kbd>:</kbd>
| 全てのセッションへの設定 | `: set -g OPTION`
| 全てのウィンドウへの設定 | `: setw -g OPTION`

### 設定ファイル

設定ファイルは ~/.tmux.conf に配置する。
編集してすぐに反映させたいときは `tmux source ~/.tmux.conf` を実行する。



### 参考文献

- [Tmux Cheat Sheet & Quick Reference](https://tmuxcheatsheet.com/)
- [tmuxチートシート - Qiita](https://qiita.com/nmrmsys/items/03f97f5eabec18a3a18b)
- [達人に学ぶ.tmux.confの基本設定 - Qiita](https://qiita.com/succi0303/items/cb396704493476373edf)
