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
新たにソフトウェアをインストールしてサービスとして起動する際も、yumやdnfを使った通常の方法でインストールし、systemctlを使った起動をすれば、自動的にファイルやディレクトリ、プロセスに対してラベル付けが行われます。
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


#### アクセスベクターキャッシュ (AVC)

サブジェクトがオブジェクトにアクセスする際に、そのアクセスを許可する/許可しないといった SELinux の決定はキャッシュされます。
このキャッシュのことを、アクセスベクターキャッシュ (AVC; Access Vector Cache) といいます。
SELinux がアクセス決定を行うまでの流れは以下の通りです。

1. サブジェクトがオブジェクトにアクションを行います。このとき、LSM Hookによってオブジェクトマネージャが呼び出されます。
2. オブジェクトマネージャは、アクションが許可されているかをAVCに問い合わせます。
3. セキュリティサーバは、サブジェクトとオブジェクトとアクションが、ポリシーの許可ルールに含まれるかを確認し、結果を返します。
4. AVCは、セキュリティサーバから受け取った結果をキャッシュし、次回以降の同じ問い合わせに対する応答を速くします。
5. オブジェクトマネージャは、問い合わせ結果を元にアクションの制御を行います。

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-core.png" width=700px />
<figcaption>アクセス決定の流れ</figcaption>
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
- 1番目はSELinuxユーザ (SEUser) を表します。Apacheには、system_uユーザが割り当てられています。なお、SELinuxのユーザ管理は、Linuxが /etc/passwd で管理するユーザのリストを使用していません。代わりに、SELinuxユーザとLinuxユーザを結びつけるための独自のデータベースとマッピングを使用します。
- 2番目はSELinuxロール (Role) を表します。Apacheは、system_rロールという役割が割り当てられています。
- 3番目はSELinuxタイプ (Type) を表します。プロセスに付与したタイプはドメインと呼びます。Apacheは、httpd_tドメインが割り当てられています。なお、タイプをサブジェクトに付与してもオブジェクトに付与しても機能は同じですが、サブジェクトに付与するときは「ドメイン」、オブジェクトに付与するときは「タイプ」と呼びます。
- 4番目は機密度レベルを表します。MLSを有効化している場合のみ使用します

SELinuxがアクション許可を判断するのに必要なのはセキュリティコンテキストだけです。
ポリシールールのほとんどは、SELinuxユーザとSELinuxロールを使用しないで、SELinuxタイプ (またはドメイン) のみを使用して構成されているため、最も重要なフィールドは3番目のSELinuxタイプだけです。

すべてのプロセスとすべてのオブジェクトにラベル付けを行い、プロセスのドメインに対してアクセス制御をする仕組みを**Type Enforcement** (**型強制**) といいます。
Type Enforcementを使用することで、SELinuxはアプリケーションやサービスができることを制御し、よりセキュアな環境を維持することができます。

#### 制限のないプロセス

制限のないドメインでプロセスが動作する場合は、そのプロセスはSELinuxからの制限を受けません。
例えば、カーネルで実行されるプロセスのドメイン kernel_t、制限のないサービスのドメイン unconfined_service_t、制限のないユーザのドメイン unconfined_t などがあります。
制限のないドメインで動作するプロセスは、MACルールは使用しませんが、DACルールは引き続き使用してアクセス制御を実施します。


### ドメイン遷移

特定のドメインがプログラムを実行した際に別のドメインに遷移することを**ドメイン遷移** (Domain Transition) といいます。
例えば、init_t ドメインの systemd が /usr/sbin/httpd (http_exec_t) を実行すると、起動したプロセスには httpd_t ドメインが割り当てられます。
ドメイン遷移をするためには、以下の複数のポリシールールが必要です。
1. サブジェクトのドメインから別のドメインに遷移するための許可ルール。遷移 (transition) する権限は process クラスに紐づいています
2. サブジェクトのドメインが、プロセス起動のためのファイル実行を許可するルール。実行 (execute) する権限は file クラスに紐づいています
3. 別のドメインに遷移するときに実行されるファイルを限定するためのルール。限定されたファイルはエントリーポイント (entrypoint) と呼ばれます

上記のポリシールールは、以下のコマンドで確認することができます。

```bash
# init_tからhttpd_tドメインに遷移するルール：
~]# sesearch -T -s init_t -c process | grep httpd_t
type_transition init_t httpd_exec_t:process httpd_t;

# init_tドメインが実行できるファイルのタイプ：
~]# sesearch -A -s init_t -t httpd_exec_t -c file -p execute
allow initrc_domain direct_init_entry:file { execute getattr map open read };

# httpd_tドメインとして起動できるエントリーポイント：
~]# sesearch -A -s httpd_t -t httpd_exec_t -c file -p entrypoint
allow httpd_t httpd_exec_t:file { entrypoint execute execute_no_trans getattr ioctl lock map open read };
```

2番目のコマンドの結果について、initrc_domain と direct_init_entry はタイプでなく属性 (Attribute) です。
末尾が `_t` であればタイプですが、それ以外の場合は属性です。
属性 (Attribute) は Type が持つ属性を表したものです。
ルールで Attribute を使うことで、Type だけ異なる複数のルールを1つにまとめることができます。
seinfo -a コマンドで確認すると、initrc_domain 属性の中には init_t タイプが存在し、direct_init_entry 属性の中には httpd_exec_t タイプが存在します。
そのため、ここでは initrc_domain を init_t、タイプが存在し、direct_init_entry を httpd_exec_t に読み替えることにします。

