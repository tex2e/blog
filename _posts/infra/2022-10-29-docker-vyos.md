---
layout:        post
title:         "[Docker] VyOSの検証環境を構築する"
date:          2022-10-29
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

DockerでVyOSの検証環境を構築する方法について説明します。
注意点ですが、NATやFirewallなどの一部の設定はコンテナ化されたVyOSでは使用できないです。
設定時の構文チェックとしての確認用程度に使うのが良いかと思います。

### ネットワーク構成
今回構築するのは、2つのネットワーク 192.168.10.0/24 と 192.168.20.0/24 があり、その間にVyOSが存在する構成です。

```fig
                       +------[vyos1]-------+
                       |     .1     .1      |
                       |                    |
                   [vswitch1]          [vswitch2]
        192.168.10.0/24|                    |192.168.20.0/24
                       |                    |
                  +----+----+          +----+----+
                  |         |          |         |
              [centos1] [centos2]  [centos3] [centos4]
                 .2        .3         .2        .3
```

- セグメント1 (192.168.10.0/24)
  - VyOS (192.168.10.1)
  - CentOS1 (192.168.10.2)
  - CentOS2 (192.168.10.3)
- セグメント2 (192.168.20.0/24)
  - VyOS (192.168.20.1)
  - CentOS3 (192.168.20.2)
  - CentOS4 (192.168.20.3)

### Ubuntu
まずはDockerを動かすためのUbuntu環境を用意します。
openvswitch関係のコマンドもインストールするため、Ubuntuを用意してください。

