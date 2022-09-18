---
layout:        book
title:         "2. SELinux入門"
menutitle:     "2. SELinux/SELinux入門"
date:          2022-02-27
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap: true
# feed: true
description:   "SELinux入門 第2章 SELinuxの使い方"
section_number: 2
sections:
  - [./1-access-control, セキュリティとアクセス制御]
  - [./2-selinux-intro, SELinux入門]
  - [./3-selinux-practice, SELinux実践]
---


### SELinuxの概要

SELinuxは、Linuxの任意アクセス制御 (DAC) に加えて強制アクセス制御 (MAC) 方式でアクセスを制御するシステムです。
ゼロデイ攻撃などのソフトウェアの脆弱性を悪用した攻撃からシステムを守るための仕組みを提供します。
SELinuxにはログと監査の機能が含まれており、不正なアクセスや権限昇格を検知することができます。
MACの制御下では、限られた許可しかないサンドボックス中でそれぞれのプログラムが実行されます。
そのため、攻撃者にプログラムの脆弱性を利用されても、侵害の影響範囲をそのプログラムに与えられた権限の範囲内だけに抑えることができます。
LinuxはDACというアクセス制御方式を利用していますが、SELinuxのMACは以下の点でLinuxのDACよりも優れています。

 * ユーザやプロセスにもルールを適用できる（DACではユーザにしか適用できない）
 * 所有者はオブジェクトのルールの変更を制限される（DACでは所有者が権限を変更できる）
 * ネットワークソケットやBloutoothなどのデバイスにもルールを適用できる

SELinuxは、各プロセスにドメインと呼ばれるラベルを付与して、サンドボックスを割り当てることでアクセス制御を行います。
各ドメインでは、必要最小限の機能は実行できますが、それ以外は拒否するルールセットが定義されています。
アクセスできるファイルはドメインごとに制限されており、自身のドメインに関係ないファイルへの読み書きは拒否されます。

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/1-type.png" width=450px />
<figcaption>各プロセスがアクセスできる範囲を制限するSELinuxの例</figcaption>
</figure>

SELinuxでは、このようなアクセス許可・拒否を判断するためにファイルごとにセキュリティコンテキストというラベルが付けられています。
それぞれのセキュリティコンテキストには、末尾が `_t` で表される**タイプ**と呼ばれる属性情報が含まれます。
タイプは、オブジェクトだけではなく、サブジェクトにも割り当てられます。
特に、プロセスに割り当てられるタイプのことを**ドメイン**と呼びます。
ドメインは、特定のタイプへのアクセス許可が与えられていなければ、そのファイルやディレクトリにアクセスすることはできません。

なお、インストール初期状態のSELinuxはデフォルトでルールを定義しているため、独自のディレクトリ構成で運用をしない限り、自分でファイルやディレクトリに対してラベル付けをする必要はほとんどありません。
新たなサービスを起動する際も、yumやdnfを使用してインストールし、systemctlを使用して起動すれば、自動的にファイルやディレクトリ、プロセスに対してラベル付けが行われます。
もし、独自のディレクトリ構成で運用したい場合や、SELinuxのポリシーが拒否してしまうパッケージの新機能を使いたい場合は、SELinuxのポリシーをコマンド経由で自分で修正することも可能です。


### DACとMACのアクセス制御順

LinuxはDAC (任意アクセス制御) というアクセス制御の仕組みがあり、これはSELinuxのMAC (強制アクセス制御) と共に利用できます。
アクセス許可・拒否の判定は、まず先にLinuxのDACで判定を行い、その後にSELinuxのMACで判定を行います。
サブジェクトがオブジェクトにアクションできるときは、LinuxのDACとSELinuxのMACの両方が許可されている場合だけです。
つまり、以下のルールで判断されます。

 * DACがアクションを禁止すれば、そのアクションは禁止されます。
 * DACがアクションを許可しても、MACがアクションを禁止すれば、そのアクションは禁止されます。
 * DACがアクションを許可して、MACもアクションを許可したとき、そのアクションは許可されます。

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

SELinuxはサブジェクトとオブジェクトの両方のセキュリティコンテキストに基づいてアクセス許可を判断します。
これらのセキュリティコンテキストは、SELinuxのポリシールールで定義されています。

**ドメイン**は、プロセスのセキュリティコンテキストのことです。
SELinuxのMACがアクセス許可を判断する際は、セキュリティコンテキストだけを使用します。
ドメインと同様に全てのユーザも、SELinuxによってセキュリティコンテキストが付けられています。
例として、現在のユーザとApacheプロセスのセキュリティコンテキストを確認すると以下のようになります。

```bash
~]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

~]$ ps -eZ | grep httpd
system_u:system_r:httpd_t:s0       1637 ?        00:00:00 httpd
```

セキュリティコンテキストは区切り文字 `:` で各項目に分かれており、それぞれ以下の意味を持ちます。

 1. 項目の1番目はSELinuxユーザ (SEUser) を表します。Apacheには、system_uユーザが割り当てられています。なお、SELinuxのユーザ管理は、Linuxが /etc/passwd で管理するユーザのリストを使用していません。代わりに、SELinuxユーザとLinuxユーザを結びつけるための独自のデータベースとマッピングを使用します。
 2. 項目の2番目はSELinuxロール (Role) を表します。Apacheは、system_rロールという役割が割り当てられています。
 3. 項目の3番目はSELinuxタイプ (Type) を表します。プロセスに付与したタイプはドメインと呼びます。Apacheは、httpd_tドメインが割り当てられています。なお、タイプをサブジェクトに付与してもオブジェクトに付与しても機能は同じですが、サブジェクトに付与するときは「ドメイン」、オブジェクトに付与するときは「タイプ」と呼びます。
 4. 項目の4番目は機密度レベルを表します。MLSを有効化している場合のみ使用します。例えば「s0-s0:c0.c1023」が設定されます。

SELinuxはサブジェクトとオブジェクトのセキュリティコンテキストを用いて、アクション許可を判断します。
ポリシールールのほとんどは、SELinuxユーザとSELinuxロールを使用しておらず、SELinuxタイプ (またはドメイン) のみで作成されているため、最も重要なフィールドは3番目のSELinuxタイプだけです。
すべてのプロセスとすべてのオブジェクトにラベル付けを行い、プロセスに対してアクセス制御をする仕組みを**Type Enforcement** (**型強制**) といいます。
Type Enforcementを使用することで、SELinuxはアプリケーションやサービスの機能を制御し、よりセキュアな環境を維持することができます。

#### 制限のないプロセス (Unconfined Process)

制限のないドメインは、SELinuxのMACの制限を受けません。LinuxのDACのアクセス制御の制限だけを受けます。
制限のないプロセスは例えば、カーネルで実行されるプロセスのドメイン kernel_t、制限のないサービスのドメイン unconfined_service_t、制限のないユーザのドメイン unconfined_t などがあります。


### ドメイン遷移 (Domain Transition)

特定のドメインがプログラムを実行した際に別のドメインに遷移することを**ドメイン遷移** (Domain Transition) といいます。
例えば、systemd (init_t ドメイン) が /usr/sbin/httpd (httpd_exec_t) を実行すると、起動したプロセスには httpd_t ドメインが割り当てられます。
ドメイン遷移をするためには、以下の複数のポリシールールが必要です。

 1. サブジェクトのドメインから別のドメインへの遷移ルール。
 2. サブジェクトのドメインから別のドメインへの遷移を許可するルール。
 3. サブジェクトのドメインが、プロセスを起動するファイルの実行を許可するルール。
 4. 別のドメインに遷移するときにプロセスを起動するファイルを限定するルール (allow entrypoint)。

ドメイン遷移に必要なポリシールールは、以下のコマンドで確認することができます。
なお、遷移 (transition) の権限は process クラス、実行 (execute) の権限は file クラスに紐づいています。

```bash
# init_tからhttpd_tドメインに遷移するルール
~]# sesearch -T -s init_t -c process | grep httpd_t
type_transition init_t httpd_exec_t:process httpd_t;
~]# sesearch -A -s init_t -t httpd_t -c process -p transition
allow initrc_domain daemon:process transition;

# init_tドメインが実行できるファイルのタイプ
~]# sesearch -A -s init_t -t httpd_exec_t -c file -p execute
allow initrc_domain direct_init_entry:file { execute getattr map open read };

# httpd_tドメインとして起動できるエントリーポイント
~]# sesearch -A -s httpd_t -t httpd_exec_t -c file -p entrypoint
allow httpd_t httpd_exec_t:file { entrypoint execute execute_no_trans getattr ioctl lock map open read };
```

コマンドの結果に含まれている initrc_domain と daemon と direct_init_entry はタイプでなく属性です。
末尾が `_t` であればタイプですが、それ以外の場合は属性です。
属性 (Attribute) は、タイプが持つ属性を表したもので、複数のルールを1つにまとめるために使用します。

