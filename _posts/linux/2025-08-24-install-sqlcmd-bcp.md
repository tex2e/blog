---
layout:        post
title:         "[Linux] sqlcmdとbcpコマンドをインストールする"
date:          2025-08-24
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

Linux（Ubuntu）にsqlcmdとbcpコマンドをインストールする手順について説明します。

### 背景

前提として、SQL Serverと通信するためのコマンドは、標準のLinuxで使えないため、aptでmsodbcsql18とmssql-tools18をインストールする必要があります。

### インストール手順

Linux（Ubuntu）で以下のコマンドを実行します。

```bash
sudo apt-get update
apt-get install -y curl gnupg lsb-release unixodbc-dev
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl https://packages.microsoft.com/config/debian/12/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
ACCEPT_EULA=Y sudo apt-get install -y msodbcsql18
ACCEPT_EULA=Y sudo apt-get install -y mssql-tools18
```

インストールが完了したら、sqlcmdとbcpコマンドへのパスを通してください。

```bash
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

これにより、`/opt/mssql-tools18/bin/bcp` コマンドが `bcp` と入力するだけで使用できるようになります。
同様に `sqlcmd` も使用できるようになります。

以上です。

### 参考資料

- [Install the sqlcmd and bcp SQL Server Command-Line Tools on Linux - SQL Server \| Microsoft Learn](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver17&tabs=ubuntu-install%2Codbc-ubuntu-2204)
