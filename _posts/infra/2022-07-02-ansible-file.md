---
layout:        post
title:         "[Ansible] fileモジュールでfileやdirの権限を設定する"
date:          2022-07-02
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

Ansibleでfileやdirの権限を設定したり、リンクを作成したりするには、組み込みの ansible.builtin.file モジュールを使用します。

### ansible.builtin.file の使用例

以下の例では、次の3つのタスクを実行しています。

1. ディレクトリ (/home/ec2-user/tmp) の作成
2. ファイル (/home/ec2-user/tmp/setup.sh) の作成と実行権限の付与 (755)
   - mode で実行権限を付ける際は `mode: +x` のように書くこともできます。
3. リンク (s.sh -> setup.sh) の作成


```yaml
---
- hosts: servers
  tasks:
  - name: Create directory           <--(1)
    ansible.builtin.file:
      path: /home/ec2-user/tmp
      state: directory

  - name: Create empty file          <--(2)
    ansible.builtin.file:
      path: /home/ec2-user/tmp/setup.sh
      state: touch
      mode: 755

  - name: Create link                <--(3)
    ansible.builtin.file:
      path: /home/ec2-user/tmp/s.sh
      state: link
      src: /home/ec2-user/tmp/setup.sh
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Create directory] ********************************************************
changed: [aws-rhel]
TASK [Create empty file] *******************************************************
changed: [aws-rhel]
TASK [Create link] *************************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

確認コマンド：

```bash
[ec2-user@ip-172-XX-XX-XX ~]$ find ~/tmp -ls
      569      0 drwxrwxr-x   2  ec2-user ec2-user       34  7月 10 03:44 /home/ec2-user/tmp
      722      0 --wxrw--wt   1  ec2-user ec2-user        0  7月 10 03:44 /home/ec2-user/tmp/setup.sh
    32154      0 lrwxrwxrwx   1  ec2-user ec2-user       27  7月 10 03:44 /home/ec2-user/tmp/s.sh -> /home/ec2-user/tmp/setup.sh
```

ansible.builtin.file モジュールでは、他にも
access_time (アクセス日時)、modification_time (修正日時)、group (所属グループ)、owner (所有者)、recurse (再帰の有無) などのオプションを設定できます。
詳細は公式ドキュメントを参照ください。

### 参考文献
- [ansible.builtin.file module – Manage files and file properties — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)

