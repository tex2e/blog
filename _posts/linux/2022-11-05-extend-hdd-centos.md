---
layout:        post
title:         "CentOS8でハードディスクを拡張する手順"
date:          2022-11-05
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

CentOS8でのハードディスク(HDD)拡張は以下の手順で行います。

1. 仮想ハードディスクを拡張する
2. **fdisk**で増設したディスクにラベルを付けて**ボリューム**を作成する
3. **pvcreate**でボリュームから**物理ボリューム (PV)**を作成する
4. **vgextend**で物理ボリュームを**ボリュームグループ (VG)**に追加する
5. **lvextend**でボリュームグループの空き領域を**論理ボリューム (LV)**に割り当てる
6. **xfs_growfs**で論理ボリュームのサイズを**ファイルシステム**に反映する

### 仮想ハードディスクの拡張
仮想マシンでCentOSを起動している場合は、ハードディスクのサイズを変更することができます。
VMware vSphereの場合が、インスタンス起動画面から「設定の編集 > 仮想ハードウェア > ハードディスク1」を選択し、サイズを必要な大きさに増やします。
以下の例では 80GB を 300GB に拡張します。

（補足）VMware vSphereではスナップショットが存在する状態でハードディスクの拡張はできません。スナップショットを削除するかクローンを作成してから拡張する必要があります。

### dfでディスク使用率の確認
CentOSサーバにSSHログインし、df コマンドで現在のディスク使用率を確認します。
/dev/mapper/rl-root と /dev/mapper/rl-home の合計が 80 GBの状態です。

```bash
~]# df -h
ファイルシステム                        サイズ  使用  残り 使用% マウント位置
devtmpfs                              1.8G     0  1.8G    0% /dev
tmpfs                                 1.8G   12K  1.8G    1% /dev/shm
tmpfs                                 1.8G  8.7M  1.8G    1% /run
tmpfs                                 1.8G     0  1.8G    0% /sys/fs/cgroup
/dev/mapper/rl-root                    52G   14G   38G   27% /
/dev/mapper/rl-home                    26G  9.2G   16G   37% /home
/dev/sda2                            1014M  250M  765M   25% /boot
/dev/sda1                             599M  5.7M  594M    1% /boot/efi
tmpfs                                 365M     0  365M    0% /run/user/10500
tmpfs                                 365M     0  365M    0% /run/user/0
```

### fdiskでボリュームラベルの確認
fdisk -l コマンドでディスクのボリュームラベルを確認します。
以下の例では /dev/sda と /dev/sdb と /dev/sdc の3つがあります。
80GBから300GBに拡張したのは「ハードディスク1」で、/dev/sda が「サイズが合致していません」という警告が発生しています。
そのため /dev/sda を修正していきます。

```bash
~]# fdisk -l
ディスク /dev/sdb: 10 GiB, 10737418240 バイト, 20971520 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト

GPT PMBR のサイズが合致していません (167772159 != 629145599) が、w (書き込み) コマンドで修正されます。
ディスク /dev/sda: 300 GiB, 322122547200 バイト, 629145600 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: gpt
ディスク識別子: 18321E20-08E9-48D2-9B40-09D53BC5350C

デバイス   開始位置  終了位置    セクタ サイズ タイプ
/dev/sda1      2048   1230847   1228800   600M EFI システム
/dev/sda2   1230848   3327999   2097152     1G Linux ファイルシステム
/dev/sda3   3328000 167770111 164442112  78.4G Linux LVM


ディスク /dev/sdd: 10 GiB, 10737418240 バイト, 20971520 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト


ディスク /dev/sdc: 10 GiB, 10737418240 バイト, 20971520 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
```

### fdiskでボリュームを作成する

fdisk コマンドで /dev/sda を修正していきます。
以下を実行することし、対話型でコマンドを入力していくことで /dev/sda4 を作成します。

