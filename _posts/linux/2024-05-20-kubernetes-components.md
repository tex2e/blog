---
layout:        post
title:         "Kubernetesのコンポーネント"
date:          2024-05-20
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

ここでは、Kubernetesの各コンポーネントの関係について説明します。

### クラスターのアーキテクチャ

```fig
+------------------------------- CLUSTER ----------------------------------+
| +---------- CONTROL PLAIN -----------+                                   |
| |                                    |                                   |
| |          cloud-controller-manager  |                                   |
| |                    ^               |                                   |
| |                    |               |      +------- Node1 ------------+ |
| |                    V               |      |                          | |
| |  etcd -----> kube-api-server --------------------+---------+         | |
| |                 ^      ^           |      |      V         V         | |
| |                 |      |           |      |   kubelet  kube-proxy    | |
| |      kube-scheduler    |           |      |      |         |         | |
| |                        |           |      |      V         V         | |
| |      kube-controller-manager       |      |   +-------------------+  | |
| |                                    |      |   | [pod] [pod] [pod] |  | |
| +------------------------------------+      |   +-------------------+  | |
|                                             +--------------------------+ |
+--------------------------------------------------------------------------+
```

管理者は kubectl コマンドを実行すると、kube-api-server を経由して管理・制御が行われます。


### 用語集

- **Control Plain** (コントロールプレーン) のコンポーネント
    - **kube-apiserver** : クラスタ全体における司令塔の役割を担当する。NodeのPodへの制御はこのAPIサーバを介して行われる
    - **kube-scheduler** : 新しいPodが作成されたときに、それらのPodが実行されるのに適切なNodeを選択して、スケジューリングする
    - **etcd** : 分散型のキーバリューストア。Kubernetesクラスタ全体の構成情報を保存するデータストアの役割を担当する
    - **kube-controller-manager** : Nodeで実行される各種ワークロードを制御する。複数のコントローラーから構成される。以下は主なコントローラの一覧
        - Depolyment Controller
        - Replicaset Controller
        - DaemonSet/StatefulSet Controller
        - Service Controller
        - Node Controller
    - **cloud-controller-manager** : AWSやGCPなどのクラウドサービスと連携するためのコンポーネント
- **Data Plain** (データプレーン) のコンポーネント
    - **kubelet** : 各Node上で動作するエージェント。Podがマニフェストに記述された通りの状態で動作していることを確認する役割を担当する
    - **kube-proxy** : 各Nodeで動作するServiceやクラスタ内外のネットワークトラフィックの制御を行う
    - Container Runtime : NodeでPodを実行するためのコンテナの実行環境。Kubernetesではcontainerd、CRI-O、Docker Engineなどの複数のエンジンに対応しています。


### コマンド実行例

```
$ kubectl get po -A
NAMESPACE              NAME                                        READY   STATUS    RESTARTS   AGE
default                hello-minikube-5c898d8489-mjkpg             1/1     Running   0          56m
kube-system            coredns-7db6d8ff4d-2kxpn                    1/1     Running   0          88m
kube-system            etcd-minikube                               1/1     Running   0          88m
kube-system            kube-apiserver-minikube                     1/1     Running   0          88m
kube-system            kube-controller-manager-minikube            1/1     Running   0          88m
kube-system            kube-proxy-r8jlk                            1/1     Running   0          88m
kube-system            kube-scheduler-minikube                     1/1     Running   0          88m
kube-system            storage-provisioner                         1/1     Running   0          88m
kubernetes-dashboard   dashboard-metrics-scraper-b5fc48f67-ckl5n   1/1     Running   0          86m
kubernetes-dashboard   kubernetes-dashboard-779776cb65-qhbh6       1/1     Running   0          86m
```




### 参考資料

- [クラスターのアーキテクチャ \| Kubernetes](https://kubernetes.io/ja/docs/concepts/architecture/)
