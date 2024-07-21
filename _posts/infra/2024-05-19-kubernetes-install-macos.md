---
layout:        post
title:         "[Kubernetes] MacOS (M1) に検証環境をminikubeで作成する"
date:          2024-05-19
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /linux/kubernetes-install-macos
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ここでは、minikubeを使ったKubernetesの環境構築の方法について説明します。


### 用語集

- Minikube : ローカルでKubernetesを動かすことができるツール
- kubectl : Kubernetesのコマンドラインツール
- Dokcer : コンテナの仮想化ツール。MacOSでKubernetesを起動するときに必要


### インストール手順

1. 必要スペックを満たすPCを用意します
    - 2 CPU以上
    - 2GB以上のメモリ
    - 20GB以上のHDD
    - インターネット接続
    - コンテナや仮想マシンを管理するツール（Docker, QEMU, Hyper-V, KVM, Podman, VirtualBoxなど）
        - 今回はMacOSのため、Dockerを使用します
2. インストール
    ```
    brew install minikube
    ```
3. クラスターの起動
    ```
    minikube start
    ```
4. クラスターの状態確認
    ```
    kubectl get po -A
    ```

### アプリのデプロイ

TCPの8080番ポートでエコーサーバを起動するには、以下のコマンドを実行します。

```
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

kubectl get services コマンドでサービスが起動したかを確認できます。

```
kubectl get services hello-minikube
```

ローカルから動作確認するために、ローカルの7080番ポートを、コンテナの8080番ポートに転送されるように設定します。
```
kubectl port-forward service/hello-minikube 7080:8080
```

この状態で、http://localhost:7080 にアクセスすると、Kubernetesにデプロイしたサーバの動作確認をすることができます。

以上です。



### 参考資料

- [minikube start \| minikube](https://minikube.sigs.k8s.io/docs/start/)