```bash
~]# fdisk /dev/sda

fdisk (util-linux 2.32.1) へようこそ。
ここで設定した内容は、書き込みコマンドを実行するまでメモリのみに保持されます。
書き込みコマンドを使用する際は、注意して実行してください。

GPT PMBR のサイズが合致していません (167772159 != 629145599) が、w (書き込み) コマンドで修正されます。

コマンド (m でヘルプ): p   <=======「p」を入力して現在の情報を出力

ディスク /dev/sda: 300 GiB, 322122547200 バイト, 629145600 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: gpt
ディスク識別子: 18321E20-08E9-48D2-9B40-09D53BC5350C

デバイス   開始位置  終了位置    セクタ サイズ タイプ
/dev/sda1      2048   1230847   1228800   600M EFI システム
/dev/sda2   1230848   3327999   2097152     1G Linux ファイルシステム
/dev/sda3   3328000 167770111 164442112  78.4G Linux LVM

コマンド (m でヘルプ): n   <=======「n」を入力して新規作成
パーティション番号 (4-128, 既定値 4):   <=======Enterを入力
最初のセクタ (167770112-629145566, 既定値 167770112):   <=======Enterを入力
最終セクタ, +セクタ番号 または +サイズ{K,M,G,T,P} (167770112-629145566, 既定値 629145566):   <=======Enterを入力

新しいパーティション 4 をタイプ Linux filesystem、サイズ 220 GiB で作成しました。

コマンド (m でヘルプ): t      <=======「t」を入力してタイプを指定
パーティション番号 (1-4, 既定値 4): 
パーティションのタイプ (L で利用可能なタイプを一覧表示します): L
 ...
 30 Linux extended boot            BC13C2FF-59E6-4262-A352-B275FD6F7172
 31 Linux LVM                      E6D6D379-F507-44C2-A23C-238F2A3DF928
 32 FreeBSD data                   516E7CB4-6ECF-11D6-8FF8-00022D09712B
 ...

パーティションのタイプ (L で利用可能なタイプを一覧表示します): 31

パーティションのタイプを 'Linux filesystem' から 'Linux LVM' に変更しました。

コマンド (m でヘルプ): w      <=======「w」を入力して書き込み
パーティション情報が変更されました。
ディスクを同期しています。
```

修正が成功すると、/dev/sda1 〜 /dev/sda4 の4つのデバイスになります。
先ほどは出力されていた「サイズが合致していません」の警告も表示されなくなります。

```bash
~]# fdisk -l
ディスク /dev/sdb: 10 GiB, 10737418240 バイト, 20971520 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト

ディスク /dev/sda: 300 GiB, 322122547200 バイト, 629145600 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: gpt
ディスク識別子: 18321E20-08E9-48D2-9B40-09D53BC5350C

デバイス    開始位置  終了位置    セクタ サイズ タイプ
/dev/sda1       2048   1230847   1228800   600M EFI システム
/dev/sda2    1230848   3327999   2097152     1G Linux ファイルシステム
/dev/sda3    3328000 167770111 164442112  78.4G Linux LVM
/dev/sda4  167770112 629145566 461375455   220G Linux LVM     <===増分の220GBが割り当てられる
```

### pvcreateでボリュームから「物理ボリューム (PV)」を作成する

次に物理ボリューム (PV) にボリューム (/dev/sda4) を追加します。
まず pvdisplay コマンドで、現在の物理ボリュームの状態を確認します。
この時点では 80GB の /dev/sda3 だけです。

```bash
~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               rl
  PV Size               78.41 GiB / not usable 2.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              20073
  Free PE               0
  Allocated PE          20073
  PV UUID               lRPagO-Bioj-TvAX-nEkT-Botl-87Ia-GVJBpD
```

新規作成した /dev/sda4 を物理ボリュームとして作成します。
作成後に再度 pvdisplay コマンドを実行すると /dev/sda4 が追加されます。

```bash
~]# pvcreate /dev/sda4
  Physical volume "/dev/sda4" successfully created.

~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               rl
  PV Size               78.41 GiB / not usable 2.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              20073
  Free PE               0
  Allocated PE          20073
  PV UUID               lRPagO-Bioj-TvAX-nEkT-Botl-87Ia-GVJBpD

  "/dev/sda4" is a new physical volume of "220.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sda4
  VG Name
  PV Size               220.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               MZzh0P-bYq8-c5Qg-RJds-m6xx-pSlv-dCu2Hi
```

### vgextendで物理ボリュームを「ボリュームグループ (VG)」に追加する
続いて、ボリュームグループを拡張します。
まずは、vgdisplay コマンドでボリュームグループの一覧を確認します。
今回は VG Size が 78.41 GiB (~= 80GB) のボリュームが拡張対象なので、「rl」というVGが修正対象になります。

```bash
~]# vgdisplay

  --- Volume group ---
  VG Name               rl
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               78.41 GiB
  PE Size               4.00 MiB
  Total PE              20073
  Alloc PE / Size       20073 / 78.41 GiB
  Free  PE / Size       0 / 0
  VG UUID               zGVDyL-iAfe-AV6X-lVY6-cceL-IdH0-Znhv6s
```