`seinfo -a` コマンドで確認すると、initrc_domain 属性の中には init_t タイプが存在し、daemon 属性の中には httpd_t タイプが存在し、direct_init_entry 属性の中には httpd_exec_t タイプが存在します。
そのため、ここでは initrc_domain 属性を init_t、タイプ、daemon 属性を httpd_t タイプ、direct_init_entry 属性を httpd_exec_t に読み替えることにします。

```bash
~]# seinfo -a initrc_domain -x
Type Attributes: 1
   attribute initrc_domain;
        ...
        init_t
        ...

~]# seinfo -a daemon -x
Type Attributes: 1
   attribute daemon;
        ...
        httpd_t
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
               (3) transition
    init_t ---------------------> httpd_t
       |                     ^
       |                     | (2) entrypoint
       |   (1) execute       |
       +----------------> httpd_exec_t
```

ドメイン遷移に必要な上記の4つのルールをすべて満たしているときに、ドメイン遷移を実施することができます。
それ以外の場合は、ドメイン遷移が必要なアプリケーションの実行に失敗するか、ドメイン遷移しないで元のドメインのままでプロセスが起動します。

具体的な例として Apache の httpd コマンドを使って、ドメイン遷移について説明します。
`/usr/sbin/httpd -DFORGROUND` コマンドなどでユーザが手動で起動したWebサーバと、systemctlなどのシステム経由で起動したWebサーバは、実行ファイルのパスが同じでも起動したプロセスはそれぞれ異なるドメインで動作します。
systemctl経由で起動したプロセスは httpd_t などの適切なドメインが割り当てられますが、手動で起動した場合は通常の処理とみなされて unconfined_t (制限なしのドメイン) が割り当てられます。
これは、プロセスのドメインはドメイン遷移のルールによってラベル付けされるためです。
ドメイン遷移のルールは「どのドメインのプロセスが、どのタイプのファイルを実行すると、どのドメインとしてプロセス起動するか」を定義するものです。
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
sesearch コマンドのオプション `-T` (type Transition) を使ってドメイン遷移のルールを検索すると、init_t ドメインのプロセスが httpd_exec_t タイプのファイルを実行すると httpd_t ドメインとしてプロセスが起動される、というルールが見つかります。

```bash
~]# sesearch -T | grep httpd_exec_t
...
type_transition init_t httpd_exec_t:process httpd_t;
...
```

sesearch の結果から、init_t ドメインの systemd プロセスが、/usr/sbin/httpd コマンドを実行すると、生成されたプロセスには httpd_t ドメインが割り当てられることがわかります。
init_t ドメインは、systemd プロセスに割り当てられるドメインです。
httpd_exec_t タイプは、/usr/sbin/apache2 や /usr/sbin/httpd などの Apache 本体のコマンドに割り当てられるタイプです。
SELinux は Apache に関連するファイルのパスを、デフォルトのファイルコンテキストに従って自動的に httpd_exec_t タイプでラベル付けしてくれます。
ファイルコンテキストのルールは `semanage fcontext -l` コマンドで確認することができます。

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

systemctl経由で起動したApacheは httpd_t ドメインが割り当てられますが、`/usr/sbin/httpd -DFORGROUND` コマンドで手動で起動した場合は unconfined_t が割り当てられます。
unconfined_t は、SELinuxに制限されないプロセスなので、本来の保護機能を十分に活用できません。
特別な理由がない限り、systemctl経由でサービスを起動するようにしましょう。
また、本番環境では起動しているプロセスが適切なドメインで動作しているかを `ps -eZ` コマンドで確認するようにしましょう。



### タイプ遷移 (Type Transition)

一般に、ファイルやフォルダを作成したときは、親のディレクトリのタイプを継承します。
例えば、一般的にログが保存される /var/log ディレクトリの下に foo/bar ディレクトリを作成して、baz ファイルを作成した場合、
作成した foo, bar, baz のセキュリティコンテキストは、親のディレクトリと同じ var_log_t タイプになります。
```bash
# 親ディレクトリのセキュリティコンテキスト
~]# ls -dZ /var/log
system_u:object_r:var_log_t:s0 /var/log

# 子ディレクトリのセキュリティコンテキスト
~]# mkdir -p /var/log/foo/bar
~]# ls -dZ /var/log/foo/bar
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar

# 子ファイルのセキュリティコンテキスト
~]# touch /var/log/foo/bar/baz
~]# ls -Z /var/log/foo/bar/baz
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar/baz
```

一方で、親のディレクトリのタイプを継承しない場合もあります。
事前にタイプ遷移のルールを定義しておくと、特定のドメインで動くプロセスが対象ディレクトリの下にファイルなどを作成した場合、その親のディレクトリのタイプを無視して、ルールに記述されているタイプを付与します。
このように、新規に作成したファイルなどのセキュリティコンテキストが、それを格納するディレクトリのタイプと異なることを**タイプ遷移** (Type Transition) といいます。
例えば、httpd_t ドメインのプロセスが、var_log_t ディレクトリにファイルを書き込むと、そのファイルは httpd_log_t タイプが付与されます。
```bash
~]# sesearch -T -s httpd_t -t var_log_t
type_transition httpd_t var_log_t:file httpd_log_t;
```

ここからはタイプ遷移の具体例として、Apache上で動くPHPが /var/log/foo/bar にファイルを追加するときに、親ディレクトリのタイプである var_log_t の代わりに、タイプ遷移のルールに従って httpd_log_t タイプが付与されることを確認します。
検証のためにまず、Apacheユーザがファイルを書き込みできるようにディレクトリの権限を修正しておきます。

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
作成されたファイルを `ls -Z` で確認すると、ファイルはタイプ遷移のルールに従って httpd_log_t にラベル付けされています。

```bash
~]# curl localhost/test.php
Update file: /var/log/foo/bar/baz_from_httpd

~]# ls -Z /var/log/foo/bar/baz*
unconfined_u:object_r:var_log_t:s0 /var/log/foo/bar/baz
  system_u:object_r:httpd_log_t:s0 /var/log/foo/bar/baz_from_httpd
```

以上から、httpd_t ドメインのプロセスが var_log_t の下にファイルを作成した場合は、タイプ遷移のルールに従って var_log_t の代わりに httpd_log_t タイプが付与されることが確認できました。

#### 名前遷移 (Name Transition)

名前遷移は、ポリシーバージョン25から対応しているタイプ遷移の一種で、ファイル作成時のみ適用されるルールです。
名前遷移は、作成するファイル名がポリシールールで指定した名前と一致するときだけタイプ遷移を実施する、というものです。
以下のポリシールールを使って名前遷移について説明します。

```bash
~]# sesearch -T -s httpd_t -t tmp_t -c file
type_transition httpd_t tmp_t:file httpd_tmp_t;
type_transition httpd_t tmp_t:file krb5_host_rcache_t HTTP_23;
type_transition httpd_t tmp_t:file krb5_host_rcache_t HTTP_48;
```

このポリシールールでは、httpd_t ドメインが tmp_t ディレクトリにファイルを作成するとき、タイプ遷移のルールに基づいて tmp_t の代わりに httpd_tmp_t タイプが付けられます。
しかし、作成するファイルの名前が HTTP_23 や HTTP_48 のときは、代わりに krb5_host_rcache_t タイプがファイルに付けられます。
検証のためにまず、/tmp 下にファイルを作成する PHP スクリプトを用意します。

/var/www/html/test-tmp.php
```php
<?php
function create_file($path) {
  // touch($path);
  file_put_contents($path, "test text");
  echo "Update file: " . $path . "\n";
}
create_file("/tmp/foo.txt");
create_file("/tmp/HTTP_01");
create_file("/tmp/HTTP_23");
create_file("/tmp/HTTP_48");
```

次に、作成したPHPにWeb経由でアクセスします。
すると、/tmp 下に4つのファイルが作成されます。
作成するファイル名は foo.txt, HTTP_01, HTTP_23, HTTP_48 の4つです。

```bash
~]# curl localhost/test-tmp.php
Update file: /tmp/foo.txt
Update file: /tmp/HTTP_01
Update file: /tmp/HTTP_23
Update file: /tmp/HTTP_48
```

/tmp 下に作成されたファイルのセキュリティコンテキストを確認すると、HTTP_01 と foo.txt はタイプ遷移のルールによって httpd_tmp_t タイプが付与されましたが、HTTP_23 と HTTP_48 は名前遷移のルールによって krb5_host_rcache_t タイプが付与されました。
つまり、名前遷移ルールは、タイプ遷移ルールの条件に、作成するファイル名を追加したものといえます。

```bash
~]# ls -Z /tmp
       system_u:object_r:httpd_tmp_t:s0 HTTP_01
system_u:object_r:krb5_host_rcache_t:s0 HTTP_23
system_u:object_r:krb5_host_rcache_t:s0 HTTP_48
       system_u:object_r:httpd_tmp_t:s0 foo.txt
```

補足ですが、検証において PHP は /tmp 直下にファイルを作成できましたが、実際にはデフォルトでサービス起動時の systemd の設定で PrivateTmp が有効 (true) になっているため、systemd で起動されるプロセスから見える /tmp のパスは、実際のパスとは異なります。
実際のパスは、プロセスごとに与えられる以下のような長いパスです。

