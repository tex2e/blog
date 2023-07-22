---
layout:        post
title:         "IAMユーザで請求コンソールが表示されないとき"
menutitle:     "[AWS] IAMユーザで請求コンソールが表示されないとき"
date:          2023-07-22
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

AWSで設定して権限を付与することで、IAMユーザで請求コンソールが表示されるようになります。
ここでは、AWSで請求コンソールを表示させる設定手順について説明します。

### 1. 請求情報へのアクセス有効化

1. ルートユーザ（管理者）でログインします。
2. ナビゲーションバーの右上にあるアカウント名を選択し、「アカウント」を選択します。
3. 画面をスクロールし、「IAMユーザー/ロールによる請求情報へのアクセス」を編集します。
4. 「IAMアクセスのアクティブ化」にチェックを入れて「更新」します。

### 2. IAMポリシーの付与

ルートユーザで、ユーザに請求情報にアクセスできるIAMポリシーを付与します。

1. IAM > ユーザ で対象のユーザを選択します。
2. ユーザの許可タブまたは所属しているグループ名の許可タブから「許可を追加」を選択します。
3. 以下のポリシーを追加します（必要に応じて一部省略可）。
    - `AWSPurchaseOrdersServiceRolePolicy`
        - AWS請求コンソールと発注コンソールへの完全なアクセス権限。このポリシーにより、ユーザーはアカウントの発注書を表示、作成、更新、削除できます。
    - `AWSBillingReadOnlyAccess`
        - AWS請求コンソールを表示するためのアクセス権限。
    - `Billing`
        - AWS請求コンソールと AWS Cost Management コンソールを表示および編集する権限。このポリシーの権限には、アカウントの使用状況の表示、予算および支払い方法の変更が含まれます。
4. ルートユーザをログアウトし、IAMユーザでログインして、請求コンソールにアクセスできれば確認完了です。


### 参考資料

- [IAM tutorial: Grant access to the billing console - AWS Identity and Access Management](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console)
    - Step 1 〜 2 が請求コンソールへのアクセス権限付与手順になります
- [Using identity-based policies (IAM policies) for AWS Billing - AWS Billing](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-permissions-ref.html)
    - 付与する許可ポリシーの一覧とその説明です。

<!--
[プロが教えるAWSアカウント作成後に行うべき設定 ～コスト管理編～ \| TOKAIコミュニケーションズ AWSソリューション](https://www.cloudsolution.tokai-com.co.jp/white-paper/2021/0701-244.html)
-->
