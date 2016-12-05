---
layout:        post
title:         "Gitの使い方（コマンド）"
menutitle:     "Gitの使い方（コマンド）"
date:          2016-09-23
tags:          Git Commands
category:      Git
author:        tex2e
cover:         /assets/mountain-alternative-cover.jpg
redirect_from:
comments:      false
published:     true
---

ここではGitの基本的な部分の説明しかしませんので、あしからず

目次
-------------

- Git 作業フロー
- 基本的なコマンド集
  - 初期設定
    - [Git リポジトリを初期化する (init)](#init)
    - [リポジトリの複製 (clone)](#clone)
    - [Git の設定の表示と変更 (config)](#config)
    - [リモートリポジトリを設定する (remote)](#remote)
  - 変更の反映
    - [変更をインデックスに登録 (add)](#add)
    - [変更をローカルリポジトリに反映 (commit)](#commit)
    - [リモートに変更を送る (push)](#push)
    - [リモートの変更を取得してマージする (pull)](#pull)
    - [リモートの変更を取得する (fetch)](#fetch)
    - [コミットのリセット (reset)](#reset)
  - ブランチ操作
    - [ブランチを操作する (branch)](#branch)
    - [作業ブランチを切り替える (checkout)](#checkout)
    - [他のブランチの変更内容をマージする (merge)](#merge)
    - [外部ツールを使って競合を解決する (mergetool)](#mergetool)
    - [ブランチの起点を変更する (rebase)](#rebase)
    - [他のブランチのコミットを取り込む (cherry-pick)](#cherry-pick)
  - 確認
    - [ファイルの状態を表示 (status)](#status)
    - [履歴を表示する (log)](#log)
    - [差分を表示する (diff)](#diff)
    - [コミットを表示する (show)](#show)
    - [リポジトリの操作履歴の確認 (reflog)](#reflog)
    - [Gitコマンドのヘルプ (help)](#help)


Git 作業フロー
-------------

概要

1. Branch : これから行う作業全体の内容を表すブランチを作ります
2. Commit : あとで読み返す時にわかりやすいコミットを心がけます
3. Push : 定期的にリモートに変更を送ります。小休憩の前に行うのがベストです
4. Pull : 他の人の変更をローカルに取り込みます。競合が発生する場合もあります
5. Merge : 複数のブランチを統合して、完成系に近づけます

基本的なコマンド集
----------------

### 初期設定

<a name="init"></a>

#### Git リポジトリを初期化する (init)

書式

`git init`

説明

新規リポジトリの作成をするときに使います。通常は .git という名前のディレクトリが作成されます。

~~~bash
$ # リポジトリの初期化
$ git init
Initialized empty Git repository in /path/to/dir/.git/
~~~

作成されるディレクトリの中身

~~~bash
.git
├── HEAD         # 現在のブランチの情報
├── config       # このリポジトリの設定
├── description  # このリポジトリの説明
├── hooks/       # フックスクリプト
│   ├── applypatch-msg.sample*
│   ├── commit-msg.sample*
│   ├── post-update.sample*
│   ├── pre-applypatch.sample*
│   ├── pre-commit.sample*
│   ├── pre-push.sample*
│   ├── pre-rebase.sample*
│   ├── prepare-commit-msg.sample*
│   └── update.sample*
├── info/
│   └── exclude  # このリポジトリで無視したいファイル
├── objects/     # Gitのバージョン管理オブジェクト
│   ├── info/
│   └── pack/
└── refs/        # ブランチやタグの参照情報
    ├── heads/
    └── tags/
~~~

<a name="clone"></a>

#### リポジトリの複製 (clone)

書式

`git clone <url>`

説明

リモートリポジトリ（共有リポジトリ）を作業者のパソコンの中に複製します

- url : リモートリポジトリが置いてある場所のURL

~~~bash
$ # リポジトリの複製
$ git clone https://github.com/username/repository
Cloning into 'repository'...
remote: Counting objects: 36, done.
remote: Total 36 (delta 0), reused 0 (delta 0), pack-reused 35
Unpacking objects: 100% (36/36), done.
Checking connectivity... done.
~~~

<a name="config"></a>

#### Git の設定の表示と変更 (config)

書式

`git config [--global] <name> [<value>]`

説明

- --global : ユーザのGitの設定を行う。globalオプションを指定しない場合は、リポジトリのGitの設定を行う。
- name : 値の名前
- value : 設定値

~~~bash
$ # ユーザ名とメアドの設定
$ git config --global user.name "My Name"
$ git config --global user.email "foo@bar.baz"
$ # ユーザ名の確認
$ git config --global user.name
My Name
~~~

`--global` を指定して設定した場合は、~/.gitconfig に設定が書き込まれます。  
上のコマンドを実行すると、.gitconfig ファイルには次のように変更が加えられます。

~~~
[user]
    name = My Name
    email = foo@bar.baz
~~~

<a name="remote"></a>

#### リモートリポジトリを設定する (remote)

書式

`git remote [-v]` : 登録されているリモートリポジトリの一覧を表示

`git remote add <name> <url>` : リモートへの接続方法の追加

`git remote rename <old> <new>` : リモート名を old から new に変更する

`git remote set-url <name> <newurl>` : リモートのURLの変更

~~~bash
$ # リモートリポジトリの登録
$ git remote add origin https://github.com/usr/repository

$ # リモートのURLを変更
$ git remote set-url origin https://github.com/usr/repository2

$ # リモート名とそのURLの確認
$ git remote -v
origin  https://github.com/usr/repository2.git (fetch)
origin  https://github.com/usr/repository2.git (push)
~~~

-----

### 変更の反映

下矢印が変更の取り込み、上矢印が変更の追加を表しています

~~~
 GitHub

          (Remote_Repository)   # リモートリポジトリ
           |      |       ∧
           |      |       |
 ----------|------|-------|----------
 PC        |      |       |
           | fetch|       |push
           |      ∨       |
          (Local_Repository)    # ローカルリポジトリ
           |      |       ∧
       pull|      |       |commit
           |      |       |
           |      |     (Index) # インデックス
           |      |       ∧
           | merge|       |add
           ∨      ∨       |
          (Working_Directory)   # 作業ディレクトリ

~~~

pull は fetch と merge をまとめて行います

- add, commit, push, pull, fetch, merge

単語 | 説明
:-----------------------------------|:------------------------------------
Remote Repository (リモートリポジトリ) | チーム全員で共有するリポジトリ
Local Repository (ローカルリポジトリ) | 作業者のマシン上にあるリポジトリ
Working Directory (作業ディレクトリ) | 現在の作業ディレクトリ
Index (インデックス) | ローカルリポジトリへ反映する変更を一時的にためておく場所

以後、リモートリポジトリをリモート、ローカルリポジトリをローカルと省略して書く場合があります

<a name="add"></a>

#### 変更をインデックスに登録 (add)

書式

`git add <file> [<file>...]`

説明

- file : インデックスに登録するファイル名

~~~bash
$ # ファイルをインデックスに追加
$ git add test.txt

$ # 全てのファイルを追加
$ git add *

$ # フォルダ下にある全てのファイルを追加
$ git add dir/
~~~

<a name="commit"></a>

#### 変更をローカルリポジトリに反映 (commit)

ブランチの様子

~~~
                     commit
A---B---C---D          =>     A---B---C---D---E  
            ∧                                 ∧
          * master                          * master
~~~

書式

`git commit [--amend] [-a] [-m <message>]`

説明

- --amend : 直前のコミットをやり直す
- -a : バージョン管理をしている（追跡をしている）すべてのファイルをコミット
- -m <message> : コミットメッセージを追加する。あとで読み返すときにわかるように、必ず何か書くこと

~~~bash
$ # インデックスにあるファイルをコミット
$ git commit -m 'your message'
[master 41f79d5] your message
 1 file changed, 3 insertion(+)

$ # 追跡している全てのファイルをコミット (addもまとめて行う)
$ git commit -am 'your message'

$ # 直前のコミットのコメントを書き換える
$ git commit --amend -m 'fixed message'

$ # ファイルの登録漏れの修正
$ git add test.txt
$ git commit --amend -m 'your message'
~~~

<a name="push"></a>

#### リモートに変更を送る (push)

ブランチの様子

~~~
remote                                  remote                         
       A---B                                   A---B---C---D                  
           ∧                                               ∧
           origin/master                                   origin/master
                               push
--------------------------      =>      --------------------------------   
local                                   local                           
       A---B---C---D                           A---B---C---D           
                   ∧                                       ∧           
                 * master                                * master      
~~~

書式

`git push [--all] [--delete] [<repository> [<ref>]]`

説明

- --all : 全てのブランチをpushする
- --delete : リモートリポジトリのブランチの削除
- repository : push先のリポジトリ（デフォルトは origin ）
- ref : ブランチ名

~~~bash
$ # リモートのoriginに変更を送る
$ git push origin master

$ # いつもpushするリモートに設定する
$ git push --set-upstream origin master

$ # リモートリポジトリに変更を送る（--set-upstream 設定後）
$ git push

$ # 新規に作成したブランチを送る
$ git push origin new-branch

$ # リモートのブランチを削除
$ git push --delete origin new-branch
$ # もしくは
$ git push origin :new-branch
~~~

<a name="pull"></a>

#### リモートの変更を取得してマージする (pull)

ブランチの様子

~~~
remote                                        remote                           
       A---B---C---D                                 A---B---C---D           
                   ∧                                             ∧           
                   origin/master                                 origin/master   

--------------------------------     pull     --------------------------------   
local                                 =>      local                        
       A---B                                         A---B---C---D          
           ∧                                                     ∧
         * master                                              * master
~~~

書式

`git pull [<repository> [<ref>]]`

説明

fetchとmergeを同時に行う（pull = fetch + merge）

- repository : pull先のリポジトリ（デフォルトは origin ）
- ref : ブランチ名

~~~bash
$ # リモートのoriginの変更をpullする
$ git pull origin master

$ # リモートのoriginをいつもpullするリモートに設定する
$ git pull --set-upstream origin master

$ # リモートの変更を取得してマージ（--set-upstream 設定後）
$ git pull

$ # 指定したブランチ「topic」をpullする
$ git push origin topic

$ # リモートのブランチ「foo」を取得して、ローカルにブランチ「foo-branch」を作成
$ git pull origin foo:foo-branch
~~~

<a name="fetch"></a>

#### リモートの変更を取得する (fetch)

ブランチの様子

~~~
remote                                   remote                            

    A---B---C---D                            A---B---C---D           
                ∧                                        ∧           
                origin/master                            origin/master

-----------------------------   fetch    -----------------------------
local                             =>     local
                                                   C---D < FETCH_HEAD
                                                  /    
    A---B                                    A---B     
        ∧                                        ∧
      * master                                 * master
~~~

書式

`git fetch  [<repository> [<ref>]]`

説明

リモートの変更を取得して、FETCH_HEAD という名前のブランチを作成します。  
merge する場合は FETCH_HEAD を現在のブランチに取り込みます。

- repository : fetch先のリポジトリ（デフォルトは origin ）
- ref : ブランチ名

~~~bash
$ # リモートの変更を取得
$ git fetch
$ git log HEAD..FETCH_HEAD    # 現在のブランチのHEADから、フェッチしたブランチのログを確認
$ git diff HEAD..FETCH_HEAD   # 現在のブランチのHEADから、フェッチしたブランチの差分を確認
$ git merge FETCH_HEAD        # 確認後、現在のブランチにマージする
~~~

<a name="reset"></a>

#### コミットのリセット (reset)

ブランチの様子

~~~
                     reset
A---B---C---D          =>     A---B---C
            ∧                         ∧
          * master                  * master
~~~

書式

`git reset [--mixed | --hard | --soft] <commit>`

説明

- --mixed : インデックスの登録を取り消す。引数がファイル名の場合はこのモードになる
- --hard : 作業ディレクトリもインデックスも破棄して、指定したコミットまで戻す
- --soft : コミットだけを取り消す。作業ディレクトリとインデックスはそのまま
- commit : commit番号（7桁の英数字）または、HEADからの相対参照

~~~bash
$ # ファイルをインデックスから外す
$ git reset test.txt
$ # または
$ git reset --mixed test.txt

$ # 直近から1つのコミットを取り消す
$ git reset HEAD^
$ # または
$ git reset --soft HEAD^

$ # 2つ前のコミットまで、作業を巻き戻す
$ git reset --hard HEAD~2
~~~



-----

### ブランチ操作

概要

Gitは変更の枝分かれの数だけ、ブランチを持っています

~~~
          topic     
          ∨         
      D---G         
     /              
A---B---C---E---F       
                ∧       
              * master  
~~~

この作業ツリーには master と topic の二つのブランチが存在します。  
ブランチ名の前に`*`が付いているのは、現在作業しているブランチを示しています。

#### #HEAD^ と HEAD~n について

上の図の master について、最新のコミット「F」は `HEAD` で参照できます。  
1つ前のコミット「E」は `HEAD~` で参照できます。（または`HEAD^`）  
nつ前のコミットは `HEAD~n` （nは整数）で参照できます。

補足

zsh の extended_glob オブションが有効な場合、  
`HEAD^` とやっても期待通りの結果は得られません。エスケープが必要です

~~~bash
$ git show HEAD^
zsh: no matches found: HEAD^
~~~

これは「ファイル名が HEAD から始まるが、その次が文字の終端ではないファイルと一致する」  
という展開が発生するからです。

~~~bash
$ ls
head        head.txt    head100     tail
$ ls head^
head.txt    head100
~~~

##### HEAD と @

コミットを参照するときに、`@` を使うと `HEAD` に変換されます

`HEAD~2` と `@~2` の参照は同じです

補足

`FETCH_HEAD` を `FETCH_@` と省略するのはダメです

--

<a name="branch"></a>

#### ブランチを操作する (branch)

ブランチの様子 (ブランチ作成の例)

~~~
                                        topic
                    branch              ∨
A---B---C             =>        A---B---C
        ∧                               ∧
      * master                        * master
~~~

書式

`git branch` : 全てのローカルブランチを表示する

`git branch [-m | -d] <branch_name>`

説明

- オプションなし : 新しいブランチの作成
- -m : 現在のブランチ名を変更
- -d: ブランチの削除

`git branch <branch_name> <start_point>`

説明

- branch_name : 新しいブランチの名前
- start_point : 指定したコミットを起点としたブランチを作成する

~~~bash
$ # ブランチの確認
$ git log --oneline --decorate --graph
* e0ef2c4 (HEAD, master) latest
* ef06c5c major fix
* a8e5f07 again, minor fix
* 05bf6c1 minor fix
* 54e47ac first commit

$ # ブランチの作成
$ git branch new-branch

$ # 指定したコミットを起点にブランチを作成
$ git branch set-start-branch HEAD~2

$ # ブランチの確認
$ git log --oneline --decorate --graph
* e0ef2c4 (HEAD, master, new-branch) latest     # new-branch が追加せれた
* ef06c5c major fix
* a8e5f07 (set-start-branch) again, minor fix   # set-start-branch が追加された
* 05bf6c1 minor fix
* 54e47ac first commit

$ # ブランチの一覧を表示
$ git branch
* master
  new-branch
  set-start-branch
~~~

<a name="checkout"></a>

#### 作業ブランチを切り替える (checkout)

ブランチの様子

~~~
          topic                            * topic   
          ∨                                  ∨   
      D---F          checkout            D---F
     /                  =>              /     
A---B---C                          A---B---C
        ∧                                  ∧
      * master                             master
~~~

書式

`git checkout <branch>` : 作業ブランチを指定したブランチに切り替える

`git checkout -b <new_branch> [<startpoint>]`

説明

- -b : 指定したブランチが存在しない場合は、作成する
- start_point : 指定したコミットを起点としたブランチを作成する

~~~bash
$ # ブランチの切り替え
$ git checkout other-branch

$ # ブランチの作成
$ git checkout -b new-branch
~~~

`git checkout -b new-branch` は、ブランチの作成 `git branch new-branch` と  
ブランチの切り替え `git checkout new-branch` をまとめて行ってくれるので、  
ブランチの作成によく使われます。

<a name="merge"></a>

#### 他のブランチの変更内容をマージする (merge)

ブランチの様子

~~~
        * topic                                 * topic   
          ∨                                       ∨   
      D---F             merge             D---F---G
     /                    =>             /       /
A---B---C---E                       A---B---C---E
            ∧                                   ∧
            master                              master
~~~

書式

`git merge [-m <message>] <branch>`

説明

- -m : マージのコミットのメッセージを指定する
- branch : 取り込むブランチ名

~~~bash
$ # master ブランチの変更を、現在のブランチに取り込む
$ git merge master

$ # fetchしてできたブランチ FETCH_HEAD をmergeする
$ git merge FETCH_HEAD
~~~

##### 競合について

例えば、other-branch の test.txt ファイルと master の test.txt ファイルで別々の内容を加えたとします。

~~~
master:test.txt         other-branch:test.txt
-----------------       -----------------------
 item1                   other-list1
 item2                   other-list2
~~~

この状態で、master に other-branch をマージすると競合が発生します。

具体的には、次のように表示されます

~~~bash
$ # mergeをする際に、競合が発生した場合
$ git merge other-branch
Auto-merging test.txt
CONFLICT (content): Merge conflict in test.txt
Automatic merge failed; fix conflicts and then commit the result.

$ # ファイルの状態を確認
$ git status
On branch master
Your branch and 'origin/master' have diverged.
and have 1 and 1 different commit each, respectively.

Unmerged paths:
  (use "git add <file>..." to mark resolution)

  both modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
$ # test.txt の競合箇所がわかるように書き変わっているのを確認
$ cat test.txt
<<<<<<< HEAD
item1
item2
=======
other-list1
other-list2
>>>>>>> other-branch
$
~~~

エディタで競合しているファイルを開いて、編集します。  
今回は、両方の変更を採用したいので、test.txt の中身を次のように書き換えます。

~~~
item1
item2
other-list1
other-list2
~~~

このとき、境界線である `<<<<<<<`, `=======`, `>>>>>>>` は削除します

修正が完了したら、インデックスに追加してコミットします。

~~~ bash
$ git add text.txt
$ git commit
[master bed8323] Merge branch 'other-branch'
$ git push
~~~

<a name="mergetool"></a>

#### 外部ツールを使って競合を解決する (mergetool)

`git mergetool [-t <tool>] [<file>...]`

説明

競合が発生している際に、外部ツールを使って競合を解決します

- -t : 使用する外部ツールを指定する
- file : 競合中のファイルを指定する（省略した場合は、全ての競合中のファイルが選ばれる）

~~~bash
$ git mergetool -t vimdiff
# vimdiff が起動する
~~~

vimで変更を加える時は `i` を押して、編集して、`<Esc>` で書き込みモードから離れます。  
編集の保存は `:w` と入力します。
全てのウィンドウを閉じるには `:qa` と入力します

<a name="rebase"></a>

#### ブランチの起点を変更する (rebase)

ブランチの様子

~~~
            * topic                                         * topic   
              ∨                                               ∨   
      D---F---G            rebase                     D'--F'--G'
     /                       =>                      /
A---B---C---E                           A---B---C---E
            ∧                                       ∧
            master                                  master
~~~

書式

`git rebase <upstream> [<branch>]`

説明

ブランチの起点（分岐元）を変更します

- upstream : ブランチの分岐元のコミットやブランチを指定する
- branch : rebase対象のブランチ名（省略した場合は、現在のブランチ）

~~~bash
$ # 現在のブランチを、masterブランチの最新コミットから分岐したように変更
$ git rebase master
~~~

<a name="cherry-pick"></a>

#### 他のブランチのコミットを取り込む (cherry-pick)

ブランチの様子

~~~
        * topic                                              * topic   
          ∨                                                    ∨   
      D---F                  cherry-pick           D---F---G'--H'
     /                            =>              /    
A---B---C---E---G---H                        A---B---C---E---G---H
                    ∧                                            ∧
                    master                                       master
~~~

書式

`git cherry-pick <commit>`

説明

- commit : 取り込み対象のコミット

~~~
$ # コミット b75ffb1 を現在のブランチに取り込む
$ git cherry-pick b75ffb1
~~~

コミット番号は、`git log --oneline <branch>` などで確認できます



-----

### 確認

<a name="status"></a>

#### ファイルの状態を表示 (status)

`git status [-s]`

説明

未追跡のファイル、修正が加えられたファイル、インデックスに登録されたファイルなどの情報が見られる

- -s (--short) : 短いフォーマットで表示する。ファイルが多い場合に確認しやすい

~~~bash
$ # ファイルの状態を確認
$ git status
On branch master                   # 現在のブランチの状態
Your branch is ahead of 'origin/master' by 3 commits.  
  (use "git push" to publish your local commits)

Changes to be committed:           # インデックスの登録されているファイル
  (use "git reset HEAD <file>..." to unstage)

  new file:   登録済みファイル

Unmerged paths:                    # 競合中のファイル
  (use "git add/rm <file>..." as appropriate to mark resolution)

  both modified:      競合中のファイル

Changes not staged for_commit:     # インデックスに追加されていないファイル
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

  modified:   未登録ファイル

Untracked files:                   # 追跡していないファイル
  (use "git add <file>..." to include in what will be committed)

  Gitのバージョン管理外のファイル

no changes added to commit (use "git add" and/or "git commit -a")
~~~

Untracked files に追跡していないファイルを表示させないようにするには、  
.gitignore に無視するファイルを追加（作成）します。

.gitignore

~~~bash
*.o    # 拡張子が .o で終わるファイルは無視
dir/   # 指定したディレクトリ以下の全てのファイルを無視
!dir/template  # 先頭に ! を加えて、無視していたファイルを無視しないようにする
~~~

`git status -s` での表示形式について、  
1文字目はインデックスの状態、2文字目は作業ディレクトリの状態を表しています。

先頭の大文字英字には、次のような意味があります。

文字 | 意味
-----|---------------
(なし)| 変更なし
M    | 変更 (modify)
A    | 追加 (add)
D    | 削除 (delete)
R    | 名前変更 (rename)
C    | 複製 (clone)
U    | 競合 (unmerged)

以下に具体例を示します

~~~ bash
$ # ファイルの状態をシンプルな表示で確認
$ git status -s
A  newfile.txt                  # インデックスに追加済みの新規ファイル
 M changefile.txt               # 作業ディレクトリ上の新しい変更
M  addfile.txt                  # インデックスに追加済みの変更
MM addchangefile.txt            # インデックスに追加後、作業ディレクトリで新たな修正が加えられたファイル
R  file.txt -> renamedfile.txt  # インデックスに追加済みの変更（ファイル名の変更）
?? untrackedfile.txt            # バージョン管理外のファイル
~~~

<a name="log"></a>

#### 履歴を表示する (log)

`git log [--<options>] [-<n>] [<range>] [<file>]`

説明

- --oneline : コミットメッセージの1行目だけを表示する
- --graph : グラフを表示する。ブランチの分岐やマージを確認するのに便利
- --decorate : HEAD, Tag, リモートブランチのHEADの情報も合わせ表示する
- --stat : コミットの変更内容の統計情報を表示する
- -n : 直近のn件のコミットを表示する（nは整数）
- range : since から until までの log を `since..until` と指定して表示する

~~~bash
$ # コミットログの一覧
$ git log

$ # branch1とbranch2を比較して、branch2にのみ存在するコミットの、1行目のメッセージを表示する
$ git log --oneline master..other-branch

$ # source treeのブランチの出力を真似る
$ git log --oneline --decorate --graph
  # グラフの例
* 52037cb (HEAD, github/master, master) Add TODO
*   7f12aba Merge pull request #15 from committer/master
|\  
| * d255dbc (github/camera-feature) created Foo.cs
| * 95a90ec Add Foo.cs
* | 15740d7 Create diagram
* | a9863b7 Rename new block. 'block' -> 'block(new)'
|/  
*   41963e2 Merge branch 'master' of https://github.com/team/repo

$ # 片方のブランチにしかないコミットを表示
$ # この例では、other-branch にあって、master にはないコミットの一覧
$ git log master..other-branch
~~~

<a name="diff"></a>

#### 差分を表示する (diff)

`git diff [--cached]`

説明

変更の差分を表示します

- --cached : インデックスと特定のコミットの差分を表示する

~~~bash
$ # 作業ディレクトリと最新のコミットとの差分を表示
$ git diff

$ # インデックスと最新のコミットとの差分を表示
$ git diff --cached

$ # 作業ディレクトリと指定のコミットとの差分を表示
$ git diff 41963e2

$ # 2つのコミットの差分を表示
$ git diff 41963e2 7f12aba
$ # または
$ git diff 41963e2..7f12aba

$ # 2つのブランチの差分を表示
$ git diff master..FETCH_HEAD
~~~

<a name="show"></a>

#### コミットを表示する (show)

`git show [--oneline] <commit>`

説明

指定したコミット情報を表示します

- --oneline : コミットメッセージの1行目だけを表示

~~~bash
$ # 最新のコミットの情報を表示
$ git show HEAD

$ # 指定したコミットの情報を表示
$ git show 41963e2

$ # 直近から3件のコミットの情報を表示
$ git show -3
~~~

<a name="reflog"></a>

#### リポジトリの操作履歴の確認 (reflog)

`git reflog`

説明

リポジトリの操作履歴の確認

~~~bash
$ # コミットログを確認
$ git log --oneline
41963e2 third commit
63fc109 second commit
a178120 first commit
$ # 2つ前のコミットまで戻す
$ git reset HEAD~2
$ # 操作履歴の確認
$ git reflog
f287e54 HEAD@{1}: reset: moving to HEAD~2
41963e2 HEAD@{2}: commit: third commit
63fc109 HEAD@{3}: commit: second commit
a178120 HEAD@{4}: commit: first commit
...
$ # 先ほどのresetを取り消す
$ git reset HEAD@{2}
~~~

<a name="help"></a>

#### Gitコマンドのヘルプ (help)

`git help <command>`

説明

gitのコマンドの使い方を確認します

~~~ bash
$ git help checkout
# manが起動する
~~~

-----
