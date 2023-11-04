---
layout:        post
title:         "AWS CLIでバケットを作成する方法"
date:          2023-11-04
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

AWS CLIでは、S3 APIのcreate-bucket APIを利用することで、S3にバケットを作成することができます。
サブコマンドs3apiのcreate-bucketメソッドを使用してバケットを作成するには、AWS CLIでAWS S3リソースへのアクセスが許可されたアクセスキーを設定 or IAMロールの割り当てをした後に、以下のコマンドを実行します。

なお、引数 --bucket には作成したいバケット名、引数 --region と --create-bucket-configuration にはバケットを配置するリージョン名を指定します。

```bash
$ aws s3api create-bucket --bucket BUCKETNAME --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1
```

出力結果：

```json
{
    "Location": "http://BUCKETNAME.s3.amazonaws.com/"
}
```

以上です。

### 参考文献

- [create-bucket — AWS CLI 1.29.71 Command Reference](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)