```bash
~]# seinfo -a initrc_domain -x
Type Attributes: 1
   attribute initrc_domain;
        ...
        init_t
        ...

~]# seinfo -a direct_init_entry -x
Type Attributes: 1
   attribute direct_init_entry;
        ...
        httpd_exec_t
        ...
```

属性をタイプに読み替えた上で、init_t から httpd_t へのドメイン遷移は次の図のようになります。

```
        ..... system_r ......
       :                     :
       :     transition      :
    init_t -------------> httpd_t
       |                     |
       |                     | entrypoint
       |     execute         |
       +----------------> httpd_exec_t
```

ドメイン遷移に必要な上記の4つのルールをすべて満たしているときに、ドメイン遷移を実施することができます。
それ以外の場合は、ドメイン遷移が必要なアプリケーションの実行に失敗するか、ドメイン遷移しないで元のドメインのままでプロセスが起動します。

具体的な例として Apache の httpd コマンドを使って、ドメイン遷移について説明します。
ユーザが手動で起動したWebサーバ (`/usr/sbin/httpd -DFORGROUND` など) と、systemctlなどのシステム経由で起動したWebサーバは、実行ファイルのパスが同じでも、起動したプロセスはそれぞれ異なるドメインで動作します。
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
sesearch コマンドのオプション `-T` (type Transition) を使ってドメイン遷移を検索すると、init_tドメインのプロセスが、httpd_exec_tタイプのファイルを実行すると、httpd_tドメインとしてプロセスが起動される、というルールが定義されています。

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


### タイプ遷移

ファイルやフォルダを作成したとき、そのタイプは親のディレクトリのタイプを継承します。
例えば、/var/logの下に foo/bar ディレクトリを作成して、baz ファイルを作成した場合、
作成した foo, bar, baz のセキュリティコンテキストには、var_log_t タイプが付与されます。
```bash
~]# ls -dZ /var/log
system_u:object_r:var_log_t:s0 /var/log

~]# mkdir -p /var/log/foo/bar
~]# ls -dZ /var/log/foo/bar
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar

~]# touch /var/log/foo/bar/baz
~]# ls -Z /var/log/foo/bar/baz
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar/baz
```

一方で、親のディレクトリのタイプを継承しない場合もあります。
事前にタイプ遷移のルールを定義しておくと、特定のドメインで動くプロセスが対象の下にディレクトリやファイルを作成した場合、その親のディレクトリのタイプを無視して、ルールに記述されているタイプを付与します。
このように、新規に作成したファイルやディレクトリのセキュリティコンテキストが、それを格納するディレクトリのタイプと異なることを**タイプ遷移** (Type Transition) といいます。
例えば、httpd_t ドメインのプロセスが、var_log_t ディレクトリにファイルを書き込むと、そのファイルは httpd_log_t タイプが付与されます。
```bash
~]# sesearch -T -s httpd_t -t var_log_t
type_transition httpd_t var_log_t:file httpd_log_t;
```

ここからはタイプ遷移の具体例として、Apache上で動くPHPが /var/log/foo/bar にファイルを追加するときに、var_log_t の代わりに httpd_log_t タイプが付与されることを確認します。

まず、Apacheユーザがファイルを追加できるようにディレクトリの権限を修正しておきます。

```bash
~]# chmod o+w /var/log/foo/bar
```

続いて、PHPファイルを作成して /var/log/の下にファイルを作成するスクリプトを用意します。

/var/www/html/test.php
```php
<?php
$myfile = "/var/log/foo/bar/baz_from_httpd";
touch($myfile);
echo "Update file: " . $myfile . "\n";
```

Web経由で test.php にアクセスすると、/var/log/の下にファイル「baz_from_httpd」が作成されます。
ls -Z で確認すると、作成されたファイルは、タイプ遷移のルールに従って httpd_log_t でラベル付けされました。

```bash
~]# curl localhost/test.php
Update file: /var/log/foo/bar/baz_from_httpd

~]# ls -Z /var/log/foo/bar/baz*
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar/baz
  system_u:object_r:httpd_log_t:s0 /var/log/foo/bar/baz_from_httpd
```

以上から、httpd_t ドメインのプロセスが var_log_t の下にファイルを作成した場合は、タイプ遷移のルールに従って var_log_t の代わりに httpd_log_t タイプが付与されることが確認できました。


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

chconコマンドは、一時的にファイルやディレクトリのセキュリティコンテキストを変更するためのツールです。
一時的というのは、本来あるべきセキュリティコンテキストとは違う状態になっていることを意味し、restorecon コマンドの実行や /.autorelabel ファイルの作成と再起動などでに元に戻る状態のことです。
なお、再起動しただけでは chcon で一時的に変えたセキュリティコンテキストは元に戻りません。

