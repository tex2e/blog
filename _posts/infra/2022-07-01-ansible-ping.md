---
layout:        post
title:         "[Ansible] pingモジュールを使う"
date:          2022-07-01
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

Ansibleでホストとの接続確認をするには、組み込みの ansible.builtin.ping モジュールを使用します。

### ansible.builtin.ping の使用例

Ansible Playbookでpingする場合は以下のように書きます。

```yml
---
- hosts: servers
  tasks:
  - name: Ping Connection
    ansible.builtin.ping:
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml 
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Ping Connection] *********************************************************
ok: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```


### Playbookを使わないで直接呼び出す場合
pingモジュールを直接呼び出して使用することもできます。
```bash
$ ansible -i inventory.ini servers -m ping
aws-rhel | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

以上です。

### 参考文献
- [ansible.builtin.ping module – Try to connect to host, verify a usable python and return pong on success — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html)