### Docker
[Docker公式のインストール手順](https://docs.docker.com/engine/install/ubuntu/)を参考にセットアップします。

```bash
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl gnupg lsb-release
$ sudo mkdir -p /etc/apt/keyrings
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Open vSwitch
仮想スイッチを作成するためのツールをインストールします。

```bash
$ sudo apt install openvswitch-common openvswitch-switch
```

仮想スイッチの作成は以下コマンドです。

```bash
$ sudo ovs-vsctl add-br vswitch1
$ sudo ovs-vsctl add-br vswitch2
$ sudo ovs-vsctl show
    Bridge vswitch2
        Port vswitch2
            Interface vswitch2
                type: internal
    Bridge vswitch1
        Port vswitch1
            Interface vswitch1
                type: internal
```

### VyOS
DockerでVyOSサーバを起動します。

```bash
$ sudo docker run -d --name vyos1 --privileged --device=/dev/net/tun -v /lib/modules:/lib/modules 2stacks/vyos:1.2.0-rc11 /sbin/init
```

vyos1にインターフェイスを作成し、仮想スイッチと接続します。

```bash
$ sudo ovs-docker add-port vswitch1 eth1 vyos1 --ipaddress=192.168.10.1/24
$ sudo ovs-docker add-port vswitch2 eth2 vyos1 --ipaddress=192.168.20.1/24
```

### CentOS
DockerでCentOSサーバを起動します。

```bash
$ sudo docker run -d --net=none --privileged --name centos1 centos /sbin/init
$ sudo docker run -d --net=none --privileged --name centos2 centos /sbin/init
$ sudo docker run -d --net=none --privileged --name centos3 centos /sbin/init
$ sudo docker run -d --net=none --privileged --name centos4 centos /sbin/init
```

各CentOSサーバにインターフェイスを作成し、仮想スイッチと接続します。

```bash
$ sudo ovs-docker add-port vswitch1 eth0 centos1 --ipaddress=192.168.10.2/24
$ sudo ovs-docker add-port vswitch1 eth0 centos2 --ipaddress=192.168.10.3/24
$ sudo ovs-docker add-port vswitch2 eth0 centos3 --ipaddress=192.168.20.2/24
$ sudo ovs-docker add-port vswitch2 eth0 centos4 --ipaddress=192.168.20.3/24
```

設定後、各サーバのIPアドレスを確認します。
```bash
$ sudo docker exec -it centos1 ip a
$ sudo docker exec -it centos2 ip a
$ sudo docker exec -it centos3 ip a
$ sudo docker exec -it centos4 ip a
```

この時点で同一ネットワークにある CentOS1 から CentOS2 への通信は可能ですが、別ネットワークの CentOS3 への通信は不可能です。

```bash
$ sudo docker exec -it centos1 ping -c 1 192.168.10.3

PING 192.168.10.3 (192.168.10.3) 56(84) bytes of data.
64 bytes from 192.168.10.3: icmp_seq=1 ttl=64 time=0.394 ms
--- 192.168.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.394/0.394/0.394/0.000 ms
```

```bash
$ sudo docker exec -it centos1 ping -c 1 192.168.20.2

connect: Network is unreachable
```


### デフォルトゲートウェイの設定

別ネットワークにあるサーバ同士を接続する場合は、お互いのデフォルトゲートウェイを vyos1 に向ける必要があります。
行きと戻りのパケットの経路が必要なので、片道の経路だけでは疎通できません。両方とも設定する必要があります。

```bash
$ sudo docker exec -it centos1 ip route add default via 192.168.10.1
$ sudo docker exec -it centos2 ip route add default via 192.168.10.1
$ sudo docker exec -it centos3 ip route add default via 192.168.20.1
$ sudo docker exec -it centos4 ip route add default via 192.168.20.1
```

設定後、各サーバのデフォルトゲートウェイを確認します。
```bash
$ sudo docker exec -it centos1 ip r
$ sudo docker exec -it centos2 ip r
$ sudo docker exec -it centos3 ip r
$ sudo docker exec -it centos4 ip r
```

デフォルトゲートウェイ設定後、別ネットワークの CentOS1 から CentOS3 への通信ができるようになります。

```bash
$ sudo docker exec -it centos1 ping -c 1 192.168.20.2

PING 192.168.20.2 (192.168.20.2) 56(84) bytes of data.
64 bytes from 192.168.20.2: icmp_seq=1 ttl=63 time=0.553 ms
--- 192.168.20.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.553/0.553/0.553/0.000 ms
```

### VyOSの設定

DockerからVyOSにbashで接続します。

```bash
[ubuntu]$ sudo docker exec -it vyos1 /bin/vbash
```

デフォルトだとVyOS設定書き込み時に「can't initialize output」と権限なしで怒られるため、以下のコマンドを root で実行します。

```bash
[vyos]# mkdir -p /var/log/vyatta/
[vyos]# touch /var/log/vyatta/vyatta-config-loader.log
[vyos]# touch /var/log/vyatta/vyatta-commit.log
[vyos]# chmod ugo+rwX /var/log/vyatta/
[vyos]# chgrp -R vyattacfg /var/log/vyatta/
```

VyOSの設定は minion ユーザに切り替えてから作業する。

```bash
[vyos]# su - minion
```

```bash
[vyos-minion]$ show config
Configuration under specified path is empty

[vyos-minion]$ config
[vyos-minion]# set interfaces loopback lo
[vyos-minion]# set system login user myvyosuser authentication plaintext-password mysecurepassword
[vyos-minion]# commit
```

NATの設定は不可でした。他のブログ記事とかではできているようなので、私の設定に不備があるかもしれないです。

```bash
[vyos-minion]$ config
[vyos-minion]# set nat source rule 10 source address '192.168.0.0/16'
[vyos-minion]# set nat source rule 10 outbound-interface 'eth0'
[vyos-minion]# set nat source rule 10 translation address masquerade
[vyos-minion]# set nat source rule 10 description 'dhcp to global'
[vyos-minion]# commit
```

Firewallの設定は可能でしたが、デフォルトだと iptables の VYATTA_FW_IN_HOOK がチェインに追加されていないので、VyOS上で設定しただけでは反映されていないようでした。

```bash
[vyos-minion]$ config
[vyos-minion]# set firewall name rule_eth1_in default-action 'accept'
[vyos-minion]# set firewall name rule_eth1_in rule 10 action 'reject'
[vyos-minion]# set firewall name rule_eth1_in rule 10 protocol 'icmp'
[vyos-minion]# set interfaces ethernet eth1 firewall in name 'rule_eth1_in'
[vyos-minion]# commit
[vyos-minion]# show
firewall {
    name rule_eth1_in {
        default-action accept
        rule 10 {
            action reject
            protocol icmp
        }
    }
}
interfaces {
    ethernet eth0 {
        address 172.17.0.2/16
    }
    ethernet eth1 {
        firewall {
            in {
                name rule_eth1_in
            }
        }
    }
    loopback lo {
    }
}
```

VyOSでFW設定後のiptablesの状態は次のようになっていました。「0 references」なので反映されていない感じです。
```bash
[vyos]# iptables -L

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain VYATTA_FW_IN_HOOK (0 references)
target     prot opt source               destination         
rule_eth1_in  all  --  anywhere             anywhere            

Chain VYATTA_FW_LOCAL_HOOK (0 references)
target     prot opt source               destination         

Chain VYATTA_FW_OUT_HOOK (0 references)
target     prot opt source               destination         

Chain rule_eth1_in (1 references)
target     prot opt source               destination         
REJECT     icmp --  anywhere             anywhere             /* rule_eth1_in-10 */ reject-with icmp-port-unreachable
RETURN     all  --  anywhere             anywhere             /* rule_eth1_in-10000 default-action accept */
```

VyOSのユーザ作成とかパスワード変更などの設定はできるようなので、Dockerコンテナ上のVyOSはあくまでも設定の構文チェックなどに使う程度に留めておくのが良いと思います。

### Dockerコンテナと仮想スイッチの削除
検証が完了したら、任意で作成したDockerコンテナと仮想スイッチを削除しておきます。

```bash
$ sudo docker rm -f vyos1
$ sudo docker rm -f centos1
$ sudo docker rm -f centos2
$ sudo docker rm -f centos3
$ sudo docker rm -f centos4

$ sudo ovs-docker del-port vswitch1 eth1 vyos1
$ sudo ovs-docker del-port vswitch2 eth2 vyos1

$ sudo ovs-docker del-port vswitch1 eth0 centos1
$ sudo ovs-docker del-port vswitch1 eth0 centos2
$ sudo ovs-docker del-port vswitch2 eth0 centos3
$ sudo ovs-docker del-port vswitch2 eth0 centos4
```
以上です。

### 参考文献

- [Dockerコンテナでネットワーク検証環境を構築する - togatttiのエンジニアメモ](https://togattti.hateblo.jp/entry/2019/06/30/104931)
- [dockerに向いてないことを無理矢理やった話（ネットワークがらみ） - Qiita](https://qiita.com/mnagaku/items/f4d8ce881bcfcc14c4c1)
- [ネットワーク初心者の新卒がDockerでネットワークの勉強をしてみた \| サイバーエージェント 公式エンジニアブログ](https://ameblo.jp/principia-ca/entry-12103919307.html)
- [ravens/docker-vyos: VyOS inside a container.](https://github.com/ravens/docker-vyos)
- [Install Docker Engine on Ubuntu \| Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)

