---
layout:        book
title:         "2. SELinux/SELinuxの概要"
date:          2022-02-11
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
syntaxhighlight: true
sitemap: false # 後で公開すること!
feed:    false # 後で公開すること!
---

**[WIP] この記事は書き途中です。完成までしばらくお待ちください。**

### SELinuxの特徴

SELinuxは、Linuxの任意アクセス制御 (DAC) に加えて強制アクセス制御 (MAC) 方式でアクセス制御を行うシステムです。
ゼロデイ攻撃などのソフトウェアの脆弱性を悪用した攻撃からシステムを守るための仕組みを提供します。
SELinuxにはログ機能と監査機能も含まれており、不正なアクセスや権限昇格を検知することができます。
MACの下では、限られた許可しか持たない専用のサンドボックスの中でそれぞれのプログラムが実行されます。
そのため、攻撃者にプログラムの脆弱性を利用されても、侵害の影響範囲をそのプログラムに与えられた権限の範囲内だけの抑えることができます。
Linuxには既にDACというアクセス制御方式もありますが、SELinuxのMACは以下の点でLinuxのDACよりも優れています。

- SELinuxのMACはユーザにもプロセスにもルールを適用できますが、LinuxのDACではユーザにしか適用できないです
- SELinuxのMACはオブジェクトの所有者がルールを変更できないですが、LinuxのDACでは所有者がルールを設定できます
- SELinuxのMACはネットワークソケットやBloutoothなどのデバイスにもルールを適用できます

SELinuxは、それぞれのプロセスにドメインと呼ばれるラベルを付与して、サンドボックスを割り当てることでアクセス制御を行います。
それぞれのドメインは、必要最小限の機能は実行できますが、それ以外は拒否するルールセットが定義されています。
ドメインごとにアクセスできるファイルは制限されていて、自身のドメインに関係ないファイルへの読み書きは拒否されます。

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/1-type.png" width=450px />
<figcaption>各プロセスがアクセスできる範囲を制限するSELinuxの例</figcaption>
</figure>

SELinuxでは、このようなアクセス許可・拒否を判断するためにファイルごとにセキュリティコンテキストというラベルが付けられています。
それぞれのセキュリティコンテキストには、末尾が `_t` で表される**タイプ**と呼ばれる属性情報が含まれます。
SELinuxによってタイプが割り当てられるのは、オブジェクトだけではなく、サブジェクトにも割り当てられます。
特に、プロセスに割り当てられるタイプのことを**ドメイン**と呼びます。
ドメインは、セキュリティコンテキストのタイプでアクセス許可が与えられていなければ、そのファイルにアクセスすることはできません。
これはファイルだけでなくディレクトリについても同様です。
ドメインは、セキュリティコンテキストのタイプでアクセス許可が与えられていなければ、対象のディレクトリにアクセスすることはできません。

インストール初期状態でSELinuxは、既に大量のルールを持っているため、自分でファイルやディレクトリに対してラベル付けをする必要はほとんどありません。
新たにソフトウェアをインストールしてサービスとして起動する際も、yumや、dnf、systemctlを使った通常の方法でインストールすれば、自動的に新規で作成したファイルやディレクトリにラベル付けが行われます。
もし、独自のディレクトリ構成にしたい場合や、SELinuxのポリシーで拒否してしまうソフトウェアの新機能を使いたい場合は、SELinuxのポリシーをコマンド経由で自分で修正することも可能です。


### DACとMACの共存

LinuxにはDAC (任意アクセス制御) というシステムがあります。
LinuxのDACとSELinuxのMAC (強制アクセス制御) は、競合しないで共存することができます。
SELinuxは、アクセス許可・拒否の判定をするとき、先にLinuxのDACによる判定を行います。
DACがアクションを禁止すれば、そのアクションは許可しません。
DACがアクションを許可すれば、続いてSELinuxはMACに基づいてアクセスが許可されているか確認します。
サブジェクトがオブジェクトにアクションできるのは、LinuxのDACとSELinuxのMACの両方が許可されている場合だけです。

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-processing-call.png" width=600px />
<figcaption>DACとMACの両方によるアクセス許可の流れ</figcaption>
</figure>


### プロセスの制御

SELinuxが特定のアクションを許可するか拒否するかを決定する必要がある場合、SELinuxは、サブジェクトとオブジェクトの両方のセキュリティコンテキストに基づいて決定を行います。
これらのセキュリティコンテキストは、SELinuxが適用するポリシールールで定義されています。

プロセスのセキュリティコンテキストは、**ドメイン**とも呼ばれ、SELinuxに対してプロセスを識別するものです。
SELinuxにはLinuxプロセスにおける所有権の概念はありません。
SELinuxのMACがアクセスを決定する際に必要なものは、セキュリティコンテキストだけです。
SELinuxにおいて、セキュリティコンテキストとラベルは同じ意味で使用されます。

