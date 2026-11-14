---
layout:        post
title:         "[Ansible] 接続先にpythonが存在しないときの対処法"
type:          Troubleshooting
description:   "Ansible実行先のホストにPythonが存在せずエラーになる場合に、ansible.builtin.rawモジュールで直接シェルコマンドを実行する対処法。"
tags:          [infra, ansible, python, troubleshooting]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-08-19T14:19:39Z
sources:
  - id:        ref-1
    resource:  https://docs.ansible.com/ansible/latest/collections/ansible/builtin/raw_module.html
    title:     "ansible.builtin.raw module – Executes a low-down and dirty command — Ansible Documentation"
  - id:        ref-2
    resource:  https://somakdas.medium.com/simple-ansible-paybook-without-python-installed-in-target-machines-1df423004da5
    title:     "Simple Ansible paybook without Python installed in target machines \\| by Somak Das \\| Medium"
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