```bash
~]# ls -Z /tmp/systemd-private-e9414bc480bf4867b313925cd079f0f6-php-fpm.service-OQldyR/tmp
       system_u:object_r:httpd_tmp_t:s0 HTTP_01
system_u:object_r:krb5_host_rcache_t:s0 HTTP_23
system_u:object_r:krb5_host_rcache_t:s0 HTTP_48
       system_u:object_r:httpd_tmp_t:s0 foo.txt
```

デフォルトでは PrivateTmp の機能は有効になっています。
この機能により、/tmp にアクセスしても他のプロセスが作成した一時ファイルを見つけることができず、有効化しておけばTOC/TOU攻撃を緩和できるため、セキュリティ的により安全といえます。
PrivateTmp の設定が true でも false でもタイプ遷移や名前遷移には影響しないのですが、もし気になる場合は以下の設定で PHP サービス専用の一時ディレクトリの機能を無効化することもできます。

```bash
~]# cat /usr/lib/systemd/system/php-fpm.service
PrivateTmp=true → false  (trueの場合、/tmpはそのプロセス専用になる。デフォルトはtrue)

~]# systemctl daemon-reload
~]# systemctl restart php-fpm
```

### ファイルのラベリング (Labeling)

ファイルのセキュリティコンテキストは、ls コマンドの `-Z` オプションで表示できます。
ディレクトリの場合は `-dZ` オプションで表示できます。

```bash
~]$ ls -Z /var/www/html/index.html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html

~]$ ls -dZ /home/example.user/
unconfined_u:object_r:user_home_dir_t:s0 /home/example.user/
```

以下はファイル作成時にラベル付けされるセキュリティコンテキストの例です。

 * /bin や /usr/bin の下に作成したファイルは、bin_t タイプになります。
 * /etc の下に作成したファイルは、etc_t タイプになります。
 * /var の下に作成したファイルは、var_t タイプになります。
 * /tmp の下に作成したファイルは、tmp_t タイプになります。
 * /home/xxx/ などのホームディレクトリの下に作成したファイルは、user_home_t タイプになります。

#### ファイルコンテキストの一時的な変更 (chcon)

chconコマンドは、一時的にファイルやディレクトリのセキュリティコンテキストを変更するためのツールです。
一時的というのは、本来あるべきセキュリティコンテキストとは違う状態になっていることを意味し、restorecon コマンドの実行や /.autorelabel ファイルの作成＆再起動などでに元に戻る状態のことです。
再起動しただけでは chcon で一時的に変えたセキュリティコンテキストは元に戻りません。

1つのファイルやディレクトリのタイプを変更するときは、`-t` (Type) でタイプを指定した後に、対象のパスを指定します。
```bash
~]# chcon -t httpd_sys_content_t /var/www/html/index.html
~]# chcon -t httpd_sys_rw_content_t /var/www/html/upload
```
ディレクトリの下の全てのタイプを変更するときは、`-R` (Recursive) オプションを追加して再帰的に動作するようにします。
```bash
~]# chcon -R -t httpd_sys_content_t /var/www/html
```

オブジェクトのセキュリティコンテキストに含まれるSELinuxユーザは、UBACが有効の場合はアクセス制御に影響します。
ただし、デフォルトではUBACは無効なので、通常はオブジェクトのSELinuxユーザ (所有者) を意識することはありません。
chcon でオブジェクトのSELinuxユーザを変える場合は、`-u` (seUser) オプションでSELinuxユーザを指定します。
```bash
~]# ls -dZ /var/www/html/upload
unconfined_u:object_r:httpd_sys_rw_content_t:s0 /var/www/html/upload
~]# chcon -u system_u /var/www/html/upload
~]# ls -dZ /var/www/html/upload
system_u:object_r:httpd_sys_rw_content_t:s0 /var/www/html/upload
```

テストや検証では chcon を使って一時的にタイプを変更し、問題がなければ次で説明する semanage fcontext で永続的にタイプを変更するようにしましょう。

#### ファイルコンテキストの永続的な変更 (semanage fcontext)

semanage fcontextは、永続的にファイルやディレクトリのセキュリティコンテキストを変更するためのツールです。
SELinuxでは、ファイルコンテキストの永続的な変更に正規表現を用いてファイルやディレクトリのラベル付けを行います。
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

永続的にファイルやディレクトリのセキュリティコンテキストを変更するルールを追加するには、`-a` (Add) オプションを追加し、`-t` で設定したいタイプ、最後の引数にマッチさせたいパスの正規表現を指定します。
ファイルコンテキストのルールを追加しただけではファイルやディレクトリのタイプは変更されないので、restorecon コマンドを使ってルールを適用してタイプを修正します。
```bash
~]# semanage fcontext -a -t httpd_sys_content_t "/var/test_www(/.*)?"
~]# restorecon -Rv /var/test_www
```
ファイルコンテキストのルールを修正する場合は、`-m` (Modify) オプションで修正します。
```bash
~]# semanage fcontext -m -t httpd_sys_rw_content_t "/var/test_www(/.*)?"
~]# restorecon -Rv /var/test_www
```
ファイルコンテキストのルールを削除する場合は、`-d` (Delete) オプションで削除します。ファイルコンテキストも元に戻すには、続けて restorecon を実行します。
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

ローカル環境でカスタマイズした変更の一覧を表示する場合、`-lC` (List Customization) オプションを使用します。
```bash
~]# semanage fcontext -lC
SELinux fcontext                type           Context
/var/test_www(/.*)?             all files      system_u:object_r:httpd_sys_content_t:s0
```

ローカル環境でカスタマイズした変更をすべて削除する場合、`-D` (Delete all customization) オプションを使用します。
```bash
~]# semanage fcontext -D
```

再起動時にファイルシステム全体を再度ラベル付けする場合は、ルートディレクトリに「.autorelabel」という名前の空ファイルを作成し、再起動 (reboot) することで再ラベル付けが実施されます。
```bash
~]# touch /.autorelabel
~]# reboot
```

その他に、ファイルのマッチに使用した正規表現が適切だったかを確認するための matchpathcon コマンドもあります。
matchpathcon は、指定したパスがファイルコンテキストに設定した正規表現とマッチするかを確認するためのツールです。
```bash
~]# matchpathcon /var/test_www/html/upload
/var/test_www/html/upload       system_u:object_r:httpd_sys_content_t:s0
```

#### ファイルコンテキストの復元 (restorecon)

restorecon はSELinuxコンテキストをデフォルト値に復元するためのコマンドです。
restorecon コマンドを使うと、chcon で設定した一時的なコンテキストは消えて、コンテキストが元に戻ります。
`-v` オプションを使用することで、restorecon 実行時にセキュリティコンテキストが元に戻されたファイルやディレクトリの一覧を表示することができます。
```bash
~]# restorecon -v /var/www/html/upload
```

ディレクトリ下の全てのファイルに対しては、`-R` (Recursive) オプションで再帰的に復元させることができます。
```bash
~]# restorecon -R -v /var/www/html
```


### ポートのラベリング (semanage port)

semanage port は、ポートの番号に割り当てるタイプを管理するためのツールです。
プロセスのTCPやUDPの送信 (send) や受信 (recv) を管理するために使用します。
すべてのポートのタイプに関連付けされているポート番号の一覧を表示するには、`-l` (List) オプションでコマンドを実行します。
```bash
~]# semanage port -l
SELinux Port Type              Proto    Port Number
afs3_callback_port_t           tcp      7001
afs3_callback_port_t           udp      7001
afs_bos_port_t                 udp      7007
...
zookeeper_election_port_t      tcp      3888
zookeeper_leader_port_t        tcp      2888
zope_port_t                    tcp      8021
```

指定したポート番号に新しいタイプを割り当てる場合、`-a` (Add) オプションを使用します。
実行時は、タイプとプロトコルとポート番号を指定します。
一般的にポートに割り当てるタイプは、末尾が `_port_t` の形式になっています。
```bash
~]# semanage port -a -t http_port_t -p tcp 8088
~]# semanage port -l | grep 8088
http_port_t                    tcp      8088, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```

指定したポート番号にタイプを追加する場合、`-m` (Modify) オプションを使用します。
指定した対象のポート番号がすでに他で使用されている場合、`-a` の代わりに `-m` オプションを使用します。
```bash
~]# semanage port -a -t http_port_t -p tcp 8000
ValueError: Port tcp/8000 already defined

~]# semanage port -l | grep 8000
soundd_port_t                  tcp      8000, 9433, 16001

~]# semanage port -m -t http_port_t -p tcp 8000
http_port_t                    tcp      8000, 8088, 80, 81, 443, 488, 8008, 8009, 8443, 9000
soundd_port_t                  tcp      8000, 9433, 16001
```

指定したポート番号のタイプを削除する場合、`-d` (Delete) オプションを使用します。
```bash
~]# semanage port -d -t http_port_t -p tcp 8088
```

ローカル環境でカスタマイズした変更の一覧を表示する場合、`-lC` (List Customization) オプションを使用します。
```bash
~]# semanage port -lC
SELinux Port Type              Proto    Port Number
http_port_t                    tcp      8000
```

