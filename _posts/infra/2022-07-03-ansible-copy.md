---
layout:        post
title:         "Ansibleのcopyモジュールでファイルコピーする"
date:          2022-07-03
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

Ansibleでファイルをコピーするには、ansible.builtin.copy モジュールを使用します。

### ansible.builtin.copy の使用例

copy モジュールでは、以下の2種類のコピー方法があります。

- (A) ローカルにあるファイルをリモートにコピーする場合 (remote_src: false)
- (B) リモート内でファイルをコピーする場合 (remote_src: true)

また、backup オプションを有効にすると、コピー先が存在するときに元ファイル名のタイムスタンプを追加して移動してからコピーをするようになります。

```yml
---
- hosts: servers
  tasks:
  - name: Copy file from remote    <--(A)
    ansible.builtin.copy:
      remote_src: true
      src: /etc/hosts
      dest: /home/ec2-user/tmp/

  - name: Copy file from local     <--(B)
    ansible.builtin.copy:
      src: ./upload/hosts
      dest: /home/ec2-user/tmp/
      backup: true
```

実行結果：

```bash
$ cat upload/hosts
127.0.0.1  www.example.local
$ ansible-playbook -i inventory.ini sample-playbook.yml     
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Copy file from remote] ***************************************************
changed: [aws-rhel]
TASK [Copy file from local] ****************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

確認コマンド：

```bash
[ec2-user@ip-172-XX-XX-XX ~]$ ls -al ~/tmp
-rw-rw-r--. 1 ec2-user ec2-user  29  7月 10 04:39 hosts
-rw-rw-r--. 1 ec2-user ec2-user 158  9月 10  2018 hosts.8796.2022-07-10@04:39:46~
```

ansible.builtin.copy モジュールでは、他にも
force (強制上書き)、group (所属グループ)、owner (所有者)、mode (権限)、validate (ファイル内容の構文チェックなど)
などのオプションを設定できます。
詳細は公式ドキュメントを参照ください。

### 参考文献
- [ansible.builtin.copy module – Copy files to remote locations — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
