---
layout:        post
title:         "[Windows] セキュリティログ：イベントID 4672 新しいログオンに特権が割り当てられました。とは"
type:          Concept
description:   "WindowsセキュリティログのイベントID 4672が記録される意味と、SeDebugPrivilegeなど割り当てられる主な特権の役割を解説。"
tags:          [windows, security-log, privileges, security]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-07T00:45:09Z
sources:
  - id:        ref-1
    resource:  https://docs.microsoft.com/ja-jp/windows/security/threat-protection/auditing/event-4672
    title:     "4672(S) 新しいログオンに割り当てられた特別な特権。 (Windows 10) - Windows security \\| Microsoft Docs"
date:          2021-11-07
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsのセキュリティログの「新しいログオンに特権が割り当てられました。」は、管理者権限などの高い権限を持つユーザがログインしたときに記録されるログです。

特権とはプロセスに関連付けられている権限のことです。
特に特権 SeDebugPrivilege が割り当てられる場合は、そのユーザは管理者ユーザであることがわかります。

* SeSecurityPrivilege : 監査とセキュリティログの管理
* SeTakeOwnershipPrivilege : ファイルとその他のオブジェクトの所有権の取得
* SeDebugPrivilege : プログラムのデバッグをする権限
* SeSystemEnvironmentPrivilege : ファームウェア環境の値を変更する権限
* SeLoadDriverPrivilege : デバイスドライバーの読み込みとアンロードをする権限
* SeImpersonatePrivilege : 認証後にクライアントを偽装する権限
* SeDelegateSessionUserImpersonatePrivilege : セッションの委任と認証後にクライアントを偽装する権限
* SeEnableDelegationPrivilege : 委任に対してコンピューターアカウントとユーザーアカウントを信頼する権限
* SeAuditPrivilege : セキュリティ監査ログの生成する権限

#### 参考文献
- [4672(S) 新しいログオンに割り当てられた特別な特権。 (Windows 10) - Windows security \| Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/security/threat-protection/auditing/event-4672)
