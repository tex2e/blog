---
layout:        post
title:         "[Ansible] userモジュールでユーザ作成する"
date:          2022-07-04
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

AnsibleでLinuxユーザを作成するには、ansible.builtin.user モジュールを使用します。

### ansible.builtin.user の使用例

以下はLinuxユーザ「example-user」を作成して、wheelグループに所属し、ログイン時のパスワードを「P@ssw0rd」に設定する処理を定義したものです。
ユーザの作成には root 権限が必要なので、`become: true` を指定します。

{% raw %}

```yml
---
- hosts: servers
  tasks:
  - name: Add user 'example-user'
    ansible.builtin.user:
      name: example-user
      groups: wheel
      password: "{{ 'P@ssw0rd' | password_hash('sha512') }}"
    become: true
```

{% endraw %}

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Add user 'example-user'] *************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

確認コマンド：

```bash
[ec2-user@ip-172-XX-XX-XX ~]$ cat /etc/passwd | grep example-user
example-user:x:1001:1001::/home/example-user:/bin/bash
[ec2-user@ip-172-XX-XX-XX ~]$ cat /etc/group | grep wheel
wheel:x:10:example-user
[ec2-user@ip-172-XX-XX-XX ~]$ su - example-user
パスワード: P@ssw0rd
[example-user@ip-172-XX-XX-XX ~]$
```

ansible.builtin.user モジュールでは、他にも
shell (ログイン時のシェル)、seuser (SELinuxのユーザタイプ)、generate_ssh_key (SSH鍵の生成) 
などのオプションを設定できます。
詳細は公式ドキュメントを参照ください。

### 参考文献
- [ansible.builtin.user module – Manage user accounts — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)