ローカル環境でカスタマイズした変更をすべて削除する場合、`-D` (Delete all customization) オプションを使用します。
```bash
~]# semanage port -D
```


### Boolean

Boolean は SELinux のポリシーを管理するためのフラグで、Onにするだけで関連する複数のルールが有効化されます。
例えば、httpd_can_network_connect_db という名前の Boolean は、On にするだけで httpd が外部のDBサーバのポートとの接続が許可されます。
Boolean の一覧は semanage boolean コマンドの `-l` (List) オプションで表示することができます。

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
例えば、httpd_can_network_connect という Boolean を一時的に有効化するには次のコマンドを実行します。一時的に設定した場合は、再起動するとデフォルト値に戻ります。
```bash
~]# setsebool httpd_can_network_connect on
```
永続的に設定したい場合は、`-P` (Permanent) オプションを追加して実行します。
`-P` オプションを指定した場合は、ポリシーの再ビルドが発生するので、設定の反映が完了するまで若干時間がかかります。
```bash
~]# setsebool -P httpd_can_network_connect on
```

ローカル環境でカスタマイズした変更の一覧を表示する場合、`-lC` (List Customization) オプションを使用します。
```bash
~]# setsebool -P httpd_can_network_connect on
~]# semanage boolean -lC
SELinux boolean                State  Default Description
httpd_can_network_connect      (on   ,   on)  Allow HTTPD scripts and modules to connect to the network using TCP.
```

ローカル環境でカスタマイズした変更をすべて削除する場合、`-D` (Delete all customization) オプションを使用します。
```bash
~]# semanage boolean -D
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

自作のポリシールールを追加するよりも、Boolean を on にしてポリシールールを修正する方が、安全に許可ルールを追加することができます。
特に、よく使う Boolean もしくは、知っておいて損はない Boolean について、簡単に紹介します。

* httpd
  - httpd_can_network_connect :
  httpdがネットワークにTCP接続するのを許可する。デフォルトは off
  - httpd_can_network_connect_db :
  httpdがネットワークのDBのポートに接続するのを許可する。デフォルトは off
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
  httpdが /tmp の下にあるファイルを実行するのを許可する。デフォルトは off
* tomcat
  - tomcat_can_network_connect_db :
  TomcatがネットワークのDBに接続するのを許可する。デフォルトは off
* named (DNS)
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
  sysadm_rロールに所属するユーザがsshログインするのを許可する。デフォルトは off
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
SELinuxユーザとLinuxユーザを対応関係を表示するには、`semanage login -l` コマンドを実行します。

```bash
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
example.user         staff_u              s0                   *
```

出力結果のそれぞれの列は、次の意味を表しています。

- Login Name : Linuxユーザでのログイン名。ルールにマッチしないその他の全てのLinuxユーザは `__default__` になります
- SELinux User : Linuxユーザに対応付けされたSELinuxユーザ名
- MLS/MCS Range : Linuxユーザに対応付けされたレベル
- Service : Linuxユーザがログイン時に使用するサービス

LinuxユーザとSELinuxユーザの対応関係を追加するには、`-a` (Add) オプションでSELinuxとLinuxユーザを指定します。
```bash
~]# semanage login -a -s user_u user1
```
LinuxユーザとSELinuxユーザの対応関係を修正するには、`-m` (Modify) オプションで修正後を内容を設定します。
```bash
~]# semanage login -m -s staff_u user1
```
LinuxユーザとSELinuxユーザの対応関係から削除するには、`-d` (Delete) オプションでLinuxユーザを指定します。
```bash
~]# semanage login -d user1
```

ローカル環境でカスタマイズした変更の一覧を表示する場合、`-lC` (List Customization) オプションを使用します。
```bash
~]# semanage login -lC
Login Name           SELinux User         MLS/MCS Range        Service
example.user         staff_u              s0-s0:c0.c1023       *
user1                sysadm_u             s0-s0:c0.c1023       *
```

ローカル環境でカスタマイズした変更をすべて削除する場合、`-D` (Delete all customization) オプションを使用します。
```bash
~]# semanage login -D
```

#### ユーザのレベル

SELinuxのユーザ一覧を表示すると「MLS/MCS Range」という列があります。
これはレベル (Level) と呼ばれるもので、そのユーザの機密レベルとカテゴリーセットを表しており、「s0-s0:c0.c1023」という形式で記述されます。

レベルには、MLS (Multi Layer Security) とMCS (Multi Category Security) の2つの属性が含まれています。
表示形式は「MLS範囲:カテゴリーセット」です。
情報セキュリティにおいては、資産の分類結果に基づいてサブジェクトに付与したものがMLS範囲、資産のカテゴリ化結果に基づいてサブジェクトに付与したものがカテゴリーセットです。

MLS範囲は、サブジェクトが所持しているクリアランスレベルの範囲を示します。
MLS範囲は「低レベル-高レベル」で表示され、s0-s0 のときは s0 と同じ意味です。
カテゴリーセットは、サブジェクトがアクセスを許可されているカテゴリの一覧です。
カテゴリーセットは「c0,c1,c2,c3」と表示されます。
また、カテゴリが連続している場合はドットで範囲を表します。例えば「c0.c3」は「c0,c1,c2,c3」と同じ意味になります。
カテゴリは1024種類まで対応しています。
例えば、ユーザのレベルが「s0-s0:c0.c1023」のときは、機密性レベル s0 かつ、c0～c1023 のカテゴリのデータに対してアクセスが許可されます。

SELinux では MLS はデフォルトで無効化されています。
使用したい場合は selinux-policy-mls パッケージをインストールして、MLS をデフォルトの SELinux ポリシーに設定します。
MLS が無効の場合、すべてのSELinuxユーザのレベルは常に s0-s0:c0.c1023 が割り当てられます。

```bash
~]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

#### SELinuxのロール

SELinuxには、複数のロールが存在します。全てのロールの一覧は、`seinfo -r` コマンドで確認することができます。
以下はそれぞれのSELinuxロールについての説明です。

- **unconfined_r** : 制限のないロール。このロールに属するユーザは、アクションがSELinuxによって制限されることはありません。
- **system_r** : デーモンやサービスのプロセスに割り当てられるシステム管理者ロール。デーモンやサービスの稼働に必要な高い権限を持ちます。
- **sysadm_r** : ユーザに割り当てられるシステム管理者ロール。システム全体を操作できる非常に高い権限を持ちます。このロールに所属するSELinuxユーザに対応するLinuxユーザは、管理者権限のグループの wheel や sudo などにも追加しておくことで、管理者権限を使用できるようになります
- secadm_r : セキュリティ管理者ロール。このロールに属するSELinuxユーザは、SELinuxのポリシーの変更と設定の修正ができます。
システム管理者とシステムポリシー管理者の職務を分離するために使用します。
- **staff_r** : ユーザの切り替えができる制限されたロール。このロールに属するSELinuxユーザは、sudo -r や newrole コマンドで管理者権限のロールに切り替えることできます。/etc/sudoers の設定で、管理者として実行可能なコマンドを指定するときにセキュリティコンテキストも指定すると、管理者権限で実行できるようになります。
- webadm_r : Web管理者ロール。httpdの設定やログにアクセスできるロールです。
- auditadm_r : 監査管理者ロール。auditdの設定やログにアクセスできるロールです。
- dbadm_r : DB管理者ロール。mysqldやpostgresqlの設定やログにアクセスできるロールです。
- logadm_r : ログ管理者ロール。`*_log_t` でタイプ付けされたログファイルにアクセスできるロールです。
- **user_r** : 制限された一般ユーザのロール。このロールに属するSELinuxユーザは、エンドユーザのアプリケーションしか実行できません。権限昇格などはできないため、管理者の操作をしたい場合は別のアカウントで再度ログインしなおす必要があります。
- guest_r : ゲストロール。ネットワーク接続に制限があるロールです。
- xguest_r : X Windowsゲストロール。X Window向けのguest_rロールです。
- object_r : オブジェクトに付けるロール。セキュリティコンテキストからSIDを決めるのに必要なロールのため、このロール自体には特に意味はありません。

オブジェクトのロール object_r は、ファイルやディレクトリに自動的に付けられるロールのため、自分でラベル付けする必要はありません。
object_r はセキュリティコンテキストからSIDを決めるために使用されます。
セキュリティコンテキストとは、SELinuxのユーザ、ロール、タイプの3つのセキュリティ属性をまとめたものです。
SELinuxでは、処理の高速化のために、セキュリティコンテキストにSID (セキュリティID) と呼ばれる一意の整数値を割り当てて識別します。
サブジェクトは能動的で様々なロールを持つことができますが、オブジェクトは受動的なのであまりロールを必要としません。
ただし、全てのサブジェクトとオブジェクトには3つのセキュリティ属性を持つセキュリティコンテキストを割り当てないといけないので、ロールが不要なオブジェクトには、ダミーのロール object_r が付与されています。

```bash
~]# ls -Z /etc/passwd
system_u:object_r:passwd_file_t:s0 /etc/passwd
```