すべてのユーザは、SELinuxによってラベル付けされています。
例として、現在ログインしているユーザのセキュリティコンテキストを表示します。

```bash
~]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

現在ログインしているユーザの情報を出力する id コマンドに -Z オプションを追加すると、ユーザのセキュリティコンテキストが表示されます。
セキュリティコンテキストは、4個のフィールドと3個の区切り文字「:」から構成されています。
「:」は4個あるように見えますが、最後の部分は「s0-s0:c0.c1023」で1個のフィールドを表します。

SELinuxのセキュリティコンテキストには、少なくとも3個、場合によっては4個のフィールドが含まれています。
例として、Apache Webサーバーのセキュリティコンテキストを表示します。

```bash
~]$ ps -eZ | grep httpd
system_u:system_r:httpd_t:s0       1637 ?        00:00:00 httpd
```

セキュリティコンテキストの各フィールドは、それぞれ次の意味を持ちます。
- 1番目はSELinuxユーザを表します。Apacheには、system_uユーザが割り当てられています。なお、SELinuxのユーザ管理は、Linuxが /etc/passwd で管理するユーザのリストを使用していません。代わりに、SELinuxユーザとLinuxユーザを結びつけるための独自のデータベースとマッピングを使用します。
- 2番目はSELinuxロール (役割) を表します。Apacheには、system_rロールが割り当てられています。
- 3番目はSELinux**タイプ**を表します。プロセスに付与したタイプはドメインと呼びます。Apacheには、httpd_tドメインが割り当てられています。なお、タイプをサブジェクトに付与してもオブジェクトに付与しても機能は同じですが、サブジェクトに付与するときは「ドメイン」、オブジェクトに付与するときは「タイプ」と呼びます。
- 4番目は機密度レベルを表します。

SELinuxがアクション許可を判断するのに必要なのはセキュリティコンテキストだけです。
ポリシールールのほとんどは、SELinuxユーザとSELinuxロールを使用しないで、SELinuxタイプ (またはドメイン) のみを使用して構成されているため、最も重要なフィールドは3番目のSELinuxタイプだけです。

すべてのプロセスとすべてのオブジェクトにラベル付けを行い、プロセスのドメインに対してアクセス制御をする仕組みを**Type Enforcement** (**型強制**) といいます。
Type Enforcementを使用することで、SELinuxはアプリケーションやサービスが実行できることを制御できます。

なお、ユーザが手動で起動したWebサーバ (`/usr/sbin/httpd -DFORGROUND` など) と、systemctlなどのシステム経由で起動したWebサーバは、実行ファイルのパスが同じでも、起動したプロセスはそれぞれ異なるドメインで動作します。
systemctl経由で起動したプロセスは httpd_t などの適切なドメインが割り当てられますが、手動で起動した場合は通常の処理とみなされて unconfined_t (制限なしのドメイン) が割り当てられます。
これは、プロセスのドメインはドメイン遷移のルールによってラベル付けされるためです。
ドメイン遷移は「どのドメインのプロセスが、どのタイプのファイルを実行すると、どのドメインとしてプロセス起動するか」を定義するものです。
unconfined_t のラベルを持つユーザがプログラムを実行しても、ドメイン遷移のルールに定義されていないため、起動されるプロセスは unconfined_t になり、SELinuxによるアクセス制御はできません。
一方で、systemctl経由でプログラムを実行すると、ドメイン遷移のルールに従ってプロセスにドメインが割り当てられます。

例として、Apacheのドメイン遷移について確認します。
systemctl経由でWebサーバを起動した場合は、プロセスには httpd ドメインが割り当てられます。
```bash
~]# systemctl start httpd
~]# ps -eZ | grep httpd
system_u:system_r:httpd_t:s0            92102 ?  00:00:00 httpd
```

一方で、手動でWebサーバを起動した場合は、プロセスには unconfined_t ドメインが割り当てられます。
```bash
~]# /usr/sbin/httpd -DFORGROUND
~]# ps -eZ | grep httpd
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023  91960 ?  00:00:00 httpd
```

起動元のプロセスのセキュリティコンテキストが違うと、生成されるプロセスのセキュリティコンテキストも変わります。
`sesearch --type_trans` または `sesearch -T` コマンドを使ってドメイン遷移を検索すると、init_tドメインのプロセスが、httpd_exec_tタイプのファイルを実行すると、httpd_tドメインとしてプロセスが起動される、というルールが定義されています。

```bash
~]# sesearch -T | grep httpd_exec_t
...
type_transition init_t httpd_exec_t:process httpd_t;
...
```

init_t ドメインは、systemd プロセスに割り当てられるドメインです。
httpd_exec_t タイプのファイルは、/usr/sbin/apache2 や /usr/sbin/httpd などの Apache 本体のコマンドです。
SELinuxはこれらのパスのファイルを自動的に httpd_exec_t タイプでラベル付けしています。
永続化したラベル付けのルールは `semanage fcontext -l` コマンドで確認することができます。
確認した結果から、init_t ドメインの systemd プロセスが、/usr/sbin/httpd コマンドを実行すると、生成されたプロセスには httpd_t ドメインが割り当てられることがわかりました。

```bash
# systemdプロセスのセキュリティコンテキスト：
~]# ps -eZ | grep init_t
system_u:system_r:init_t:s0           1 ?        00:00:05 systemd

