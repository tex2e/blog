---
layout:        post
title:         "Ansibleでfdiskを使ってパーティションを設定する"
date:          2022-07-09
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

fdisk は非対話モード (non-interactive) で実行することができます。
echo で入力するコマンドを出力し、それをパイプで fdisk に入れることで、非対話でもパーティションを設定することができます。

```bash
echo -e "n\np\n1\n\n\nw\n" | fdisk /dev/xvdb
```

以下、Ansible で fdisk を使ってパーティションを Linux LVM に設定する例です。

```yml
---
- hosts: servers
  tasks:
  # /dev/xvdbのパーティションをLinux LVMとして設定する。
  # すでに設定済みの場合は実行しない。

  - name: Check partition
    become: true
    ansible.builtin.shell:
      fdisk -l | grep xvdb
    register: fdisk_l_grep_xvdb
    changed_when: False

  - name: Set partition
    become: true
    ansible.builtin.shell:
      echo -e "n\np\n1\n\n\nt\n8e\nw\n" | fdisk /dev/xvdb
    when: not 'Linux LVM' in fdisk_l_grep_xvdb
```

実行結果：

```bash
$ ansible-playbook -i inventory.ini sample-playbook.yml     
PLAY [servers] *****************************************************************
TASK [Gathering Facts] *********************************************************
ok: [aws-rhel]
TASK [Set partition] ***********************************************************
changed: [aws-rhel]
PLAY RECAP *********************************************************************
aws-rhel                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

確認コマンド：

```output
[root@ip-172-XX-XX-XX ~]# lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  10G  0 disk 
├─xvda1 202:1    0   1M  0 part 
└─xvda2 202:2    0  10G  0 part /
xvdb    202:16   0   8G  0 disk 
└─xvdb1 202:17   0   8G  0 part 
[root@ip-172-XX-XX-XX ~]# 
[root@ip-172-XX-XX-XX ~]# fdisk -l
Disk /dev/xvda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: D209C89E-EA5E-4FBD-B161-B461CCE297E0

Device     Start      End  Sectors Size Type
/dev/xvda1  2048     4095     2048   1M BIOS boot
/dev/xvda2  4096 20971486 20967391  10G Linux filesystem


Disk /dev/xvdb: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xb2f800b1

Device     Boot Start      End  Sectors Size Id Type
/dev/xvdb1       2048 16777215 16775168   8G 8e Linux LVM
```

Shellを使わずに行う別の方法として linux-system-roles.storage ロールを使用する方法がありますが、Ansibleの送信元サーバと送信先サーバの両方に必要なパッケージをインストールする必要があります。
詳細は [Chapter 2. Managing local storage using RHEL System Roles Red Hat Enterprise Linux 8 \| Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/managing-local-storage-using-rhel-system-roles_managing-file-systems)
をご確認ください。

以上です。


### 参考文献
- [How to run fdisk in non-interactive batch mode](https://www.xmodulo.com/how-to-run-fdisk-in-non-interactive-batch-mode.html)