#### SELinuxユーザのデフォルトマッピングを変更する

LinuxユーザがSELinuxユーザと対応付けされていない場合、デフォルトではSELinuxの unconfined_u ユーザが割り当てられます。
unconfined_u は SELinux の制限を受けないユーザのため、脆弱性を使った権限昇格によるシステム全体の権限が奪われる可能性があります。
SELinuxユーザのデフォルトマッピングの変更することで、より安全にユーザからシステムを保護することができます。
ここでは、LinuxユーザのデフォルトSELinuxユーザを unconfined_u から user_u に変更する方法について説明します。

SELinuxユーザの user_u は、sudo や su が実行できない (setuidができない) ユーザです。
たとえLinux Kernelの脆弱性を使用しても、権限昇格することはできません。
通常の一般ユーザは、user_u に割り当てるのが妥当です。
semanage login コマンドを使って、オプション `-m` (Modify)、`-s` (Seuser)、`-r` (Range) を指定して、`__default__` を user_u にマッピングします。

```bash
~]# semanage login -m -s "user_u" -r s0 __default__
~]# semanage login -l
Login Name           SELinux User         MLS/MCS Range        Service
__default__          user_u               s0                   *
root                 unconfined_u         s0-s0:c0.c1023       *
mako                 unconfined_u         s0-s0:c0.c1023       *
```
設定を元に戻すには、以下のコマンドで実行します。
```bash
~]# semanage login -m -s "unconfined_u" -r s0-s0:c0.c1023 __default__
```

#### staff_u ユーザに特定のコマンドの sudo だけを許可する

例えば、Webサーバがある環境で、あるユーザに awk を sudo で実行できる権限を与えてログを解析してもらいたいとします。
そのコマンドを管理者権限で実行する際に、SELinuxのドメイン下で動作させて、範囲外のファイルを操作できないように制限する方法について説明します。

管理者権限コマンドの実行制限をする方法は、まずLinuxのユーザに対して staff_u というSELinuxユーザを割り当てます。
ここでは、Linuxユーザの user1 にSELinuxユーザの staff_u を割り当てます。
```bash
~]# useradd user1
~]# passwd user1

~]# semanage login -a -s staff_u user1
~]# semanage login -l
Login Name           SELinux User         MLS/MCS Range        Service
__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
user1                staff_u              s0-s0:c0.c1023       *
```
LinuxユーザにSELinuxユーザの割り当てをしたら、次は staff_u というSELinuxユーザが持っているロールに logadm_r を追加して、`*_log_t` タイプのファイルにアクセスできるロールを付与します。
```bash
~]# semanage user -l
                Labeling   MLS/       MLS/
SELinux User    Prefix     MCS Level  MCS Range                      SELinux Roles
staff_u         user       s0         s0-s0:c0.c1023                 staff_r sysadm_r unconfined_r

~]# semanage user -m -R 'staff_r sysadm_r logadm_r' staff_u

~]# semanage user -l
                Labeling   MLS/       MLS/
SELinux User    Prefix     MCS Level  MCS Range                      SELinux Roles
staff_u         user       s0         s0-s0:c0.c1023                 staff_r sysadm_r logadm_r
```
最後に /etc/sudoers を編集します。
visudo コマンドを実行して設定を修正し、user1 が /usr/bin/awk ファイルを logadm_t ドメインで実行するように制限します。
```bash
~]# visudo
```

/etc/sudoers に書き込む設定は以下の内容です。
```conf
user1 ALL=(ALL) ROLE=logadm_r TYPE=logadm_t /usr/bin/awk
```

次に設定が正しく行われたかを確認します。別のコンソールを開いて、ログを解析するユーザ user1 でログインします。
このとき、ログイン時のドメインは staff_t であることを確認します。
```bash
~]$ id
uid=1003(user1) gid=1003(user1) groups=1003(user1) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
```
user1 で `sudo -l` コマンドを実行し、user1 が実行できる sudo コマンドを確認します。
```bash
~]$ sudo -l
...
User user1 may run the following commands on localhost:
    (ALL) ROLE=logadm_r TYPE=logadm_t /usr/bin/awk
```
/usr/bin/awk コマンドを sudo で実行できるので、試しに awk で /var/log/audit/audit.log を開いてみます。
コマンドを実行すると、問題なく監査ログの中身を表示できると思います。
```bash
~]$ sudo /usr/bin/awk '/^type=AVC/ {print $0}' /var/log/audit/audit.log
```

次に、sudo と awk を使って管理者権限のシェルを奪取します。
awk には、システムコマンドを呼び出すための system 関数が存在します。
この system 関数を利用してシェルを起動させることができます。
awk を root 権限で実行した場合、その子プロセスであるシェルも root 権限で動作します。
他のコマンドでもこのような権限昇格の方法がありますので、詳しく知りたい方は [GTFOBins](https://gtfobins.github.io/) を参照してください。
awk の場合は、`awk 'BEGIN {system("/bin/sh")}'` をコマンドで実行するとシェルが起動ので、これ利用して管理者権限で awk を実行すると root 権限のシェルを手に入れることができます。
以下は sudo と awk で root 権限を取得して、/etc/passwd の編集を試みたところです。

```bash
~]$ sudo /usr/bin/awk 'BEGIN {system("/bin/sh")}'
sh-4.4# id
uid=0(root) gid=0(root) groups=0(root) context=staff_u:logadm_r:logadm_t:s0-s0:c0.c1023
sh-4.4# echo "test" >> /etc/passwd
sh: /etc/passwd: Permission denied
sh-4.4#
```
sudo と awk を使って root 権限 `uid=0(root)` を奪取することができました。
しかし、SELinuxによって、/etc/passwd への書き込みが失敗しました。
監査ログを確認すると、以下の拒否ログが記録されていると思います。

/var/log/audit/audit.log
```
type=AVC msg=audit(0000000000.908:7884): avc:  denied  { append } for  pid=70812 comm="sh" name="passwd" dev="dm-0" ino=16786641 scontext=staff_u:logadm_r:logadm_t:s0-s0:c0.c1023 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
```
ログの内容は、logadm_t ドメインが passwd_file_t タイプのファイルに書き込み (append) するポリシールールは存在しないのでSELinuxが拒否した、という意味になります。
logadm_t ドメインが passwd_file_t タイプに対して許可されているアクションを sesearch で検索すると、確かに書き込み (writeやappend) は含まれていないことが確認できます。
```bash
~]# sesearch -A -s logadm_t -t passwd_file_t
...
allow nsswitch_domain passwd_file_t:file { getattr ioctl lock map open read };
```
なお、logadm_t タイプは nsswitch_domain 属性を持つため、上記のサブジェクトは nsswitch_domain を logadm_t と読み替えることができます。

```bash
]# seinfo -a nsswitch_domain -x | grep logadm_t
Type Attributes: 1
   attribute nsswitch_domain;
        ...
        logadm_t
        ...
```
logadm_t ドメインは passwd_file_t タイプのファイルに書き込み (writeやappend) することはできないため、SELinuxに拒否されたことが確認できました。
このように、staff_u のSELinuxユーザを割り当て適切なドメインでのみ sudo を許可することで、ユーザの権限昇格を使った攻撃を緩和できる環境を構築することができます。

#### ロールの切り替え

Linuxがユーザを切り替えるときに su を使用するように、SELinuxのロールを切り替える時は `newrole -r` や `sudo -r` コマンドを使用します。
newrole コマンドは `dnf install policycoreutils-newrole` でインストールすることができます。
例えば、ユーザとロールのマッピングが以下の通りで、staff_u ユーザは staff_r, sysadm_r, logadm_r ロールの3つを持っている状態とします。

```bash
~]# semanage user -l
                Labeling   MLS/       MLS/
SELinux User    Prefix     MCS Level  MCS Range                      SELinux Roles
staff_u         user       s0         s0-s0:c0.c1023                 staff_r sysadm_r logadm_r
```

このとき、newrole コマンドを使用して、staff_u ユーザを staff_r ロールから sysadm_r ロールに切り替えることができます。
ただし、SELinuxのロールを sysadm_r などの管理者ロールに変えても、Linuxの管理者グループである wheel や sudo グループに所属していないと、管理者コマンドを実行するときにDACの権限で拒否されてしまいます。
実際の運用では、`usermod -aG` でユーザを wheel グループに追加したり、/etc/sudoers で特定のコマンドのみ sudo できるように設定した後に、`semanage login -a` でユーザに staff_u ロールを持たせる、という流れになります。

```bash
~]$ id
uid=1002(user1) gid=1002(user1) groups=1002(user1) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023

~]$ newrole -r sysadm_r
Password: (ここでパスワードを入力する)

~]$ id
uid=1002(user1) gid=1002(user1) groups=1002(user1) context=staff_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

ロールの切り替えは、newrole コマンド以外に sudo でもできます。
管理者権限で実行するための sudo コマンドに、`-r` (Role) オプションを追加することで SELinux ロールを指定することができます。
例えば、user2 ユーザは管理者グループの wheel に所属しており、かつ staff_u ユーザは staff_r と sysadm_r の両方のロールを持つ場合、`sudo -r sysadm_r su` コマンドを実行することで、ユーザを root に切り替えつつ、SELinuxロールを sysadm_r に切り替えることができます。

```bash
~]$ id
uid=1003(user2) gid=1003(user2) groups=1003(user2),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023