1つのファイルやディレクトリのタイプを変更するときは、`-t` (Type) でタイプを指定した後に、対象のパスを指定します。
```bash
~]# chcon -t httpd_sys_content_t /var/www/html/index.html
~]# chcon -t httpd_sys_rw_content_t /var/www/html/upload
```
ディレクトリの下の全てのタイプを変更するときは、`-R` (Recursive) オプションを追加して再帰的に動作するようにします。
```bash
~]# chcon -R -t httpd_sys_content_t /var/www/html
```

オブジェクトのセキュリティコンテキストに含まれるSELinuxユーザは、UBACが無効の場合は影響しませんが、UBACが有効の場合はアクセス制御に影響します。
chcon でオブジェクトのSELinuxユーザを変える場合は、`-u` (seUser) オプションでSELinuxユーザを指定します。
```bash
~]# ls -dZ /var/www/html/upload
unconfined_u:object_r:httpd_sys_rw_content_t:s0 /var/www/html/upload

~]# chcon -u system_u /var/www/html/upload

~]# ls -dZ /var/www/html/upload
system_u:object_r:httpd_sys_rw_content_t:s0 /var/www/html/upload
```

chcon は一時的にタイプを変更するので、テストでは chcon を使い、問題がなければ次に説明する semanage fcontext で永続的にタイプを変更するという作業の流れになります。

#### ファイルコンテキストの復元 (restorecon)

restorecon はSELinuxコンテキストをデフォルト値に復元するためのコマンドです。
restorecon コマンドを使うと、chcon で設定した一時的なコンテキストは消えて、コンテキストが元に戻ります。
```bash
~]# restorecon -v /var/www/html/upload
```

ディレクトリ下の全てのファイルに対しては、`-R` (Recursive) オプションで再帰的に復元させることができます。
```bash
~]# restorecon -R -v /var/www/html
```

#### ファイルコンテキストの永続的な変更 (semanage fcontext)

永続的にファイルやディレクトリのセキュリティコンテキストを変更するためのツールです。
SELinuxでは、ファイルコンテキストの永続的な変更に正規表現を使用してファイルやディレクトリのラベル付けを行います。
ラベル付けの一覧は、`-l` (List) オプションで確認できます。
```bash
~]# semanage fcontext -l
SELinux fcontext      type               Context

/                     directory          system_u:object_r:root_t:s0
/.*                   all files          system_u:object_r:default_t:s0
/[^/]+                regular file       system_u:object_r:etc_runtime_t:s0
...
/afs                  directory          system_u:object_r:mnt_t:s0
/bacula(/.*)?         all files          system_u:object_r:bacula_store_t:s0
/bin                  all files          system_u:object_r:bin_t:s0
/bin/.*               all files          system_u:object_r:bin_t:s0
/bin/alsaunmute       regular file       system_u:object_r:alsa_exec_t:s0
/bin/bash             regular file       system_u:object_r:shell_exec_t:s0
/bin/bash2            regular file       system_u:object_r:shell_exec_t:s0
...
```

永続的にファイルやディレクトリのセキュリティコンテキストを変更するルールを追加するには、`-a` (Add) オプションを追加し、-t で設定したいタイプ、最後にマッチさせたいパスの正規表現を指定します。
ルールを追加しただけでは、ファイルやディレクトリのタイプは変更されないので、restorecon コマンドを使ってルールを適用します。
```bash
~]# semanage fcontext -a -t httpd_sys_content_t "/var/test_www(/.*)?"
~]# restorecon -Rv /var/test_www
```
修正する場合は、`-m` (Modify) オプションで修正します。
```bash
~]# semanage fcontext -m -t httpd_sys_rw_content_t "/var/test_www(/.*)?"
~]# restorecon -Rv /var/test_www
```
削除する場合は、`-d` (Delete) オプションで削除します。ファイルコンテキストも元に戻すには、続けて restorecon を実行します。
```bash
~]# semanage fcontext -d "/var/test_www(/.*)?"
~]# restorecon -Rv /var/test_www
```

対象のディレクトリ下のラベル付けルールを、別のディレクトリ下と完全に同じにする場合は、`-e` (Equivalence) オプションでコピー元とコピー先を指定します。
例えば、以下のように、/var/www 下のルールを /var/test_www 下にも適用した場合、/var/www/html/upload と /var/test_www/html/upload のラベルは同じになります。
```bash
~]# semanage fcontext -a -e /var/www /var/test_www
~]# semanage fcontext -l
...
SELinux Local fcontext Equivalence

/var/test_www = /var/www
```

また、ファイルのマッチに使用した正規表現が適切だったかを確認するための matchpathcon コマンドもあります。
matchpathcon は、semanage fcontextに設定した正規表現にマッチするかを確認するためのツールです。
```bash
~]# matchpathcon /var/test_www/html/upload
/var/test_www/html/upload       system_u:object_r:httpd_sys_content_t:s0
```

semanage を使わないでファイルコンテキストの永続的な変更をする方法もあります。
再起動時にファイルシステム全体を再度ラベル付けする場合は、ルートディレクトリに「.autorelabel」という名前の空ファイルを作成し、再起動 (reboot) することで再ラベル付けが実施されます。
```bash
~]# touch /.autorelabel
~]# reboot
```



### ポートのラベリング (semanage port)

TODO:

https://tex2e.github.io/blog/linux/semanage-port

一覧表示
```bash
~]# semanage port -l
```

