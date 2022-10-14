---
layout:        post
title:         "AWS CLIで起動中のEC2インスタンスID一覧を表示＆EC2を起動・停止する"
date:          2022-10-14
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

AWS CLIで起動中のEC2インスタンスID一覧を表示し、EC2を起動・停止する方法について説明します。

### AWS CLIで起動中のEC2インスタンスID一覧を表示

AWS CLIで起動中のEC2インスタンス一覧を表示するには、awsコマンドの ec2 describe-instances サブコマンドを実行します。
オプション --filter で状態名（instance-state-name）が起動中（running）のEC2だけを出力します。

実行コマンド (describe-instances)：

```bash
$ aws ec2 describe-instances --filter "Name=instance-state-name,Values=running"
```

出力結果：

```json
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-00011223344556677",
                    "InstanceId": "i-00123456789abcdef",  <== インスタンスID
                    "InstanceType": "t2.micro",
                    ...
```

### AWS CLIでEC2を起動

AWS CLIでEC2インスタンスを起動するには、awsコマンドの ec2 start-instances サブコマンドを実行します。
--instance-ids でEC2インスタンスIDを指定します。

実行コマンド (start-instances)：

```bash
$ aws ec2 start-instances --instance-ids i-00123456789abcdef
```

### AWS CLIでEC2を停止

AWS CLIでEC2インスタンスを停止するには、awsコマンドの ec2 stop-instances サブコマンドを実行します。
--instance-ids でEC2インスタンスIDを指定します。

実行コマンド (stop-instances)：

```bash
$ aws ec2 stop-instances --instance-ids i-00123456789abcdef
```

以上です。


### 参考文献

- [ec2 — AWS CLI 1.25.91 Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/)
- [describe-instances — AWS CLI 1.25.91 Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)
- [start-instances — AWS CLI 1.25.91 Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/start-instances.html)
- [stop-instances — AWS CLI 1.25.91 Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/stop-instances.html)