~]$ sudo -r sysadm_r su
~]# id
uid=0(root) gid=0(root) groups=0(root) context=staff_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

sudo -r でロールとユーザを切り替えると、セキュリティコンテキストは切り替え前が「staff_u:**staff_r**:**staff_t**」で、切り替え後が「staff_u:**sysadm_r**:**sysadm_t**」になります。

なお、sudo -r でロールを指定しないでユーザを root に切り替えた場合、セキュリティコンテキストは staff_t のままです。
staff_t のままでは十分な管理者権限を持たないため、root であってもシステム管理用のコマンドを実行することができない場合が多いです。
```bash
~]$ id
uid=1003(user2) gid=1003(user2) groups=1003(user2),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023

~]$ sudo su
[sudo] password for user2:  (ここでパスワードを入力する)
bash: /root/.bashrc: Permission denied
bash-4.4# id
uid=0(root) gid=0(root) groups=0(root) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
```



### セキュリティコンテキストの確認方法

SELinuxの特徴の1つであるタイプ強制 (TE; Type Enforcement) は、すべてのサブジェクトとオブジェクトにラベル付けをして、そのタイプに基づいた振る舞いを強制させることです。
ここまで、サブジェクトやオブジェクトへのラベル付けを説明してきましたが、それぞれのセキュリティコンテキストの確認方法をまとめると、以下のコマンドを使って確認することができます。
基本的にはコマンドに `-Z` オプションをつけるとセキュリティコンテキストも表示されるようになります。

- サブジェクト
  - ユーザ : `id -Z`
  - プロセス : `ps -eZ | grep <プロセス名>`
  - ソケット : `ss -talpnZ` (管理者権限で実行すること)
- オブジェクト
  - ファイル : `ls -Z <ファイルパス>`
  - ディレクトリ : `ls -dZ <ディレクトリパス>`



### ポリシーモジュールの管理 (semodule)

SELinuxポリシーは、複数のポリシーモジュールで構成されています。
ポリシーモジュール (Policy Module) は、複数のポリシールールをまとめたもので、モジュール毎に有効化/無効化をすることができます。
また、ポリシーモジュールは自作することもできます。
現在読み込まれているポリシーモジュールの一覧を表示するには、semodule コマンドを `-l` (List) オプションで実行します。
ポリシーモジュールの優先度や現在の状態 (有効/無効) などのより詳細な情報を表示するには、オプションを `-lfull` にして実行します。
```bash
~]# semodule -l      # 一覧表示
~]# semodule -lfull  # 一覧詳細表示
```
自分で作成したポリシーモジュールパッケージをSELinuxに読み込むには、`-i` オプションを使用します。
```bash
~]# semodule -i myrule.pp
```
ポリシーモジュールパッケージを読み込む際は、ルールを適用する優先度を設定できます。
優先度は `-X` オプションで指定し、1～999 の値を設定できます。
同じ名前のポリシーモジュールでも優先度が異なる場合は、別々で登録されます。
同じ名前のポリシーモジュール名で既存の優先度よりも大きい値を設定した場合は、優先度の大きいモジュールだけが有効になり、優先度の小さいモジュールは無効になります。
```bash
~]# semodule -i myrule.pp -X 500
```
登録したポリシーモジュールを削除したい場合は、`-r` (Remove) オプションで削除します。
同じ名前で複数の優先度が存在する場合は、`-X` で優先度も指定します。
```bash
~]# semodule -r myrule -X 500
```
登録したポリシーモジュールを削除しないが無効化したい場合は、`-d` (Disable) オプションを使います。
また、無効化したポリシーモジュールを有効化したい場合は、`-e` オプションを使います。
```bash
~]# semodule -d myrule  # 無効化
~]# semodule -e myrule  # 有効化
```

#### semanage module

semanage module コマンドは、semodule コマンドを拡張したツールです。
基本的には semodule コマンドで十分ですが、`-lC` などの一部の機能は semanage module にしか存在しないです。
ローカル環境でカスタマイズした変更の一覧を表示する場合、`-lC` (List Customization) オプションで確認することができます。
```bash
~]# semanage module -lC
Module Name               Priority  Language
simplehttpserver          400       pp    Disabled
myrule                    300       pp
```

#### 拒否ログに応じて許可ルールを作成する (audit2allow)

SELinuxが特定のアクションを拒否した場合、拒否ログは監査ログ /var/log/audit/audit.log に記録されます。
audit2allow コマンドは、SELinuxが特定のアクションを拒否しないように、拒否ログの内容から許可ルールを含むポリシーモジュールパッケージ (.pp) を作成します。
作成したポリシーモジュールパッケージを semodule で読み込み、ポリシーモジュールを作成することによって、特定のアクションは SELinux によって拒否されなくなります。

例えば、監査ログに次の拒否ログが記録されていた場合に、このアクションを許可するために audit2allow を使って自作ポリシーモジュールを作成する例を紹介します。
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

結果を見ると、httpd_t ドメインが http_port_t ポートに接続できるルールが出力されました。
その許可ルールの上の「!!!」から始まる注意書きを読むと「この許可ルール (AVC) は次の Boolean を on にしても有効化されます：httpd_can_network_connect, ...」と書かれています。
一般的に、httpd_t ドメインがネットワークに接続したい場合は、`setsebool -P httpd_can_network_connect on` を実行して、httpd_can_network_connect という Boolean を on にするだけで接続できるようになります。
ただし、ここでは自作ポリシーモジュールの作成についての説明をするため、Boolean を使わない方法で進めていきます。

audit2allow で出力された許可ルールが問題ないことを確認したら、続いて `-M` (Module) オプションで作成するポリシーモジュール名を指定します。
ポリシーモジュール名は、自作であることがわかるように、モジュール名の先頭に my や custom などの文字列の追加が推奨されます。
次のコマンドを実行すると、ポリシーモジュールパッケージ myrule.pp と、TE形式のルール myrule.te がファイルに保存されます。

```bash
~]# echo '<拒否ログ>' | audit2allow -M myrule

******************** IMPORTANT ***********************
To make this policy package active, execute:
semodule -i myrule.pp
```

また、audit2allow -M でポリシーモジュールパッケージを作成する際に、`-D` (Dontaudit) を追加すると Allow ルールの代わりに Dontaudit ルールでポリシーモジュールパッケージを作成します。
主に、監査ログを埋めつくすけど重要ではない拒否ログを、拒否したまま監査ログに残さないようにするために使用します。
```bash
~]# echo '<拒否ログ>' | audit2allow -M -D myrule
```

最後に、保存されたポリシーモジュールパッケージを semodule で読み込んでポリシーモジュールを作成し、ルールを適用します。
```bash
~]# semodule -i myrule.pp
```

audit2allow と semodule で自作ポリシーモジュールを作成することで、自分の環境だけに適用する許可ルールを追加することができます。

#### ポリシーモジュールパッケージの内容を確認する

ポリシーモジュールパッケージはバイナリファイルのため、そのままでは中身を確認することができません。
そこで /usr/libexec/selinux/hll/pp コマンドを使用して CIL 形式で表示することで中身を確認することができます。
pp コマンドの使い方は、.pp ファイルの内容を cat で表示して pp コマンドにパイプで渡すと、内容が CIL 形式で表示されます。
```bash
~]# cat myrule.pp | /usr/libexec/selinux/hll/pp

(typeattributeset cil_gen_require http_port_t)
(typeattributeset cil_gen_require httpd_t)
(allow httpd_t http_port_t (tcp_socket (name_connect)))
```

#### ポリシーモジュールの作成

ポリシーモジュールは自分で作成することができます。
ポリシーモジュールの作成から適用において、必要なファイルは以下の通りです。

 1. TE形式のポリシールール (.te)
 2. バイナリポリシーモジュール (.mod)
 3. ポリシーモジュールパッケージ (.pp)

例えば、tomcat_t ドメインのプロセスが、外部とネットワーク通信をしたときに、Auditallowルール (許可してログも残す) を適用するというポリシーモジュールを作成してみます。
まず、tomcat_t ドメインにTCP/UDP通信をするための権限 tcp_socket, udp_socketを与えるために、my_tomcat_policy.te を作成して内容を以下のように書きます。

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

作成したTEファイルは checkmodule コマンドと、semodule_package コマンドを使用して、ポリシーモジュールパッケージ (.pp) に変換します。

まず、TEファイルからポリシーモジュールパッケージに変換 (コンパイル) するには、以下のコマンドを順番に入力します。

```bash
~]# checkmodule -M -m -o my_tomcat_policy.mod my_tomcat_policy.te
~]# semodule_package -o my_tomcat_policy.pp -m my_tomcat_policy.mod
~]# semodule -i my_tomcat_policy.pp
```

