---
layout:        post
title:         "Ansibleのreplaceモジュールでファイルの内容を編集する"
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

Ansible でファイルを編集する場合は、ansible.builtin.replace モジュールを使います。

### ansible.builtin.replace の使用例
以下は /etc/yum.conf 内にある *check= の設定値を書き換える方法です。
- path に編集するファイルパスを指定します。
- regexp に編集したい内容とマッチする正規表現を指定します。
- replace にマッチした後の置換文字列を指定します。丸括弧でマッチした部分は「\1」で展開することができます。

```yml
---
- hosts: servers
  tasks:
  - name: Update /etc/yum.conf
    become: true
    ansible.builtin.replace:
      path: /etc/yum.conf
      regexp: '(?<=check=)(\d+)'
      replace: '000\1'
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Update /etc/yum.conf] ****************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

確認コマンド：

```bash
~]# cat /etc/yum.conf 
[main]
gpgcheck=0001
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
```

gpgcheck=1 が gpgcheck=0001 に置換されました。
動作確認したら設定を元に戻しておきます。

以上です。

### 参考文献
- [ansible.builtin.replace module – Replace all instances of a particular string in a file using a back-referenced regular expression — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/replace_module.html)
