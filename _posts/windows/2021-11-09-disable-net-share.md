---
layout:        post
title:         "Windowsでユーザ端末間のファイル共有を禁止する"
date:          2021-11-09
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsで管理共有を無効化して「このフォルダーを共有する」の機能を無効化する方法について説明します。

### ADのグループポリシーを変更する方法

1. 「グループポリシー管理」を起動 (gpmc.msc)＞対象ドメイン＞「Default Domain Policy」を右クリック＞編集
2. コンピュータの構成＞基本設定＞Windows設定＞レジストリ＞新規作成＞レジストリ項目
    - ハイブ : HKEY_LOCAL_MACHINE
    - キー : SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
    - 値 : AutoShareWks
    - 種類 : REG_DWORD
    - データ : 0 (管理共有を0で無効化、1で有効化)
3. OK後に「再起動」または「gpupdate.exe /force」
4. 「net share」コマンドで「Default share」や「Remote Admin」が消えて管理共有が無効になったことを確認する。

### レジストリエディタを編集する方法

1. regedit.exe を起動する
2. 「HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters」に以下の項目を新規追加する
    - 値 : AutoShareWks
    - 種類 : REG_DWORD
    - データ : 0 (管理共有を0で無効化、1で有効化)
3. 再起動してから「net share」コマンドで「Default share」や「Remote Admin」が消えて管理共有が無効になったことを確認する。

設定前：
```cmd
> net share

共有名       リソース                            注釈

-------------------------------------------------------------------------------
IPC$                                         Remote IPC
C$           C:\                             Default share
ADMIN$       C:\Windows                      Remote Admin
```

設定後：
```cmd
> net share

共有名       リソース                            注釈

-------------------------------------------------------------------------------
IPC$                                         Remote IPC
コマンドは正常に終了しました。
```

以上が、管理共有機能を無効化する手順でした。

### Firewallで管理共有に接続できるIPを制限する

システム運用上、ファイル共有が必要な場合は、Windows Firewallで接続元IPを制限します。
Default Domain Policyを編集する場合は次の手順です。
1. コンピュータの構成＞ポリシー＞Windowsの設定＞セキュリティの設定＞セキュリティが強化されたWindowsファイアウォール＞受信の規則
    - 全般：接続をブロックする
    - プロトコルおよびポート：ローカルポート：137,138/udp(NetBios)、39,445/TCP(SMB)
    - スコープ：リモートIPアドレス：192.168.56.0/24  (接続先IPを限定する)
2. 各PCで「gpupdate.exe /force」もしくは自動更新されるまで待つ


#### 参考文献
- [\[Windows\] 隠し共有と管理共有 - りゃうけのブログ。](http://www.hirno.net/~wind/blog/2016/02/windows-1.html)