自作ポリシーモジュールが登録されているかを確認するには、`semodule -lfull` コマンドでモジュール一覧を表示します。
表示することでモジュールが有効かを確認できます。
```bash
~]# semodule -lfull | grep my_tomcat_policy
```

#### ポリシールールのタイプと属性

SELinux のポリシールールには、主に Type (タイプ) と Attribute (属性) の2種類があります。
Type はセキュリティコンテキストのタイプです。
タイプの名前は、末尾が `_t` で終わるように命名規則で統一されています。
例えば、末尾が `_exec_t` ならプロセスを起動するための実行ファイル (プログラム)、末尾が `_port_t` なら接続先のポートに関するタイプです。

Attribute は Type が持つ属性を表したものです。
ルールで Attribute を使うことで、Type だけ異なる複数のルールを1つにまとめることができます。
seinfo コマンドの `-a` (Attribute) で属性を指定し、`-x` (Explain) で属性に所属するタイプの一覧を表示できます。

```bash
~]# seinfo -a initrc_domain -x
Type Attributes: 1
   attribute initrc_domain;
        cluster_t
        condor_startd_t
        init_t                  <-- init_tタイプはinitrc_domain属性を持つ
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
        httpd_exec_t             <-- httpd_exec_tタイプはdirect_init_entry属性を持つ
        httpd_rotatelogs_exec_t
        ...
```

逆に、特定の Type が所属する Attribute の一覧を表示することもできます。
`-t` (Type) でタイプを指定し、`-x` (Explain) でタイプが所属する属性の一覧を表示できます。

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


#### ポリシールールの検索

sesearch コマンドは、SELinuxのポリシールール (アクセスベクタルール) を検索するためのツールです。
ポリシールールはTE形式で記述することができ、1つのルールは以下のような形式で記述されます。
```
rule_name source_type target_type : class perm_set (object_name);
```
各項目はそれぞれ以下の意味を持ちます。
- **rule_name** : ルールの名前。ポリシールールは、オブジェクトに対するサブジェクトのアクションの許可を定義していて、主に次の4種類のルールを使用しています。
  - allow : アクションを許可して、監査ログに記録しない
  - auditallow : アクションを許可して、監査ログに記録する (granted でログに記録される)
  - dontaudit : アクションを拒否するが、監査ログに記録しない
  - type_transition : ドメイン遷移やタイプ遷移を許可する
- **source_type** : ドメイン。アクセス元のセキュリティコンテキストのタイプを表します。
- **target_type** : タイプ。アクセス先のセキュリティコンテキストのタイプを表します。
- **class** : オブジェクトクラス。ファイルやディレクトリなどのオブジェクトの種類を表します。
- **perm_set** : アクションの権限。オブジェクトに対してサブジェクトが許可されているアクションの一覧です。
- (object_name) : オブジェクト名。ルールが type_transition (タイプ遷移) のときのみ使用され、遷移先のタイプを表します。

sesearch コマンドで上記のルールを検索するには、以下のオプションを使用します。
よく使用するのは `-A` (Allow) と `-T` (Transition) です。

- `-A` : すべての allow ルールを検索します
- `--auditallow` : すべての auditallow ルールを検索します
- `--dontaudit` : すべての dontaudit ルールを検索します
- `-T` : すべての type_transition ルール (ドメイン遷移やタイプ遷移) を検索します

上記の必須の検索オプションに加えて、ドメインやオブジェクトクラスでさらに検索条件を絞り込むために、以下のオプションも使用できます。

- `-s` : アクセス元 (Source) のタイプやドメインを指定して検索します
- `-t` : アクセス先 (Target) のタイプを指定して検索します
- `-c` : オブジェクトクラス (object Class) を指定して検索します
- `-p` : アクションの権限 (Permission) を指定して検索します

それぞれのオプションを使用した検索例を以下に示します。

httpd が外部サーバの接続できるTCPポートの一覧を確認するために、httpd_t ドメインがTCP接続を許可するルール一覧を表示するときのコマンドは以下となります。
```bash
~]# sesearch -A -s httpd_t -c tcp_socket
```
passwd_file_t タイプのファイル (/etc/passwd) に書き込みを許可するルール一覧を表示するときのコマンドは以下となります。
```bash
~]# sesearch -A -t passwd_file_t -c file -p write
```
init_t ドメイン (systemd) からドメイン遷移を許可するルール一覧を表示するときのコマンドは以下となります。
```bash
~]# sesearch -T -s init_t -c process
```
httpd_t ドメインが tmp_t タイプのディレクトリにファイルを作成したときのタイプ遷移を許可するルール一覧を表示するときのコマンドは以下となります。
```bash
~]# sesearch -T -s httpd_t -t tmp_t -c file
```
httpd_can_network_connect という Boolean の on/off で有効化/無効化されるルールの一覧を表示するときのコマンドは以下となります。
```bash
~]# sesearch -A -b httpd_can_network_connect
```

ポリシールールの検索では、検索結果でアクセス元タイプ (source_type) やアクセス先タイプ (target_type) に末尾が `_t` ではないものが表示される場合があります。
ポリシールールにおいて、タイプの末尾が `_t` ではないとき、それは属性 (Attribute) です。
タイプは複数の属性を持つことができます。
例えば、http_port_t タイプは port_type 属性を持っています。
ポリシールールの定義では、属性を使うことでタイプだけが異なるルールをまとめて1つのルールで定義できるようになります。

ポリシールールの検索においては、検索結果で現れた属性 (Attribute) を持っているタイプを調べるために seinfo コマンドを使います。
seinfo コマンドは、SELinuxオブジェクトの情報を表示するツールです。
`-a` (Attribute) オプションで属性を指定し、`-x` (Expand) でより詳細な情報を表示します。
以下は、port_type 属性を持つタイプの中に、http_port_t が含まれていることを確認するコマンドの例です。

```bash
~]# seinfo -a port_type -x
Type Attributes: 1
   attribute port_type;
        afs3_callback_port_t
        afs_bos_port_t
        ...
        http_cache_port_t
        http_port_t               <-- http_port_tタイプはport_type属性を持つ
        i18n_input_port_t
        ...
```

このように、ポリシールールの検索でタイプの末尾が `_t` 以外のものが現れたら属性として扱い、seinfo コマンドでその属性を持つタイプを調査することで、ルールが許可しているサブジェクトやオブジェクトのタイプは何かを知ることができます。



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
- result : アクセスを拒否したときは denied、auditallowルールで許可ログを出力するときは granted と表示されます。
- access_vector : オブジェクトマネージャによって識別したアクション。read, write, exec など
- pid=, **comm=** : タスクの場合は、実行したプロセスのプロセスIDと、実行したコマンドのパス名
- dev=, **ino=**, **path=** : アクセス対象のリソースを管理するデバイス番号と、inode番号、パス名
  - ino= : inode番号からアクセス先のファイルの場所は、`find / -inum <inode番号>` で調べることができます
  - path= : パス名はアクションによってログに記録されない場合があります
- **name=** : アクセス対象のファイル名や、ディレクトリ名 (この属性はログに含まれない場合もある)
- **scontext=** : アクセス元 (サブジェクト) のセキュリティコンテキスト
- **tcontext=** : アクセス先 (オブジェクト) のセキュリティコンテキスト
- **tclass=** : アクセス先のオブジェクトのクラス。file, dir, tcp_socket など
- permissive= : SELinuxがPermissiveで動作したか (検知したが拒否しないモードであったか)

それでは実際の拒否ログを使いながら、ログの属性値を参考に、拒否ログを読み解くための手順について紹介します。
まず、監査ログに記録された拒否ログは以下のような内容だとします。
```
type=AVC msg=audit(1558865501.958:282): avc:  denied  { write } for  pid=1647 comm="httpd" name="upload" dev="dm-0" ino=33584792 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```
この拒否ログについて、拒否ログの属性値から情報を収集していきます。
1. `denied` から、SELinuxが何らかのアクションを拒否したことがわかります。
2. `tclass=dir` と `{ write }` から、ディレクトリへの書き込みが拒否されたことがわかります。
3. `ino=33584792` から、`find / -inum 33584792` で対象のパスを検索し、オブジェクトの場所を確認します。ここでは検索結果が /var/www/html だとします。
4. `scontext=...:httpd_t:...` から、上記のアクションを実行したプロセスは「httpd_t」ドメインで動作していたことがわかります。
5. `tcontext=...:httpd_sys_content_t:...` から、対象のディレクトリ /var/www/html のタイプは「httpd_sys_content_t」であったことがわかります。
6. `msg=audit(1558865501.958:282)` から数字の 1558865501 をUNIX時刻からローカル時刻に変換して、取得した時刻 2019/5/26 19:11:41 から拒否ログ発生時刻を特定します。
7. まとめると、拒否ログは「時刻 2019/5/26 19:11:41 に httpd_t ドメインのプロセスが /var/www/html のディレクトリに書き込みを試みたが、httpd_t は httpd_sys_content_t への書き込み権限が許可されていないため拒否された」という意味になります。

