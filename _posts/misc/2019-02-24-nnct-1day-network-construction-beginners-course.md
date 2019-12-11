---
layout:        post
title:         "ネットワーク構築入門講座の参加メモ"
date:          2019-02-24
category:      Misc
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

ネットワーク構築入門講座の内容についての雑メモ。
学校内部でホワイトハッカー育成事業として情報科4・5年くらいを対象にした講座。

- CISCO Catalystのコマンド集などが書かれたプリントが配布された
- L2スイッチとL3スイッチが、各グループと講師の先生のところにある（計4つのルータがある状況）
- 全部の機材を合わせたら1000万円近くになるらしい
- 持ち込みのノートパソコンとスイッチのコンソールを接続して設定を行う

Ubuntuを持ち歩いている私はコンソール接続は次のコマンドで接続してプロンプトに入った（コンソールはEthernetポートで、シリアルケーブル + それをUSB type Aに変換するUSBシリアルケーブルの2つを使って接続している）。

```
sudo screen /dev/ttyUSB0
```

sudo を忘れると接続できないので注意。screenコマンドは事前にインストールしておいた。
この時点で無線LANからは切断しておく（ping したときに学内LANにパケットが飛ぶのを防ぐため）。

- 現状のネットワーク構成を確認した後に、それぞれのスイッチを初期化
- 初期化と再起動

    ```
    CL2# erase startup-config      # 設定の削除
    CL2# delete flash:vlan.dat     # vlan情報の削除
    CL2# reload                    # 再起動
    ```

    L2/L3スイッチの両方で初期化と再起動。爆音を立てながらしばらくすると再起動が完了する。

- モード切り替え

    「ユーザEXECモード」と「特権EXECモード」

    ```
    CL2> enable
    Password:
    CL2# disable
    CL2>
    ```

    「特権EXECモード」と「グローバルコンフィグレーションモード」

    ```
    CL2# configure terminal
    CL2(config)# exit
    CL2#
    ```

    コマンド名は一意に定まるなら省略可能

    - enable => en
    - configure terminal => conf term

    グローバルコンフィグレーションモードで特権EXECモードのコマンドを実行したい場合はコマンドの先頭に `do` を付ける。

    ```
    CL2(config)# do show conf
    ```

- 名前とパスワードの設定

    ```
    Switch(config)# hostname CL2          # スイッチの名前
    CL2(config)# enable password foobar   # 特権EXECモードのパスワード
    CL2(config)# line console 0           # ラインコンフィグモード
    CL2(config-line)# password foobar     # コンソールログイン時のパスワード
    CL2(config-line)# login               # コンソールからのログインを有効
    CL2(config-line)# end
    CL2#write memory                      # 設定の保存
    ```

    パスワードの暗号化

    ```
    CL2(config)# enable password foobar   # パスワードを平文で保存
    CL2(config)# enable secret foobar     # パスワードをハッシュで保存
    ```

- 設定の確認

    ```
    CL2# show configuration
    ```

    `write memory` で設定を保存しなくても設定変更は反映される。
    現在反映されている設定を見るには `show running-config` というコマンドを打つ。

- MACアドレステーブルの表示

    ```
    CL2# show mac address-table
    ```

    指定したMACアドレスをブロックすることも可能

    ```
    CL2(config)# mac address-table static <macaddr> vlan 10 drop
    ```

- ポートにIPを割り当てる（Layer 3）

    ```
    CL3(config)# interface gigabitEthernet 1/0/1  # IFモード
    CL3(config-if)# no switchport                 # L3モード
    CL3(config-if)# ip address IPアドレス サブネットマスク
    CL3(config-if)# no shutdown                   # ポート有効化
    CL3(config-if)# end
    CL3# write memory
    ```

    interfaceに対して設定を取り消すときは no ではなく `default` を使う

    ```
    CL3(config)# default interface gigabitEthernet 1/0/1
    ```

    - Example:

        ```
        CL3(config)# interface gigabitEthernet 1/0/1
        CL3(config-if)# no switchport
        CL3(config-if)# ip address 192.168.10.1 255.255.255.0
        CL3(config-if)# end
        CL3(config)# interface gigabitEthernet 1/0/2
        CL3(config-if)# no switchport
        CL3(config-if)# ip address 192.168.15.1 255.255.255.0
        CL3(config-if)# end
        ```

- ポートの設定確認

    ```
    CL3# show interfaces gigabitEthernet 1/0/1
    ```

- VLANの作り方

    ```
    CL3(config)# vlan 10   # VLAN番号を付ける
    CL3(config-vlan)# end
    CL3# write memory
    CL3# show vlan brief   # VLANの確認
    ```

    他の設定方法:

    ```
    CL3(config)# vlan 10,15   # カンマ区切り
    CL3(config)# vlan 10-15   # ハイフンで連続（10,11,12,13,14,15）
    CL3(config)# no vlan 10   # VLANの削除
    ```

- VLANにIPを割り当てる

    ```
    CL3(config)# interface vlan 10
    CL3(config-if)# ip address IPアドレス サブネットマスク
    CL3(config-if)# no shutdown
    CL3(config-if)# end
    CL3# write memory
    ```

- VLAN間のIPルーティングを有効にする

    ```
    CL3# ip routing      # 有効化
    CL3# no ip routing   # 無効化
    ```

