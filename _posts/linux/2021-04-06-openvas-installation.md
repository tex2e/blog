---
layout:        post
title:         "OpenVASをKali Linuxにインストール"
date:          2021-04-06
category:      Linux
cover:         /assets/cover1.jpg
redirect_from: /security/openvas-installation
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

OpenVASは脆弱性スキャンをするためのツールです。
ここではKaliにOpenVASをインストールする方法について説明します。

まず、aptを使ってOpenVASのインストールし、専用のコマンドでセットアップします（インストール時は openvas を gvm に変えても同じです）。
```bash
sudo apt install openvas
sudo gvm-setup
```

gvm-setupが正常終了するとadminユーザのパスワードが表示されるので、念のためメモします。

次に、adminでログインするのは面倒なので、OpenVASのログインユーザを作成・追加します。
gvmdコマンドは _gvm ユーザで実行する必要があるので、sudo -u で実行ユーザ名を指定します（DBアクセス時にユーザ名を使っていると思われます）。
今回はユーザ名/パスワードを kali/kali とします。
```bash
sudo -u _gvm -- gvmd --create-user=kali
sudo -u _gvm -- gvmd --user=kali --new-password=kali
sudo -u _gvm -- gvmd --get-users
```

OpenVASの開始と終了方法
```bash
sudo gvm-start
sudo gvm-stop
```

脆弱性リストの更新
```bash
sudo gvm-feed-update
```

gvm-start で OpenVASのサービスが起動したら、ブラウザの起動に失敗するエラーのダイアログが表示されますが無視して、
127.0.0.1:9392 にアクセスし、kali/kali でログインします。

脆弱性スキャンするには、上のメニューの「Scans」>「Tasks」を開き、左上のアイコンから「New Task」をクリックします。ダイアログが表示されるので、「Scan Targets」の右のアイコンから「Create a new target」をクリックしてスキャン対象のIPを指定します。
その他はデフォルト値のままで保存します [^1]。

[^1]: [How to Add and Scan a Target for Vulnerabilities on OpenVAS Scanner - kifarunix.com](https://kifarunix.com/how-to-add-and-scan-a-target-for-vulnerabilities-on-openvas/)

実行は「Tasks」内のタスク一覧の右側にある「Actions」から再生ボタンみたいなアイコンをクリックすると脆弱性スキャンが開始されます。

実行時や脆弱性スキャンが完了すると、当該タスクにReportsへリンクが表示され、Resultsを確認することができます。

以上です。

---
