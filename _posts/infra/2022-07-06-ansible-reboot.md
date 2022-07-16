---
layout:        post
title:         "Ansibleのrebootモジュールで再起動する"
date:          2022-07-06
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

Ansible で対象サーバを再起動したい場合は、ansible.builtin.reboot モジュールを使用します。

### ansible.builtin.reboot の使用例

以下は対象サーバは再起動するための設定例です。
ansible.builtin.reboot では reboot_timeout オプションでサーバが再起動するまでの最大待機時間を指定できます。
最大待機時間のデフォルトは600秒 (10分) です。

なお、rebootしても後続の処理を続けることができます。
今回の例ではreboot後の600秒以内にサーバにログインできた場合、後続の処理が実行されます。
今回は確認のために ping していますが、本番では ping は不要です。

```yml
---
- hosts: servers
  tasks:
  - name: Reboot
    ansible.builtin.reboot: reboot_timeout=600
    become: true

  - name: Ping Connection
    ansible.builtin.ping:
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Reboot] ******************************************************************
changed: [aws-rhel]
TASK [Ping Connection] *********************************************************
ok: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

以上です。

### 参考文献
- [ansible.builtin.reboot module – Reboot a machine — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/reboot_module.html)

