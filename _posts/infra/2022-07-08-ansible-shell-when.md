---
layout:        post
title:         "Ansibleのshellモジュールの結果で条件分岐させる"
date:          2022-07-08
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

Ansibleで前のタスクの結果を使って、次のタスクを実行するかしないかを決めるには、when を使います。
また、前のタスクの結果は register で保存することができます。

### register と when による条件分岐
when はタスクを実行するかしないかを判断するために使います。
また、register は直前のタスクの結果を保存するために使います。

さらに、shell を実行する際は常に changed になってしまいますが、確認コマンドだけで changed はふさわしくないので、changed_when: False で常に changed にならないように設定します。

```yml
---
- hosts: servers
  tasks:
  - name: Check timezone
    shell: LANG=C timedatectl
    register: timezone
    changed_when: False

  - name: Set timezone to Asia/Tokyo
    shell: |
      timedatectl set-timezone Asia/Tokyo
      timedatectl
    become: true
    when: not 'Asia/Tokyo' in timezone.stdout
```

実行結果（1回目）：
```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Check timezone] **********************************************************
ok: [aws-rhel]
TASK [Set timezone to Asia/Tokyo] **********************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

実行結果（2回目）：
```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Check timezone] **********************************************************
ok: [aws-rhel]
TASK [Set timezone to Asia/Tokyo] **********************************************
skipping: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0 
```

実行結果：

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

Time zone が Asia/Tokyo になったことが確認できます。

以上です。

### 参考文献
- [ansible.builtin.shell module – Execute shell commands on targets — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)
- [第3章 日付と時刻の設定 Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-configuring_the_date_and_time)

