---
layout:        post
title:         "Ansibleのlineinfileモジュールでファイルに行を追加する"
date:          2022-07-15
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

Ansible でファイルに設定の行を追加する場合は、ansible.builtin.lineinfile モジュールを使います。

### ansible.builtin.lineinfile の使用例
以下は、/etc/hosts にIPを追加するように設定する例です。
- path には、編集したい対象のファイルパスを指定します。
- regexp オプションを指定すると、マッチした場合はその行を置換し、マッチしない場合は行の追加だけをします。
- line は置換後の行を指定します。

```yml
---
- hosts: servers
  tasks:
  - name: add IP to /etc/hosts
    become: true
    ansible.builtin.lineinfile:
      path: /etc/hosts
      regexp: '^172.17.0.1'
      line: '172.17.0.1  www.example.local'
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [add IP to /etc/hosts] ****************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

確認コマンド：

```bash
~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.17.0.1  www.example.local
```

以上です。

### 参考文献
- [lineinfile – Manage lines in text files — Ansible Documentation](https://docs.ansible.com/ansible/latest/modules/lineinfile_module.html)
