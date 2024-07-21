---
layout:        post
title:         "[AWS] CLIでIAMユーザの多要素認証を無効化する方法"
date:          2023-11-03
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

AWS CLIでIAMリソースを更新可能なアクセスキーがある状態で、マネジメントコンソールを使用しないで、MFAが有効になったIAMユーザからMFA (多要素認証) を無効化する方法について説明します。


### 1. IAMユーザのMFAデバイスを確認

まず初めに、IAMユーザに設定されたMFAデバイスのID (ARN) を確認します。
IAMのlist-mfa-devies APIを利用し、引数 --user-name でユーザ名を指定し、それに紐づくMFAデバイスのARNを表示させます。

```bash
$ aws iam list-mfa-devices --user-name USERNAME
```

出力結果：

```json
{
    "MFADevices": [
        {
            "UserName": "USERNAME",
            "SerialNumber": "arn:aws:iam::123456789012:mfa/USERNAME",
            "EnableDate": "2023-11-01T10:20:30+00:00"
        }
    ]
}
```

### 2. MFAデバイスの無効化 (STSなし)

次に、IAMのdeactivate-mfa-device APIを利用して、MFAデバイスを無効化します。
エラーが出力されなければ成功で、ここまでで作業は完了です。お疲れ様でした。

```bash
$ aws iam deactivate-mfa-device --user-name USERNAME --serial-number arn:aws:iam::123456789012:mfa/USERNAME
```

ただし、IAMユーザに紐づくMFAの削除が以下のように失敗することがあります。
この場合は、MFAデバイスを無効化するためにMFAを使ってAWS STSから一時的な認証情報を取得する作業が必要になります。

```console
An error occurred (AccessDenied) when calling the DeactivateMFADevice operation:
To complete this action, please ensure that you are authenticated with an MFA 
device that is enabled for this user.
```

### 3. STSで一時的な認証情報の取得

MFAデバイスで表示されるトークンを使い、STSで一時的な認証情報を取得することで、MFAデバイスの無効化に必要な認証情報を取得することができます。
AWS STSのget-session-token APIを利用し、引数 --serial-number にMFAデバイスのARN、引数 --token-code に現在使用中のMFAデバイスで表示された6桁のトークンを指定して実行します。

```bash
$ aws sts get-session-token --serial-number arn:aws:iam::123456789012:mfa/USERNAME --token-code 123456
```

出力結果：

```json
{
    "Credentials": {
        "AccessKeyId": "ASIA******HWS",
        "SecretAccessKey": "Ayj******EOY",
        "SessionToken": "IQoJa******CnZgA=",
        "Expiration": "2023-11-02T11:20:30+00:00"
    }
}
```

### 4. MFAデバイスの無効化 (STSあり)

AWS STSのget-session-tokenの結果のJSONで必要な認証情報が返ってくるので、それらを環境変数にセットしてから、MFAデバイスを無効化するコマンドを実行します。
Linuxの場合は、以下のコマンドで認証情報を環境変数に認証情報をセットします。

```bash
$ export AWS_ACCESS_KEY_ID=ASIA******SWR
$ export AWS_SECRET_ACCESS_KEY=Ayj******EOY
$ export AWS_SESSION_TOKEN=IQoJa******CnZgA=
```

認証情報をセットしたら、MFAデバイス無効化コマンドを再度実行します。
エラーが出力されなければ成功です。

```bash
$ aws iam deactivate-mfa-device --user-name USERNAME --serial-number arn:aws:iam::123456789012:mfa/USERNAME
```

MFAデバイス無効化後に認証情報が不要になったら環境変数を解放（削除）しておきましょう。
何もしなくても24時間以内には自動的にトークンは無効化されますが、不要になった時点で環境変数から削除するのが安全です。

```bash
$ unset AWS_ACCESS_KEY_ID
$ unset AWS_SECRET_ACCESS_KEY
$ unset AWS_SESSION_TOKEN
```

以上です。


### 参考資料

- [IAMユーザーのMFAをAWS CLIで無効化する \| DevelopersIO](https://dev.classmethod.jp/articles/disable-iam-user-mfa-with-aws-cli/)
- [AWS CLI 経由で MFA を使用してアクセスを認証する \| AWS re:Post](https://repost.aws/ja/knowledge-center/authenticate-mfa-cli)