以上が拒否ログを読むための大まかな手順になります。
さらに様々な種類の拒否ログを読むためには、tclass のオブジェクトクラスの種類 (file, dir, tcp_socket, ... など) と、アクションの種類 (read, write, exec, ... など) を理解する必要があります。
オブジェクトクラスとアクションの対応関係の詳細は、[SELinux Notebook](https://github.com/SELinuxProject/selinux-notebook) に書かれています。
特に以下のページでは、全てのオブジェクトクラスとアクションについての説明が書かれているので、不明なオブジェクトクラスやアクションが現れた場合は、ここを確認するのをおすすめします。

- [Appendix A - Object Classes and Permissions \| SELinuxProject/selinux-notebook](https://github.com/SELinuxProject/selinux-notebook/blob/main/src/object_classes_permissions.md)

代表的なオブジェクトクラスとアクション (権限) について、以下にまとめました。
ここに列挙したものだけでも覚えておくと、ログを見る際にも役に立つと思います。

代表的なドメイン (Domain)：
- init_t : systemdのプロセス (initを廃止してsystemdを導入したが、ドメイン名はそのまま)
- sshd_t : SSHサーバのプロセス
- httpd_t : Webサーバのプロセス
- named_t : DNSサーバのプロセス
- postfix_master_t : メールサーバのプロセス
- mysqld_t : DBサーバのMySQLのプロセス
- postgresql_t : DBサーバのPostgreSQLのプロセス
- container_runtime_t : dockerdのプロセス
- kernel_t : カーネルのプロセス
- unconfined_t : 制限のないSELinuxユーザのプロセス
- unconfined_service_t : 制限のないサービスのプロセス

代表的なオブジェクトクラス (Object Class)：
- dir : ディレクトリ
- file : ファイル
- lnk_file : シンボリックリンク
- tcp_socket : TCPソケット
- udp_socket : UDPソケット

代表的な権限 (Permission)：
- add_name : ディレクトリ内にファイルを作成する
- append : ファイル内容の末尾に追記する (writeとは異なる)
- getattr : ファイルなどの属性情報を取得する
- link : ファイルのハードリンクを作成する
- name_bind : デーモンがポートを使用して待ち受ける
- name_connect : デーモンが外部ポートと通信する
- read : ファイル内容を読む
- remove_name : ファイルを削除する
- rename : ファイル名を変更する
- rmdir : ディレクトリを削除する
- search : ディレクトリ内を検索できる
- transition : 新しいタイプ・ドメインに遷移する
- write : ファイルに内容を書き込む



#### SELinuxによる拒否ログを見つける

SELinuxの拒否ログは /var/log/audit/audit.log や /var/log/messages に出力されます。
SELinuxに関するログを見つけるには「denied」や「SELinux is preventing」でgrepで抽出します。

/var/log/audit/audit.log には「denied」というメッセージとともに拒否ログが記録されます。
そのため、grepで検索する際は「denied」という文字列で検索します。

```bash
~]# grep "denied" /var/log/audit/audit.log
# または
~]# tail -f /var/log/audit/audit.log | grep "denied"
```
ヒットする拒否ログの例：
```
type=AVC msg=audit(0000000000.639:792): avc:  denied  { read } for  pid=4635 comm="cat" name="example.txt" dev="dm-0" ino=33575049 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:admin_home_t:s0 tclass=file permissive=0
```

/var/log/messages には「SELinux is preventing」というメッセージとともに拒否ログが記録されます。
そのため、grepで検索する際は「SELinux is preventing」という文字列で検索します。

```bash
~]# grep "SELinux is preventing" /var/log/messages
# または
~]# tail -f /var/log/messages | grep "SELinux is preventing"
```
ヒットする拒否ログの例：
```
localhost setroubleshoot[4637]: SELinux is preventing /usr/bin/cat from read access on the file example.txt. For complete SELinux messages run: sealert -l e9c5f189-8574-4467-8c68-6d4c7b79b6bd
```


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

まず、SELinuxで現れる専門用語について説明します。

- **アクセスベクタ (AV)** : AV (Access Vector) は、一連の読み書きなどのアクセス許可を表すビットマップです。

- **アクセスベクタキャッシュ (AVC)** : **AVC** (Access Vector Cache) は、オブジェクトマネージャの処理速度を速くするために、セキュリティサーバが行ったアクセス制御の判断を保存します。

- **ドメイン (Domain)** : ドメインは、プロセスに対応するセキュリティコンテキストのタイプです。
型強制 (TE; Type Enforcement) のルールは、ドメインとオブジェクトの関係性を定義します。

- **オブジェクトクラス (Object Class)** : オブジェクトクラスは、ファイル、ソケット、サービスを含むオブジェクトへの読み書きなどの権限を記述するためのクラスです。
オブジェクトマネージャは、インスタンス化されたオブジェクトにアクセスを強制します。

- **オブジェクトマネージャ (Object Manager)** : 制御下にあるオブジェクトのラベル付け、管理（作成、アクセス、破棄など）、および適用を担当するユーザースペースおよびカーネルコンポーネント。
オブジェクトマネージャは、ソースとターゲットのセキュリティコンテキスト (SID)、オブジェクトクラス、および一連のアクセス許可 (AV) に基づいて、アクセスを決定するためにセキュリティサーバを呼び出します。
セキュリティサーバは、現在ロードされているポリシーがアクセスを許可するか拒否するかに基づいて決定を下します。
オブジェクトマネージャは、セキュリティサーバを呼び出して、オブジェクトの新しいセキュリティコンテキスト (SID) を導出することもできます。

- **ポリシー (Policy)** : ポリシーは、アクセス権を決定する一連のルールです。
SELinuxでは、これらのルールは通常、m4マクロ (参照ポリシー) またはCIL言語のカーネルポリシ言語で記述されます。
次に、ポリシーはセキュリティサーバにロードするためにバイナリ形式にコンパイルされます。

- **ロールに基づくアクセス制御 (RBAC)** : SELinuxユーザは、RBAC (Role Based Access Control) によってアクセス制御されます。
SELinuxユーザは1つ以上のロールに関連付けられ、各ロールは1つ以上のドメインタイプに関連付けられます。

- **セキュリティサーバ (Security Server)** : セキュリティサーバは、SELinux対応アプリケーションおよびオブジェクトマネージャーに代わってアクセスの決定を行い、ポリシーに基づいてセキュリティコンテキストを導出するLinuxカーネルのサブシステムです。
セキュリティサーバは決定を強制せず、ポリシーに従って操作が許可されているかどうかを示すだけです。
決定を実施するのは、SELinux対応のアプリケーションまたはオブジェクトマネージャの責任です。

- **セキュリティコンテキスト (Security Context)** : SELinuxセキュリティコンテキストは、次の必須の要素 user:role:type とオプションの [:range] 要素で構成される可変長文字列です。
セキュリティコンテキストは「コンテキスト」と省略され、「ラベル」と呼ばれることもあります。

- **セキュリティ識別子 (SID)** : SIDは、セキュリティコンテキストを表すカーネルセキュリティサーバとユーザースペースAVCによってマップされた一意の整数値です。
カーネルセキュリティサーバによって生成されるSIDは、Linuxセキュリティモジュールフックを介してカーネルオブジェクトマネージャーとの間で受け渡されるuint32の値です。

- **Type Enforcement (TE)** : SELinuxは、特定のスタイルのタイプ強制 (TE) を使用して、強制アクセス制御 (MAC) を強制します。
TEは、すべてのサブジェクトとオブジェクトにタイプ識別子を関連付けして、ポリシーによって定められたルールを適用します。

SELinuxは、型強制 (TE; Type Enforcement)、ロールに基づくアクセス制御 (RBAC)、多層階セキュリティ (MLS) の3種類のアクセス制御機能を提供します。
その中で、特に重要なのは Type Enforcement です。
SELinuxのTEモデルは、プロセスにはドメインを付与し、オブジェクトにはタイプを付与し、これらのセキュリティコンテキストをアクセスベクタと比較してアクセス許可を判断します。

次に、SELinuxが提供している機能の全体像は以下の図に示します。

<figure>
<img src="{{ site.baseurl }}/media/book/selinux/2-high-level-arch.png" width=800px />
<figcaption>SELinuxのアーキテクチャ</figcaption>
</figure>

特に重要な点だけ掻い摘んで説明すると、以下のポイントがあります。

- セキュリティサーバは、カーネルに組み込まれています。
- ポリシーは、ユーザ空間で作成されて、libselinux ライブラリを介して読み込まれます。
- 設定ファイルは /etc/selinux に格納されています。
- SELinuxは「モジュール指向のポリシー」に対応しており、複数のモジュールからポリシーを構成しています。
- ポリシーを作成するにはポリシーソースが必要です。ポリシーソースは、カーネルポリシー言語 (TE) やマクロ (m4)、共通中間言語 (CIL) を使用します。
- ポリシーソースをコンパイルしてSELinuxに読み込むには、checkmodule, semodule_package, semodule などの複数のツールが必要です。
- システム管理者がポリシーを管理できるようにするために、Linuxの一部のコマンドはSELinux用に変更されます。
- SELinuxによるログは、監査ログに記録されます。
- SELinuxはネットワークにラベル付けすることも可能です。