追加
```bash
~]# semanage port -a -t <TYPE> -p <tcp|udp> <PORT>
~]# semanage port -m -t <TYPE> -p <tcp|udp> <PORT>
```

削除
```bash
~]# semanage port -d -t <TYPE> -p <tcp|udp> <PORT>
```

### Boolean (semanage boolean)

Boolean は SELinux のポリシーを管理するためのフラグで、Onにするだけで関連する複数のルールが有効化されます。
Boolean の一覧は semanage コマンドを使って表示することができます。

```bash
~]# semanage boolean -l
SELinux boolean                State  Default Description
abrt_anon_write                (off  ,  off)  Allow abrt to anon write
abrt_handle_event              (off  ,  off)  Allow abrt to handle event
abrt_upload_watch_anon_write   (on   ,   on)  Allow abrt to upload watch anon write
antivirus_can_scan_system      (off  ,  off)  Allow antivirus to can scan system
antivirus_use_jit              (off  ,  off)  Allow antivirus to use jit
auditadm_exec_content          (on   ,   on)  Allow auditadm to exec content
authlogin_nsswitch_use_ldap    (off  ,  off)  Allow authlogin to nsswitch use ldap
...
```

Boolean の値は on か off のどちらかです。
Boolean の値を設定するには、setsebool コマンドを使用して Boolean 名と on または off を指定します。
例えば、httpd_can_network_connect という Boolean を一時的に有効化するには次のコマンドを実行します。一時的に設定した場合は、再起動するとデフォルトに戻ります。
```bash
~]# setsebool httpd_can_network_connect on
```
永続的に設定したい場合は、`-P` (Permanent) オプションを追加して実行します。
-P オプションを指定した場合は、ポリシーの再ビルドが発生するので、設定の反映が完了するまで若干時間がかかります。
```bash
~]# setsebool -P httpd_can_network_connect on
```

#### Booleanの影響範囲を調べる

対象の Boolean を on にする前に、その Boolean によってどんな許可ルールが有効化されるのか確認するには、sesearch コマンドを使います。
sesearch コマンドに `-b` (Boolean) オプションを使うと、Boolean の影響範囲を出力することができます。

```bash
~]# sesearch -A -b httpd_can_network_connect
...
allow httpd_sys_script_t port_type:tcp_socket name_connect; [ httpd_can_network_connect && httpd_enable_cgi ]:True
allow httpd_sys_script_t port_type:tcp_socket { recv_msg send_msg }; [ httpd_can_network_connect && httpd_enable_cgi ]:True
allow httpd_sys_script_t port_type:udp_socket recv_msg; [ httpd_can_network_connect && httpd_enable_cgi ]:True
allow httpd_sys_script_t port_type:udp_socket send_msg; [ httpd_can_network_connect && httpd_enable_cgi ]:True
allow httpd_t port_type:tcp_socket name_connect; [ httpd_can_network_connect ]:True
```


#### 役立つBooleanの一覧

* httpd
  - httpd_can_network_connect :
  httpdのスクリプト (PHPなど) がネットワークにTCP接続するのを許可する。デフォルトは off
  - httpd_can_network_connect_db :
  httpdのスクリプト (PHPなど) がネットワークのDBのポートに接続するのを許可する。デフォルトは off
  - httpd_can_connect_ldap :
  httpdがLDAPポートに接続するのを許可する。デフォルトは off
  - httpd_can_sendmail :
  httpdがメールを送信するのを許可する。デフォルトは off
  - httpd_can_network_relay
  httpdがリバースプロキシとして動作するのを許可する。デフォルトは off
  - httpd_enable_cgi :
  httpdが httpd_sys_script_exec_t タイプを付けた実行ファイルをCGIが実行するのを許可する。デフォルトは on
  - httpd_enable_homedirs :
  httpdがユーザのホームディレクトリにアクセスするのを許可する。デフォルトは off
  - httpd_tmp_exec :
  httpdが /tmp でファイルを実行するのを許可する。デフォルトは off
* tomcat
  - tomcat_can_network_connect_db :
  TomcatがネットワークのDBに接続するのを許可する。デフォルトは off
* named (DNS)q
  - named_tcp_bind_http_port :
  DNSがHTTPポートで接続を待ち受けるのを許可する。DNS over HTTPSなどの対応。デフォルトは off
  - named_write_master_zones :
  動的DNSでマスターゾーンファイルを編集するのを許可する。デフォルトは on
* mysql
  - mysql_connect_http :
  MySQLがネットワークにHTTP接続するのを許可する。デフォルトは off
  - mysql_connect_any :
  MySQLがネットワークのすべてのポートに接続するのを許可する。デフォルトは off
* postgresql
  - postgresql_can_rsync :
  PostgreSQLが復旧のためにsshとrsyncを使用することを許可する。デフォルトは off
* sshd
  - ssh_sysadm_login :
  sysadm_rロールに所属するユーザが、sshログインするのを許可する。デフォルトは off
* nfs
  - nfs_export_all_ro :
  VFS経由でエクスポートされる全てのファイルとディレクトリを読み取り専用にする。デフォルトは on
  - nfs_export_all_rw :
  VFS経由でエクスポートされる全てのファイルとディレクトリを読み書き可能にする。デフォルトは on
