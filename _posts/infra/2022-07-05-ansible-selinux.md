---
layout:        post
title:         "Ansibleのselinuxモジュールで無効化・有効化する"
date:          2022-07-05
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

Ansible で SELinux の有効化・無効化をするには、ansible.posix.selinux モジュールを使用します。
モジュールがない場合は `ansible-galaxy collection install ansible.posix` でインストールします。

### AnsibleでSELinux無効化
AnsibleでSELinuxを無効化する際は、disabled の設定をした後に reboot をする必要があります。
disabled をしただけだと permissive モードになるため、コマンドが拒否されるなどの事象は発生しませんが、監査ログ (audit.log) などには記録され続けます。

なお、rebootしても後続の処理を続けることができます。
今回の例ではreboot後の600秒(10分)以内にサーバにログインできた場合、後続の処理が実行されます。
確認のために ping していますが、本番では ping は不要です。

```yml
---
- hosts: servers
  tasks:
  - name: Disable SELinux
    ansible.posix.selinux: state=disabled
    become: true

  - name: Reboot
    ansible.builtin.reboot: reboot_timeout=600
    become: true
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Disable SELinux] *********************************************************
[WARNING]: SELinux state temporarily changed from 'enforcing' to 'permissive'. State change will take effect
next reboot.
changed: [aws-rhel]
TASK [Reboot] ******************************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

確認コマンド：

```bash
[ec2-user@ip-172-XX-XX-XX ~]$ grep "^SELINUX=" /etc/selinux/config 
SELINUX=disabled
[ec2-user@ip-172-XX-XX-XX ~]$ getenforce
Disabled
```


### AnsibleでSELinux有効化
AnsibleでSELinuxを有効化する際は、policy と enforcing の両方を設定した後に reboot をする必要があります。

```yml
---
- hosts: servers
  tasks:
  - name: Enable SELinux
    ansible.posix.selinux: state=enforcing policy=targeted
    become: true

  - name: Reboot
    ansible.builtin.reboot: reboot_timeout=600
    become: true
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml

PLAY [servers] *************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [aws-rhel]

TASK [Enable SELinux] ******************************************************************************************
[WARNING]: Reboot is required to set SELinux state to 'enforcing'
changed: [aws-rhel]

TASK [Reboot] **************************************************************************************************
changed: [aws-rhel]

PLAY RECAP *****************************************************************************************************
aws-rhel                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

確認コマンド：

```bash
[ec2-user@ip-172-XX-XX-XX ~]$ grep "^SELINUX=" /etc/selinux/config 
SELINUX=enforcing
[ec2-user@ip-172-XX-XX-XX ~]$ getenforce
Enforcing
```

以上です。

### 参考文献
- [ansible.posix.selinux module – Change policy and state of SELinux — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/posix/selinux_module.html)
- [ansible.builtin.reboot module – Reboot a machine — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/reboot_module.html)
