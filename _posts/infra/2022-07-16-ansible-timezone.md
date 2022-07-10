---
layout:        post
title:         "Ansibleのtimezoneモジュールでタイムゾーンを設定する"
date:          2022-07-16
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

Ansible でタイムゾーンの変更をするには、community.general.timezone モジュールを使用します。

### community.general.timezone の使用例
Ansibleのtimezoneモジュールの name に地域を指定します。
指定できる地域の一覧は `timedatectl list-timezones` コマンドで確認できます。

```yml
---
- hosts: servers
  tasks:
  - name: Set timezone to Asia/Tokyo
    community.general.timezone:
      name: Asia/Tokyo
    become: true
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml

PLAY [servers] *****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]

TASK [Set timezone to Asia/Tokyo] **********************************************
changed: [aws-rhel]

PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

確認コマンド：

```output
[ec2-user@ip-172-XX-XX-XX ~]$ timedatectl
               Local time: 日 2022-07-10 19:01:48 JST
           Universal time: 日 2022-07-10 10:01:48 UTC
                 RTC time: 日 2022-07-10 10:01:48
                Time zone: Asia/Tokyo (JST, +0900)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```


### 参考文献
- [community.general.timezone module – Configure timezone setting — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/community/general/timezone_module.html)