* その他
  - deny_ptrace :
  ptraceコマンドを実行するのを拒否する。デフォルトは off
  - deny_bluetooth :
  Bluetoothの使用を拒否する。デフォルトは off



### ユーザの管理 (semanage login)

SELinuxユーザは、Linuxユーザとは別にあり、ユーザのセキュリティコンテキストを保持するために使用するものです。
SELinuxユーザとLinuxユーザを対応関係を表示するには、semanage login -l コマンドを実行します。

```bash
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
example.user         staff_u              s0                   *
```

- Login Name : Linuxユーザでのログイン名。ルールにマッチしないその他の全てのLinuxユーザは `__default__` になります
- SELinux User : Linuxユーザに対応付けされたSELinuxユーザ名
- MLS/MCS Range : Linuxユーザに対応付けされたレベル
- Service : Linuxユーザがログイン時に使用するサービス

SELinuxユーザの対応関係を追加するには、`-a` (Add) オプションでSELinuxとLinuxユーザを指定します。
```bash
~]# semanage login -a -s user_u user1
```
追加されているSELinuxユーザの対応関係を修正するには、`-m` (Modify) オプションで修正後を内容を設定します。
```bash
~]# semanage login -m -s staff_u user1
```
対応関係から削除するには、`-d` (Delete) オプションでLinuxユーザを指定します。
```bash
~]# semanage login -d user1
```

#### ユーザのレベル

SELinuxのユーザ一覧を表示すると「MLS/MCS Range」という列があります。
これはレベル (Level) と呼ばれるもので、そのユーザの機密レベルとカテゴリセットをを表しており、「s0-s0:c0.c1023」という形式で記述されます。

レベルには、MLS (Multi Layer Security) とMCS (Multi Category Security) の2つの属性が含まれています。
表示される形式は「MLS範囲:カテゴリーセット」です。
情報セキュリティの文脈を考慮すると、資産の分類結果に基づいてサブジェクトに付与したものがMLS範囲、資産のカテゴリ化結果に基づいてサブジェクトに付与したものがカテゴリーセットです。

MLS範囲は、サブジェクトが所持しているクリアランスレベルの範囲を示します。
MLS範囲は「低レベル-高レベル」と表され、s0-s0 のときは s0 と同じです。
カテゴリセットは、サブジェクトがアクセスを許可されているカテゴリの一覧です。
カテゴリセットは「c0,c1,c2,c3」と表されます。
また、カテゴリが連続している場合は「c0.c3」のように、ドットを使って範囲を示します。
カテゴリは1024種類まで対応しています。
例えば、レベルが「s0-s0:c0.c1023」のときは、機密性レベル s0 かつ、c0～c1023 のカテゴリに対してアクセスが許可されます。

SELinux では MLS はデフォルトで無効化されているので、使用したい場合は selinux-policy-mls パッケージをインストールして、MLS をデフォルトの SELinux ポリシーとして設定します。
MLS が無効の場合、すべてのSELinuxユーザはデフォルトのレベルである s0-s0:c0.c1023 が割り当てられます。