vgextend コマンドでVG名「rl」を指定し、物理ボリューム /dev/sda4 をグループに追加します。
実行後に再度 vgdisplay コマンドで確認すると、VG Size が増加することが確認できます（以下の例では 298.41 GiB と表示され、220GB拡張された）。

```bash
~]# vgextend rl /dev/sda4
  Volume group "rl" successfully extended

~]# vgdisplay
  --- Volume group ---
  VG Name               rl
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <298.41 GiB
  PE Size               4.00 MiB
  Total PE              76392
  Alloc PE / Size       20073 / 78.41 GiB
  Free  PE / Size       56319 / <220.00 GiB
  VG UUID               zGVDyL-iAfe-AV6X-lVY6-cceL-IdH0-Znhv6s
```

### lvextendでボリュームグループの空き領域を「論理ボリューム (LV)」に割り当てる
物理ボリュームをボリュームグループに追加したら、次は論理ボリュームのサイズを拡張します。
まずは、lvdisplay コマンドで論理ボリュームの一覧を確認します。
そして、lvextend コマンドではファイルシステム名を指定して拡張するため、論理ボリューム名からファイルシステム名への変換が必要です。
例えば、論理ボリューム名が「/dev/rl/root」であればファイルシステムは「/dev/mapper/rl-root」です。

今回拡張するファイルシステムは /dev/mapper/rl-root です。

```bash
~]# df -h
ファイルシステム                        サイズ  使用  残り 使用% マウント位置
devtmpfs                              1.8G     0  1.8G    0% /dev
tmpfs                                 1.8G   12K  1.8G    1% /dev/shm
tmpfs                                 1.8G  8.7M  1.8G    1% /run
tmpfs                                 1.8G     0  1.8G    0% /sys/fs/cgroup
/dev/mapper/rl-root                    52G   14G   38G   27% /
/dev/mapper/rl-home                    26G  9.2G   16G   37% /home
/dev/sda2                            1014M  250M  765M   25% /boot
/dev/sda1                             599M  5.7M  594M    1% /boot/efi
tmpfs                                 365M     0  365M    0% /run/user/10500
tmpfs                                 365M     0  365M    0% /run/user/0
```

lvextend コマンドで /dev/sda の空き領域を全てを /dev/mapper/rl-root に割り当てることで、ファイル領域を拡張します。

```bash
~]# lvextend -l +100%FREE /dev/mapper/rl-root
  Size of logical volume rl/root changed from <51.31 GiB (13135 extents) to 271.30 GiB (69454 extents).
  Logical volume rl/root successfully resized.
```

lvdisplay コマンドで確認すると、論理ボリューム /dev/rl/root のサイズ LV Size が 271.30 GiB (~= 300GB) に拡張されました。

```bash
~]# lvdisplay

  --- Logical volume ---
  LV Path                /dev/rl/root
  LV Name                root
  VG Name                rl
  LV UUID                Ryxier-VfFT-xCFN-6dhj-R69S-NdRM-1moKPm
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2022-07-11 13:21:10 +0900
  LV Status              available
  # open                 1
  LV Size                271.30 GiB
  Current LE             69454
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
```

### xfs_growfsで論理ボリュームのサイズを「ファイルシステム」に反映する
論理ボリュームを拡張したら、最後にファイルシステムに反映させます。
xfs_growfs コマンドでCentOSにファイルシステム側に増設した論理ボリュームを認識させます。

```bash
~]# xfs_growfs /
meta-data=/dev/mapper/rl-root    isize=512    agcount=4, agsize=3362560 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=0 inobtcount=0
data     =                       bsize=4096   blocks=13450240, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=6567, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 13450240 to 71120896

~]# df -h
ファイルシステム                        サイズ  使用  残り 使用% マウント位置
devtmpfs                              1.8G     0  1.8G    0% /dev
tmpfs                                 1.8G   12K  1.8G    1% /dev/shm
tmpfs                                 1.8G  8.7M  1.8G    1% /run
tmpfs                                 1.8G     0  1.8G    0% /sys/fs/cgroup
/dev/mapper/rl-root                   272G   16G  257G    6% /
/dev/mapper/rl-home                    26G  9.2G   16G   37% /home
/dev/sda2                            1014M  250M  765M   25% /boot
/dev/sda1                             599M  5.7M  594M    1% /boot/efi
tmpfs                                 365M     0  365M    0% /run/user/10500
tmpfs                                 365M     0  365M    0% /run/user/0
```

以上です。

### 参考文献

- [【CentOS8】ボリューム拡張手順（/dev/mapper/cl-root）ESXi7.0環境 \| インフラエンジニアの技術LOG](https://genchan.net/it/server/13181/)
