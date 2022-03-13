---
layout:        post
title:         "curlとwgetコマンドをAppArmorで制限する"
date:          2021-12-09
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

curlとwgetコマンドが実行できないようにAppArmorで制限する方法について説明します。

まず、AppArmorで使用するプロファイルを作成するためのパッケージをインストールします。
なお、プロファイルは手動で作成・適用をすることも可能なので、必ず必要なパッケージというわけではありません。
```bash
~# apt install apparmor-utils
```

### curlを制限する

aa-genprofコマンドを使って、curl用のプロファイルを作成します。
システムログから許可ルールを追加する作業をせずに「F」を入力して終了することで、ほぼ何も許可しないため、curlの実行を制限することができます。
```bash
~# aa-genprof curl
Writing updated profile for /usr/bin/curl.
Setting /usr/bin/curl to complain mode.
...
[(S)can system log for AppArmor events] / (F)inish
<Fを入力>
Setting /usr/bin/curl to enforce mode.
...
Reloaded AppArmor profiles in enforce mode.
...
Finished generating profile for /usr/bin/curl.
```
プロファイルは /etc/apparmor.d ディレクトリに作成されるので、usr.bin.curl が作成されたことを確認します。
```bash
~# cat /etc/apparmor.d/usr.bin.curl
#include <tunables/global>

/usr/bin/curl {
  #include <abstractions/base>

  /usr/bin/curl mr,

}
```
プロファイルが有効化されていると、curlで通信ができなくなります。
```bash
~# aa-status | grep curl
   /usr/bin/curl
~# curl example.com
curl: (6) Could not resolve host: example.com
```
usr.bin.curlプロファイルを一時的に無効化 (-R) すると、curlが実行できるようになります。
```bash
~# apparmor_parser -R /etc/apparmor.d/usr.bin.curl
~# aa-status | grep curl
~# curl example.com
<!doctype html>
<html>
<head>
    <title>Example Domain</title>
...
```
usr.bin.curlプロファイルを一時的に有効化すると、curlが実行できなくなります。
```bash
~# apparmor_parser /etc/apparmor.d/usr.bin.curl
~# aa-status | grep curl
   /usr/bin/curl
~# curl example.com
curl: (6) Could not resolve host: example.com
```
AppArmorで制限されたcurlを実行したときのログ (kern.log) は、以下のような拒否ログが出力されます。
```bash
~# tail -f /var/log/kern.log | grep -i denied
audit: type=1400 audit(0000000000.768:93): apparmor="DENIED" operation="open" profile="/usr/bin/curl" name="/etc/ssl/openssl.cnf" pid=5317 comm="curl" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.768:94): apparmor="DENIED" operation="create" profile="/usr/bin/curl" pid=5317 comm="curl" family="inet6" sock_type="dgram" protocol=0 requested_mask="create" denied_mask="create"
audit: type=1400 audit(0000000000.804:95): apparmor="DENIED" operation="open" profile="/usr/bin/curl" name="/etc/host.conf" pid=5317 comm="curl" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.804:96): apparmor="DENIED" operation="open" profile="/usr/bin/curl" name="/run/systemd/resolve/stub-resolv.conf" pid=5317 comm="curl" requested_mask="r" denied_mask="r" fsuid=0 ouid=101
audit: type=1400 audit(0000000000.804:97): apparmor="DENIED" operation="open" profile="/usr/bin/curl" name="/etc/nsswitch.conf" pid=5317 comm="curl" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.804:98): apparmor="DENIED" operation="create" profile="/usr/bin/curl" pid=5317 comm="curl" family="inet" sock_type="dgram" protocol=0 requested_mask="create" denied_mask="create"
```

なお、プロファイルを永続的に有効化したいときは「aa-enforce」、無効化したいときは「aa-disable」コマンドをプロファイルを指定して実行します。
```bash
~# aa-enforce /etc/apparmor.d/usr.bin.curl
Setting /etc/apparmor.d/usr.bin.curl to enforce mode.

~# aa-disable /etc/apparmor.d/usr.bin.curl
Disabling /etc/apparmor.d/usr.bin.curl.
```

<br>

### wgetを制限する

続いて、wgetの制限をするプロファイルも作成して、AppArmorでwgetが実行できないように制限してみます。
```bash
~# aa-genprof wget
Profiling: /usr/bin/wget
...
[(S)can system log for AppArmor events] / (F)inish
<Fを入力>
...
Finished generating profile for /usr/bin/wget.
```
作成されたプロファイルを表示し、内容がwgetであることを確認します。
```bash
~# cat /etc/apparmor.d/usr.bin.wget
#include <tunables/global>

/usr/bin/wget {
  #include <abstractions/base>

  /usr/bin/wget mr,

}
```
プロファイルusr.bin.wgetが有効化されていると、wgetで通信ができなくなります。
```bash
~# aa-status | grep wget
   /usr/bin/wget
~# wget example.com
Failed to Fopen file /etc/wgetrc
Failed to Fopen file /etc/wgetrc
wget: Cannot read /etc/wgetrc (Permission denied).
----  http://example.com/
Resolving example.com (example.com)... failed: Temporary failure in name resolution.
wget: unable to resolve host address ‘example.com’
```
usr.bin.wgetプロファイルを一時的に無効化 (-R) すると、wgetが実行できるようになります。
```bash
~# apparmor_parser -R /etc/apparmor.d/usr.bin.wget
~# aa-status | grep wget
~# wget example.com
----  http://example.com/
Resolving example.com (example.com)... 93.184.216.34, 2606:2800:220:1:248:1893:25c8:1946
Connecting to example.com (example.com)|93.184.216.34|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1256 (1.2K) [text/html]
Saving to: ‘index.html’

index.html                    100%[=================================================>]   1.23K  --.-KB/s    in 0s

 (131 MB/s) - ‘index.html’ saved [1256/1256]
```
AppArmorで制限されたwgetを実行したときのログ (kern.log) は、以下のような拒否ログが出力されます。
```bash
~# tail -f /var/log/kern.log | grep -i denied
audit: type=1400 audit(0000000000.504:100): apparmor="DENIED" operation="open" profile="/usr/bin/wget" name="/etc/wgetrc" pid=5432 comm="wget" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.524:101): apparmor="DENIED" operation="open" profile="/usr/bin/wget" name="/etc/nsswitch.conf" pid=5432 comm="wget" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.524:102): apparmor="DENIED" operation="open" profile="/usr/bin/wget" name="/etc/host.conf" pid=5432 comm="wget" requested_mask="r" denied_mask="r" fsuid=0 ouid=0
audit: type=1400 audit(0000000000.524:103): apparmor="DENIED" operation="open" profile="/usr/bin/wget" name="/run/systemd/resolve/stub-resolv.conf" pid=5432 comm="wget" requested_mask="r" denied_mask="r" fsuid=0 ouid=101
audit: type=1400 audit(0000000000.524:104): apparmor="DENIED" operation="create" profile="/usr/bin/wget" pid=5432 comm="wget" family="inet" sock_type="dgram" protocol=0 requested_mask="create" denied_mask="create"
```

以上です。

#### 参考文献
- [Home · Wiki · AppArmor / apparmor · GitLab](https://gitlab.com/apparmor/apparmor/-/wikis/home)
- [Profiles · Wiki · AppArmor / apparmor · GitLab](https://gitlab.com/apparmor/apparmor/-/wikis/Profiles)
- [Documentation · Wiki · AppArmor / apparmor · GitLab](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)