```bash
~]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

#### SELinuxのロール

- **user_r** : 制限されたロール。このロールに属するSEユーザは、エンドユーザのアプリケーションしか実行できないです。権限昇格などは使用できないため、管理者の操作をしたい場合は別のアカウントで再度ログインしなおす必要があります
- **staff_r** : ユーザの切り替えができる制限されたロール。このロールに属するSEユーザは、newroleコマンドによるロールの切り替えができます。対応するLinuxユーザは wheel グループに所属していても管理者権限を使うことはできません (dac_override で拒否されます)。 /etc/sudoers を編集すれば管理者権限も使用できるようになります
- **sysadm_r** : システム管理者ロール。システム全体を操作できる非常に高い権限を持ちます。このロールに所属するSEユーザは、対応するLinuxユーザを管理者権限のグループ wheel などに追加しておくことで管理者権限を使用することができます
- **secadm_r** : セキュリティ管理者ロール。このロールに属するSEユーザは、SELinuxのポリシーの変更とコントロールの操作ができます。
システム管理者とシステムポリシー管理者の職務の分離をするために使用します
- **system_r** : デーモンやサービスのプロセスに割り当てられるロール。システム管理者ほどではないですが、デーモンやサービスの稼働に必要な高い権限を持ちます

unconfined_r : 制限のないロール。このロールに属するユーザは、すべてのアクションがSELinuxに制限されません


#### オブジェクトのロール (コラム)

セキュリティコンテキストとは、SELinuxのユーザ、ロール、タイプの3つのセキュリティ属性をまとめたものです。
SELinuxでは、処理の高速化のために、セキュリティコンテキストにSID (セキュリティID) と呼ばれる一意の整数値を割り当てて識別します。
サブジェクトは能動的で様々なロールを持つことができますが、オブジェクトは受動的なのであまりロールを必要としません。
ただし、全てのサブジェクトとオブジェクトには3つのセキュリティ属性を持つセキュリティコンテキストを割り当てないといけないので、ロールが不要なオブジェクトには、ダミーのロール object_r が付与されています。

```bash
~]# ls -Z /etc/passwd
system_u:object_r:passwd_file_t:s0 /etc/passwd
```

TODO:

https://tex2e.github.io/blog/linux/selinux-user

https://tex2e.github.io/blog/linux/selinux-user-mapping



### ポリシーモジュールの管理 (semodule)

SELinuxポリシーは、複数のポリシーモジュールから構成されています。
ポリシーモジュール (Policy Module) は、複数のポリシールールをまとめたもので、モジュール毎に有効化/無効化をすることができます。
また、ポリシーモジュールは自作することもできます。
現在読み込まれているポリシーモジュールの一覧を表示するには、semodule コマンドを `-l` (List) オプションで実行します。
```bash
~]# semodule -l
```
ポリシーモジュールの優先度や現在の状態 (有効/無効) などのより詳細な情報を表示するには、オプションを -lfull にして実行します。
```bash
~]# semodule -lfull
```
自分で作成したポリシーモジュールをSELinuxに読み込むには、semodule -i コマンドを使用します。
```bash
~]# semodule -i myrule.pp
```
ポリシーモジュールを読み込む際は、ルールを適用する優先度を設定できます。
優先度は -X オプションで指定し、1～999 の値を設定できます。
同じ名前のポリシーモジュールでも優先度が異なる場合は、別々で登録されます。
同じ名前のポリシーモジュール名で既存の優先度よりも大きい値を設定した場合は、優先度の大きいモジュールだけが有効になり、優先度の小さいモジュールは無効になります。
```bash
~]# semodule -i myrule.pp -X 500
```
登録したポリシーモジュールを削除したい場合は、`-r` (Remove) オプションで削除します。
同じ名前で複数の優先度が存在する場合は、-X で優先度も指定します。
```bash
~]# semodule -r myrule.pp -X 500
```
登録したポリシーモジュールを削除しないが無効化したい場合は、`-d` (Disable) オプションを使います。
```bash
~]# semodule -d myrule.pp
```
無効化したポリシーモジュールを有効化したい場合は、`-e` (Enable) オプションを使います。
```bash
~]# semodule -e myrule.pp
```

#### audit2allow

SELinuxが特定のアクションを拒否した場合、拒否ログは監査ログ /var/log/audit/audit.log に記録されます。
audit2allow コマンドは、SELinuxが特定のアクションを拒否しないように、拒否ログの内容から許可ルールを含むポリシーモジュールパッケージ (.pp) を作成します。
作成したポリシーモジュールパッケージを semodule -i で読み込み、ポリシーモジュールを作成することによって、特定のアクションは SELinux によって拒否されなくなります。

例えば、監査ログに次の拒否ログが記録されていた場合に、audit2allow を使って自作ポリシーモジュールを作成する例を紹介します。
```
type=AVC msg=audit(0000000000.612:355): avc:  denied  { name_connect } for  pid=3297 comm="curl" dest=80 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0
```
上記の拒否ログは、httpd_t ドメインのプロセスが外部の http_port_t (80番) ポートに接続を試みたので拒否した、ということを示しています。
この拒否ログの1行をコピーして、次のコマンドの `<拒否ログ>` の部分に貼り付けて実行すると、TE形式の許可ルールが出力されます。

```bash
~]# echo '<拒否ログ>' | audit2allow

#============= httpd_t ==============
#!!!! This avc can be allowed using one of the these booleans:
#     httpd_can_network_connect, httpd_graceful_shutdown, httpd_can_network_relay, nis_enabled
allow httpd_t http_port_t:tcp_socket name_connect;
```

出力結果を見ると、httpd_t ドメインが http_port_t ポートに接続できるルールが出力されました。
その許可ルールの上に、注意書きがあり、内容を読むと「この許可ルール (AVC) は次の Boolean を on にしても有効化されます：httpd_can_network_connect, ...」と書かれています。
一般的に、httpd_t ドメインがネットワークに接続したい場合は、`setsebool -P httpd_can_network_connect on` を実行して、httpd_can_network_connect という Boolean を on にするだけで接続できるようになります。
ただし、ここでは自作ポリシーモジュールの作成についての説明をするため、Boolean を使わない方法で進めていきます。

audit2allow で出力された許可ルールが問題ないことを確認したら、続いて `-M` (Module) オプションで作成するポリシーモジュール名を指定します。
ポリシーモジュール名は、自作であることがわかるように、モジュール名の先頭に my や custom などの文字列の追加が推奨されます。
次のコマンドを実行すると、ポリシーモジュールパッケージ myrule.pp と、TE形式のルール muryle.te がファイルに保存されます。

```bash
~]# echo '<拒否ログ>' | audit2allow -M myrule

******************** IMPORTANT ***********************
To make this policy package active, execute:
semodule -i myrule.pp
```

余談ですが、audit2allow -M でポリシーモジュールパッケージを作成する際に、`-D` (Dontaudit) を追加すると Allow ルールの代わりに Dontaudit ルールでポリシーモジュールパッケージを作成します。
主に、監査ログを埋めつくすけど重要ではない拒否ログを、拒否したまま監査ログに残さないようにするために使用します。
```bash
~]# echo '<拒否ログ>' | audit2allow -M -D myrule
```

最後に、保存されたポリシーモジュールパッケージを、semodule -i でSELinuxポリシーに読み込んでポリシーモジュールを作成し、ルールを適用します。
```bash
~]# semodule -i myrule.pp
```

audit2allow と semodule で自作ポリシーモジュールを作成することで、自身の環境だけに適用する許可ルールを追加することができます。


#### ポリシーモジュールパッケージの内容を確認する

ポリシーモジュールパッケージはバイナリファイルのため、そのままでは中身を確認することができません。
そこで /usr/libexec/selinux/hll/pp コマンドを使用して CIL 形式で表示することで中身を確認することができます。
/usr/libexec/selinux/hll/pp コマンドの使い方は、cat で表示した .pp ファイルの内容をパイプで渡してあげるだけです。
```bash
~]# cat myrule.pp | /usr/libexec/selinux/hll/pp