# httpd_exec_tタイプを持つファイルパターン：
~]# semanage fcontext -l | grep httpd_exec_t
...
/usr/sbin/apache(2)?                 regular file     system_u:object_r:httpd_exec_t:s0
/usr/sbin/httpd(\.worker)?           regular file     system_u:object_r:httpd_exec_t:s0
/usr/sbin/httpd\.event               regular file     system_u:object_r:httpd_exec_t:s0
/usr/sbin/lighttpd                   regular file     system_u:object_r:httpd_exec_t:s0
/usr/sbin/nginx                      regular file     system_u:object_r:httpd_exec_t:s0
/usr/sbin/php-fpm                    regular file     system_u:object_r:httpd_exec_t:s0
...

# httpdコマンドのセキュリティコンテキスト：
~]$ ls -Z /usr/sbin/httpd
system_u:object_r:httpd_exec_t:s0 /usr/sbin/httpd
```

systemctl経由で起動したApacheは httpd_t ドメインが割り当てられますが、手動で起動した場合は unconfined_t が割り当てられます。
unconfined_t は、SELinuxに制限されないプロセスなので、本来の保護機能を十分に活用できません。
特別な理由がない限り、yumやdnfでインストールしたときのパッケージのファイル構成を維持し、systemctl経由でサービスを起動するようにします。
また、本番環境では起動しているプロセスが適切なドメインで動作しているかを `ps -eZ` コマンドで確認することは、アクセス制御をする上で重要なことです。




#### アクセス決定

TODO:

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-core.png" width=700px />
<figcaption>アクセス決定の流れ</figcaption>
</figure>




### ファイルのラベリング

ファイルのセキュリティコンテキストは、ls コマンドの -Z オプションを使用して取得できます。
ディレクトリのセキュリティコンテキストも同様に取得できます。

```bash
~]$ ls -Z /var/www/html/index.html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html

~]$ ls -dZ /home/example.user/
unconfined_u:object_r:user_home_dir_t:s0 /home/example.user/
```

ファイルに関するラベル付けルールが定義されていない場合、新規作成したファイルはルート直下のディレクトリ名に似たタイプでラベル付けされます。

- /bin や /usr/bin の下に作成したファイルは、bin_t のタイプが付けられます。
- /etc の下に作成したファイルは、etc_t のタイプが付けられます。
- /var の下に作成したファイルは、var_t のタイプが付けられます。
- /tmp の下に作成したファイルは、tmp_t のタイプが付けられます。
- /home/xxx/ などのホームディレクトリの下に作成したファイルは、user_home_t のタイプが付けられます。


#### ファイルコンテキストの一時的な変更 (chcon)

TODO:

https://tex2e.github.io/blog/linux/selinux-chcon

#### ファイルコンテキストの復元 (restorecon)

TODO:

#### ファイルコンテキストの永続的な変更 (semanage fcontext)

TODO:

https://tex2e.github.io/blog/linux/semanage-fcontext

#### オブジェクトのロール
セキュリティコンテキストとは、SELinuxのユーザ、ロール、タイプの3つのセキュリティ属性をまとめたものです。
SELinuxでは、処理の高速化のために、セキュリティコンテキストにSID (セキュリティID) と呼ばれる一意の整数値を割り当てて識別します。
サブジェクトは能動的で様々なロールを持つことができますが、オブジェクトは受動的なのであまりロールを必要としません。
ただし、全てのサブジェクトとオブジェクトには3つのセキュリティ属性を持つセキュリティコンテキストを割り当てないといけないので、ロールが不要なオブジェクトには、ダミーのロール object_r が付与されています。


### ポートのラベリング (semanage port)

TODO:

https://tex2e.github.io/blog/linux/semanage-port

### ブール値 (semanage boolean)

TODO:

### ユーザの管理 (semanage login)

TODO:

https://tex2e.github.io/blog/linux/selinux-user

https://tex2e.github.io/blog/linux/selinux-user-mapping

### ポリシーモジュールの管理 (semodule)

TODO:

audit2allow + semodule

https://tex2e.github.io/blog/linux/selinux-allow-from-denied-log


### ログと監査

TODO:


### SELinuxのアーキテクチャ

TODO:

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-high-level-arch.png" width=800px />
<figcaption>SELinuxのアーキテクチャ</figcaption>
</figure>




---

[PRIV](./1-access-control) \| [NEXT](./3-selinux-practice)