- ポートにVLANを割り当てる

    ```
    CL3(config)# interface gigabitEthernet 1/0/1
    CL3(config-if)# switchport access vlan 10  # ポートにVLANを設定
    CL3(config-if)# no shutdown                # ポートを有効化
    CL3(config-if)# end
    CL3# write memory
    CL3# show vlan brief
    ```

    複数のポートを指定するときは `interface range` を使う

    ```
    CL3(config)# interface range gigabitEthernet 1/0/1-24
    CL3(config-if)# switchport access vlan 10
    CL3(config)# interface range gigabitEthernet 1/0/25-48
    CL3(config-if)# switchport access vlan 15
    ```

- ポートをTrunkポートにする（タグVLAN）

    ```
    CL3(config)# interface gigabitEthernet 1/0/1
    CL3(config-if)# switchport trunk encapsulation dot1q # 使用する規格
    CL3(config-if)# switchport mode trunk  # Trunkモード
    CL3(config-if)# no shutdown
    CL3(config-if)# end
    CL3# write memory
    CL3# show interfaces trunk
    ```

    特定のVLANタグだけを流すことも可能

    ```
    CL3(config-if)# switchport trunk allowed <vlan> # 特定のVLANだけ流す
    CL3(config-if)# switchport trunk allowed all    # 全部許可
    ```

- 静的ルーティング

    ```
    CL3# conf term
    CL3(config)# ip route 宛先IP 宛先MASK ネクストホップ
    CL3(config)# end
    CL3# write memory
    ```

    ルーティングを消すときは `no ip route ...` と書く

    - 静的ルーティングの例:

        アドレス192.168.10.0/24にパケットを送るにはアドレス192.168.99.2のルータにパケットを送る場合

        ```
        CL3(config)# ip route 192.168.10.0 255.255.255.0 192.168.99.2
        ```

- 動的ルーティング（RIP）

    ```
    CL3# conf term
    CL3(config)# router rip
    CL3(config-router)# network 192.168.10.0  # 配下のネットワーク1
    CL3(config-router)# network 192.168.15.0  # 配下のネットワーク2

    CL3# show ip route
    〜省略〜
    R  192.168.10.9/24 [120/1] via 192.168.99.2, 00:00:04, ether1/0/48
    C  192.168.4.0/24 is directly connected, Vlan4
    C  192.168.99.0/24 is directly connected, ether1/0/48
    R  192.168.20.9/24 [120/2] via 192.168.99.2, 00:00:05, ether1/0/48
    ```

    - `show ip route`の読み方は、RはRIP（Routing Information Protocol）、OはOSPF（Open Shortest Path First）、Cは直接接続（Connected）
    - \[**120**/2] は AD値（Administrative Distance）=~ 信頼度（0になるほど信頼度が高い）
    - \[120/**2**] はメトリック（ここではホップ数が2）
    - 信頼度の高い順は、直接接続 > 静的ルーティング > OSPF > RIP

    デフォルトルータだけを静的に決めて、その他は動的ルーティングにするのがベストプラクティス

    - Example:

        宛先IPアドレスがルーティングテーブルにないときは 192.168.99.2 に送る場合

        ```
        CL3(config)# ip route 0.0.0.0 0.0.0.0 192.168.99.2
        ```

- RIPの情報

    各種タイマーの情報や、RIPを流しているインターフェースの情報が確認できる

    ```
    CL3# show ip protocols
    ```

- RIPを流さない

    - 無駄なアップデートの抑制
    - 配下のネットワークの情報を送らないことでセキュリティの向上

    ```
    CL3(config)# router rip
    CL3(config-router)# passive-interface vlan 15  # RIPを流さない
    CL3(config-router)# end
    CL3# write memory
    CL3# show ip protocols    # vlan15が除外されている
    ```

- アクセスリスト

    アクセスリストの作成は `access-list 番号 {permit|deny} プロトコル 送信元IP 送信元MASK`

    ```
    CL3(config)# access-list 100 permit tcp any any
    CL3(config)# end
    CL3# write memory
    CL3# show access-lists
    ```

    アクセスリストの適用

    ```
    CL3(config)# interface vlan 10
    CL3(config-if)# ip access-group 100 out  # 送信時にルール適用
    CL3(config-if)# end
    CL3# write memory
    ```

- ポートのミラー

    ポートAをミラーしてポートBにパケットを流して、ポートBをパソコンに接続すればルーティングプロトコル（この講座ではRIPv1）をパケットキャプチャすることができる。デバッグ時などに使える

    - 次の設定はポート24をポート22にミラーする方法：

```
CL3(config)# monitor session 1 source interface gigabitEthernet 1/0/24
CL3(config)# monitor session 1 destination interface gigabitEthernet 1/0/22
```

- Ethernetを抜き差ししたときにスイッチのLEDで接続できたか確認する
  - 消灯：未接続
  - オレンジ：接続中
  - グリーン：接続完了

- ARPスプーフィング（ARPポイズニング）の話とかもあるとホワイトハッカー育成事業の面を出せたような気がする... けど全体的に勉強になったので個人的にはよかった


### 参考文献

- [Ciscoルータ/Catalystコマンド一覧 - ネットワーク入門サイト](https://beginners-network.com/cisco-catalyst-command/)