(typeattributeset cil_gen_require http_port_t)
(typeattributeset cil_gen_require httpd_t)
(allow httpd_t http_port_t (tcp_socket (name_connect)))
```


#### ポリシーモジュールの作成

ポリシーモジュールは自分で作成することができます。
例えば、tomcat_t ドメインのプロセスが、外部とネットワーク通信をしたときに、Auditallowルール (許可するがログは残す) を適用するというポリシーモジュールを作成してみます。
まず、my_tomcat_policy.te を作成して内容を以下のように記述します。

my_tomcat_policy.te
```conf
module my_tomcat_policy 1.0.0;
require {
        type tomcat_t;
        class tcp_socket *;
        class udp_socket *;
        class rawip_socket *;
}
auditallow tomcat_t self:{ tcp_socket udp_socket rawip_socket } *;
```

作成したTEファイルは checkmodule コマンドと、semodule_package コマンドを使用して、ポリシーモジュールパッケージに変換します。

```
TE形式のポリシールール (.te) => バイナリポリシーモジュール (.mod) => ポリシーモジュールパッケージ (.pp)
```

TEファイルからポリシーモジュールパッケージに変換 (コンパイル) するには、以下のコマンドを順番に入力します。

```bash
~]# checkmodule -M -m -o my_tomcat_policy.mod my_tomcat_policy.te
~]# semodule_package -o my_tomcat_policy.pp -m my_tomcat_policy.mod
~]# semodule -i my_tomcat_policy.pp
```

自作ポリシーモジュールが登録されているかを確認するには、semodule -lfull でモジュール一覧を表示することで有効かを確認できます。
```bash
~]# semodule -lfull | grep my_tomcat_policy
```


#### ポリシールールのタイプと属性

SELinux のポリシールールには、主に Type (タイプ) と Attribute (属性) の2種類があります。
Type はセキュリティコンテキストのタイプで、Attribute は Type が持つ属性を表したものです。
ルールで Attribute を使うことで、Type だけ異なる複数のルールを1つにまとめることができます。

特定の Attribute に所属する Type の一覧を表示するには、seinfo コマンドの `-a` (Attribute) で属性を指定し、`-x` (Explain) で属性に所属するタイプの一覧を表示させます。

```bash
~]# seinfo -a initrc_domain -x
Type Attributes: 1
   attribute initrc_domain;
        cluster_t
        condor_startd_t
        init_t                  <-- initrc_domain属性の中にinit_tタイプ
        initrc_t
        kdumpctl_t
        openshift_initrc_t
        piranha_pulse_t

~]# seinfo -a direct_init_entry -x
Type Attributes: 1
   attribute direct_init_entry;
        NetworkManager_exec_t
        abrt_exec_t
        abrt_upload_watch_exec_t
        ...
        hsqldb_exec_t
        httpd_exec_t             <-- direct_init_entry属性の中にhttpd_exec_tタイプ
        httpd_rotatelogs_exec_t
        ...
```

逆に、特定の Type が所属する Attribute の一覧を表示することもできます。
表示するには、`-t` (Type) でタイプを指定し、`-x` (Explain) でタイプが所属する属性の一覧を表示させます。

```bash
~]# seinfo -t init_t -x
Types: 1
   type init_t, can_relabelto_shadow_passwords, nsswitch_domain, 
   can_change_object_identity, can_change_process_identity, 
   can_change_process_role, can_dump_kernel, can_load_kernmodule, 
   can_load_policy, can_setbool, corenet_unlabeled_type, domain, 
   fixed_disk_raw_read, fixed_disk_raw_write, kernel_system_state_reader, 
   memory_raw_read, named_filetrans_domain, netlabel_peer_type, 
   initrc_transition_domain, initrc_domain, syslog_client_type, 
   pcmcia_typeattr_1, can_relabelto_binary_policy;

~]# seinfo -t httpd_exec_t -x
Types: 1
   type httpd_exec_t alias phpfpm_exec_t, entry_type, exec_type, file_type, 
   non_auth_file_type, non_security_file_type, direct_init_entry;
