---
layout:        post
title:         "[Ansible] SSH公開鍵認証からプレイブック実行までの流れ"
date:          2022-05-04
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

Ansibleの使い方について、簡単に説明します。

Ansibleはリモートでコマンドを実行するために、sshでサーバに接続します。
Ansibleを使うためには、まずSSHの公開鍵認証でサーバに接続できるようにします。

### 秘密鍵と公開鍵の生成
ssh-keygen コマンドを利用して、秘密鍵と公開鍵の生成します。
ここでは、鍵の生成にSSH認証において最強の鍵である楕円曲線暗号 ed25519 を使用しています。
すでに鍵を作成済みの場合、再作成する必要はありません
```bash
$ ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

### 接続先情報の設定
SSHでサーバに接続する際の情報を ~/.ssh/config に追加します。各設定項目は以下の通りです。
- **Host** : サーバ名（HostNameを指定する場合は識別子）
    - **HostName** : サーバのIP（省略可）
    - **User** : サーバログイン時に使用するユーザ名
    - **IdentityFile** : サーバログイン時に使用する

~/.ssh/config には以下のように設定を追加します。この場合、`ssh centos8` や `ssh mako@192.168.11.102` で接続できるようになります。
```conf
Host centos8
  HostName 192.168.11.102
  User mako
  IdentityFile ~/.ssh/id_ed25519
```

### サーバに公開鍵を登録する
ssh-copy-id コマンドを利用して、生成した公開鍵をサーバの ~/.ssh/authorized_keys に追加します。
このコマンドを使わない方法もありますが、ssh-copy-id の使用を推奨します [^1]。
```bash
$ ssh-copy-id -i ~/.ssh/id_ed25519 centos8
```

[^1]: ssh-copy-id コマンドを利用しないでサーバに公開鍵を登録するには、以下のコマンドを実行します。
    ```bash
    $ cat ~/.ssh/id_ed25519.pub | ssh ホスト名 'mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
    ```

### 公開鍵認証の確認
サーバに登録した公開鍵でログインできることを以下のコマンドで確認します。
```bash
$ ssh centos8
```
または
```bash
$ ssh mako@192.168.11.102
```

### Ansibleの疎通確認
インベントリは、ターゲットノードの接続情報を記載したファイルです。
接続先のサーバ情報をインベントリファイル「inventory.ini」に書いて、新規ファイルとして保存します。
```ini
[linuxservers]
centos8 ansible_host=192.168.11.102
```

以下の ansible コマンドを実行し、ping モジュールによる疎通を確認します。
```bash
$ ansible all -i inventory.ini -m ping
```

結果は json 形式で表示されます。SUCCESS であれば疎通できていることが確認できます。
```res
centos8 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

### Ansibleによるコマンドの実行
Ansibleでは、プレイブックにYAML形式で自動化する内容を記述します。
ここでは、ファイル mytest.yml に以下の内容を書き、/etc/os-release の内容を表示するプレイブックを作成します。

{% raw %}

```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Get OS version
      command: cat /etc/os-release
      register: res_command

    - name: Show Result
      debug:
        msg: "{{ res_command['stdout_lines'] }}"
```

{% endraw %}

以下の ansible-playbook コマンドでプレイブックを実行します。
```bash
$ ansible-playbook -i inventory.ini mytest.yml
```

実行結果：
```output
PLAY [linuxservers] *****************************************************************

TASK [Get OS version] ***************************************************************
changed: [centos8]

TASK [Show Result] ******************************************************************
ok: [centos8] => {
    "msg": [
        "NAME=\"CentOS Stream\"",
        "VERSION=\"8\"",
        "ID=\"centos\"",
        "ID_LIKE=\"rhel fedora\"",
        "VERSION_ID=\"8\"",
        "PLATFORM_ID=\"platform:el8\"",
        "PRETTY_NAME=\"CentOS Stream 8\"",
        "ANSI_COLOR=\"0;31\"",
        "CPE_NAME=\"cpe:/o:centos:centos:8\"",
        "HOME_URL=\"https://centos.org/\"",
        "BUG_REPORT_URL=\"https://bugzilla.redhat.com/\"",
        "REDHAT_SUPPORT_PRODUCT=\"Red Hat Enterprise Linux 8\"",
        "REDHAT_SUPPORT_PRODUCT_VERSION=\"CentOS Stream\""
    ]
}

PLAY RECAP **************************************************************************
centos8                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

### Ansibleによるサービス起動
サービス起動を定義したプレイブック mytest2.yml を以下の内容で作成します。
```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Start httpd service
      service:
        name: httpd
        state: started
      become: true
```

ansible-playbook コマンドでプレイブックを実行します。
今回は root に昇格する必要があるため、become で root ユーザに sudo で昇格するときのパスワードを入力するためのオプション --ask-become-pass を追加します。
```bash
$ ansible-playbook -i inventory.ini mytest3.yml --ask-become-pass
```

実行結果：
```output
BECOME password: rootパスワードを入力

PLAY [linuxservers] *****************************************************************

TASK [Start httpd service] **********************************************************
changed: [centos8]

PLAY RECAP **************************************************************************
centos8                    : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

### Ansibleによるファイアウォール管理
HTTPのポートをファイアウォールで開く方法を定義したプレイブック mytest3.yml を以下の内容で作成します。
```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Permit traffic for http service
      firewalld:
        service: http
        permanent: true
        state: enabled
      become: true
```
ansible-playbook コマンドでプレイブックを実行します。
```bash
$ ansible-playbook -i inventory.ini mytest3.yml --ask-become-pass
```

### Ansibleによるユーザ管理
ユーザのパスワードを設定するプレイブック mytest4.yml を以下の内容で作成します。
```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Create user
      user:
        name: testuser
        password: testuser123
      become: true
```

ansible-playbook コマンドでプレイブックを実行します。
```bash
$ ansible-playbook -i inventory.ini mytest4.yml --ask-become-pass
```

### 条件の設定 (when)
特定のホストで特定の処理をスキップしたいときは、whenステートメントを使用します。
ansible_facts という変数には、接続先のホストの情報が格納されており、whenを使って条件を満たすときのみ処理を実行するということを実現します。
```yaml
---
- hosts: linuxservers

  tasks:
    - name: shut down CentOS 7 systems
      command: /sbin/shutdown -t now
      when: ansible_facts['distribution'] == "CentOS" and ansible_facts['distribution_major_version'] == "7"
```

### ループ文 (loop)
処理を繰り返したいときは、loopを使用します。繰り返しでリストに参照する際の変数名は「item」です。

{% raw %}

```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Add Users
      user:
        name: "{{ item }}"
        state: present
      loop:
        - testuser1
        - testuser2
      become: true
```

{% endraw %}

リストの要素は、文字列だけでなくハッシュ（連想配列）にすることも可能です。

{% raw %}

```yaml
---
- hosts: linuxservers
  gather_facts: false

  tasks:
    - name: Add Users
      user:
        name: "{{ item.name }}"
        state: present
        groups: "{{ item.groups }}"
      loop:
        - { name: 'testuser1', groups: 'wheel' }
        - { name: 'testuser2', groups: 'root' }
      become: true
```

{% endraw %}

以上です。

#### 参考文献
- [Playbook の使用 — Ansible Documentation](https://docs.ansible.com/ansible/2.9_ja/user_guide/playbooks.html)
- [User Guide — Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/index.html)

---
