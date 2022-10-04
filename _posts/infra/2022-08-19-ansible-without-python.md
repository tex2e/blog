---
layout:        post
title:         "Ansibleで接続先にpythonが存在しないとき"
date:          2022-08-19
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

Ansibleで接続先にpythonが存在しないときや、pythonコマンドが実行できない時は、Ansibleのrawモジュールを使用して、直接シェルコマンドを実行することで解決できます。

通常、Ansibleを実行する際に接続先にPythonが存在しないとエラーになります。

```
fatal: [xxx.xxx.xxx.xxx]: FAILED! => {
    "changed": false,
    "failed": true,
    "module_stderr": "Shared connection to xxx.xxx.xxx.xxx closed.\r\n",
    "module_stdout": "/bin/sh: 1: /usr/bin/python: not found\r\n",
    "msg": "MODULE FAILURE",
    "rc": 0
}
```

接続先でPythonが使えない場合は、Ansibleのrawモジュールを使用します。
使い方は通常の command や shell モジュールと同じように使えます。

{% raw %}

```yml
---
- hosts: all
  vars:
    user: tex2e

  tasks:
    - name: Add user
      ansible.builtin.raw: useradd -m {{user}}

    - name: Create file
      ansible.builtin.raw: |-
        echo "Hello, world" >> /tmp/test.log
```

{% endraw %}

以上です。

### 参考文献

- [ansible.builtin.raw module – Executes a low-down and dirty command — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/raw_module.html)
- [Simple Ansible paybook without Python installed in target machines \| by Somak Das \| Medium](https://somakdas.medium.com/simple-ansible-paybook-without-python-installed-in-target-machines-1df423004da5)