```


### ログと監査

SELinuxのポリシールールに違反するアクションが実行されると、SELinuxはそのアクションを拒否すると同時に、拒否ログを出力します。
ログの出力先は、システムやauditdサービスの起動状況によって変わります。

1. カーネル起動時のSELinuxのログ出力先は、/var/log/dmesg
2. auditd サービスが起動していないときのSELinuxのログの出力先は、/var/log/messages
3. auditd サービスが起動しているときのSELinuxのログの出力先は、/var/log/audit/audit.log

#### 監査ログの読み方

ログに記録される拒否ログは、AVCログとも呼ばれます。
拒否ログのそれぞれの属性値は、次の意味を表しています。

- **type=** : auditイベントの種類。SELinuxでは以下の2種類があります。
  - type=AVC : カーネル空間で生成したログ
  - type=USER_AVC : ユーザ空間で生成したログ
- **msg=** : auditイベントID。`msg=audit(UNIXTIME時刻:シリアル番号)` の形式で示されます。複数のauditイベントのシリアル番号が同じ場合は、それらが関連性のある一連のauditイベントであることがわかります。
- result : アクセスを拒否したときは denied、auditallowルールで許可ログを出力するときは granted です。
- access_vector : オブジェクトマネージャによって識別したアクション。read, write, exec など
- pid=, **comm=** : タスクの場合は、実行したプロセスのプロセスIDと、実行したコマンドのパス名
- dev=, **ino=**, **path=** : アクセス対象のリソースを管理するデバイス番号と、inode番号、パス名
  - ino= : inode番号からアクセス先のファイルの場所は、`find / -inum <inode番号>` で調べることができます
  - path= : パス名はアクションによってログに記録されない場合があります
- **name=** : アクセス対象のファイル名や、ディレクトリ名 (この属性はログに含まれない場合もある)
- **scontext=** : アクセス元 (サブジェクト) のセキュリティコンテキスト
- **tcontext=** : アクセス先 (オブジェクト) のセキュリティコンテキスト
- **tclass=** : アクセス先のオブジェクトのクラス。file, dir, tcp_socket など
- permissive= : SELinuxがPermissiveで動作したか (検知したが拒否しないモードか有効化されていたか)

それでは実際の拒否ログを使いながら、ログの属性値を参考に、拒否ログを読み解くための手順について紹介します。
まず、監査ログに記録された拒否ログは以下のようなものでした。
```
type=AVC msg=audit(1558865501.958:282): avc:  denied  { write } for  pid=1647 comm="httpd" name="upload" dev="dm-0" ino=33584792 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```
この拒否ログについて、拒否ログの属性値から情報を収集していきます。
1. `denied` から、SELinuxが何らかのアクションを拒否したことがわかります。
2. `tclass=dir` と `{ write }` から、ディレクトリへの書き込みが拒否されたことがわかります。
3. `ino=33584792` から、`find / -inum 33584792` で対象のパスを検索し、オブジェクトの場所を確認します (ここでは検索結果が /var/www/html だとします)。
4. `scontext=...:httpd_t:...` から、上記のアクションを実行したプロセスは「httpd_t」ドメインで動作していたことがわかります。
5. `tcontext=...:httpd_sys_content_t:...` から、対象のディレクトリ /var/www/html のタイプは「httpd_sys_content_t」であったことがわかります。
6. `msg=audit(1558865501.958:282)` から数字の 1558865501 をUNIX時刻からローカル時刻に変換して、取得した時刻 2019/5/26 19:11:41 から拒否ログ発生時刻を特定します。
7. まとめると、拒否ログは「時刻 2019/5/26 19:11:41 に httpd_t ドメインのプロセスが /var/www/html のディレクトリに書き込みを試みたが、httpd_t は httpd_sys_content_t への書き込み権限が許可されていないため拒否された」という意味になります。

以上が拒否ログを読むための大まかな手順になります。
さらに様々な種類の拒否ログを読むためには、tclass のオブジェクトクラスの種類 (file, dir, tcp_socket, ... など) と、アクションの種類 (read, write, exec, ... など) を理解する必要があります。
オブジェクトクラスとアクションの対応関係の詳細は、[SELinux Notebook](https://github.com/SELinuxProject/selinux-notebook) に書かれています。
特に以下のページでは、全てのオブジェクトクラスとアクションについての説明が書かれているので、不明なオブジェクトクラスやアクションが現れた場合は、ここを確認するのをおすすめします。

- [Appendix A - Object Classes and Permissions \| SELinuxProject/selinux-notebook](https://github.com/SELinuxProject/selinux-notebook/blob/main/src/object_classes_permissions.md)


#### Dontauditルール

SELinuxのログ出力では、許可するがログも記録する Auditallow ルールと、拒否してもログが記録されない Dontaudit ルールが存在します。
それぞれのルールの個数は seinfo で確認することができます。

```bash
~]# seinfo | grep audit:
  Auditallow:          164    Dontaudit:         10355
```

Dontaudit ルールが有効になっていると、SELinuxが拒否してもログに出力されないため、デバッグ時の原因調査が困難になります。
一般的には、影響の少ない拒否ログがログを埋め尽くさないように (ノイズが増えないように) Dontaudit ルールを有効にすべきですが、デバッグ時は無効化したいです。
Dontaudit ルールを無効にして拒否ログを出力させるには、semodule コマンドに `-D` (Disable dontaudit) と `-B` (Build) オプションの両方を入れて実行します。

```bash
~]# semodule -DB
```

Dontaudit ルールを再度有効化するには、-B オプションだけで実行します。

```bash
~]# semodule -B
```


### SELinuxのアーキテクチャ

TODO:

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-high-level-arch.png" width=800px />
<figcaption>SELinuxのアーキテクチャ</figcaption>
</figure>




---

[PRIV](./1-access-control) \| [NEXT](./3-selinux-practice)
