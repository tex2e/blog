---
layout:        post
title:         "texlive2019へのアップグレード on Ubuntu"
date:          2019-10-04
tags:          LaTeX
category:      LaTeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
sitemap: false
draft:   true
---

Ubuntuのtexliveを2018から2019にアップグレードしたので、その方法についての備忘録。

tlmgrで新しいパッケージを入れようとしたら例のアップグレードが必要ですとのメッセージが...

```
$ sudo tlmgr install tikzposter                           
tlmgr: Remote repository is newer than local (2018 < 2019)
Cross release updates are only supported with
  update-tlmgr-latest(.sh/.exe) --update
Please see https://tug.org/texlive/upgrade.html for details.
```

というわけで、このページを読みながら、アップグレードしていきます。

[https://tug.org/texlive/upgrade.html](https://tug.org/texlive/upgrade.html)

まず、texliveがインストールされているディレクトリに移動して、2018をコピーして2019を作成します。
そしたら環境変数 PATH を 2019 に変更します。

```
$ cd /usr/local/texlive
$ cp -a 2018 2019
$ export PATH="/usr/local/texlive/2019/bin/x86_64-linux:$PATH" >> .bash_profile
```

次に update-tlmgr-latest.sh をダウンロードして実行します。

```
$ wget http://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh
$ sh update-tlmgr-latest.sh -- --upgrade
Verifying archive integrity... All good.
Uncompressing TeX Live Manager Updater  100%  
./runme.sh: updating in /usr/local/texlive/2018...
./runme.sh: tlmgr version says this is TeX Live 2018,
./runme.sh: and this updater script created: Sat Jul  6 02:28:20 CEST 2019.
./runme.sh: ok, doing full release upgrade  from 2018 to 2019.
./runme.sh: updating /usr/local/texlive/2018/bin/x86_64-linux ...
./runme.sh: /usr/local/bin/tlmgr including objects: master/tlpkg/tlpobj/texlive.infra.tlpobj master/tlpkg/tlpobj/texlive.infra.x86_64-linux.tlpobj
D:Cannot open package log file for appending: /usr/local/texlive/2018/texmf-var/web2c/tlmgr.log
D:Will not log package installation/removal/update for this run
D:tlmgr:main: ::tldownload_server defined: TeXLive::TLDownload=HASH(0x255d420)
D:setup_programs: preferring system versions
D:trying to set up system curl, arg --version
D:program curl found in the path
D:trying to set up system wget, arg --version
D:program wget found in the path
D:trying to set up system lz4, arg --version
D:program lz4 not usable from path
D:(unix) trying to set up lz4, default /usr/local/texlive/2018/tlpkg/installer/lz4/lz4.x86_64-linux, arg --version
D:Using shipped /usr/local/texlive/2018/tlpkg/installer/lz4/lz4.x86_64-linux for lz4 (tested).
D:trying to set up system gzip, arg --version
D:program gzip found in the path
D:trying to set up system xz, arg --version
D:program xz found in the path
DD:dumping $::progs = {
  'compressor' => 'lz4',
  'curl' => 'curl',
  'gzip' => 'gzip',
  'lz4' => '/usr/local/texlive/2018/tlpkg/installer/lz4/lz4.x86_64-linux',
  'tar' => 'tar',
  'wget' => 'wget',
  'working_compressors' => [
    'lz4',
    'gzip',
    'xz'
  ],
  'working_downloaders' => [
    'curl',
    'wget'
  ],
  'xz' => 'xz'
};
./runme.sh: done.
```

最後に tlmgr 自身とパッケージのアップデートをします。

```
$ sudo tlmgr update --self --all
tlmgr: package repository ftp://ftp.u-aizu.ac.jp/pub/tex/CTAN/systems/texlive/tlnet (verified)
tlmgr: saving backups to /usr/local/texlive/2018/tlpkg/backups
[  1/144] auto-remove: powerdot ... done
[  2/144, ??:??/??:??] update: adobemapping [2120k] (45645 -> 51787) ... done
[  3/144, 00:07/12:31] update: amsmath [2513k] (47349 -> 52096) ... done
...
[142/144, 14:53/14:53] update: collection-basic [1k] (45851 -> 51558) ... done
[143/144, 14:53/14:53] update: collection-langjapanese [1k] (47703 -> 52150) ... done
[144/144, 14:54/14:54] update: collection-latexrecommended [1k] (45955 -> 52096) ... done
running mktexlsr ...
done running mktexlsr.
running updmap-sys ...
done running updmap-sys.
regenerating fmtutil.cnf in /usr/local/texlive/2018/texmf-dist
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine tex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine tex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine ptex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine ptex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine pdftex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine pdftex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine euptex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine euptex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine luatex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine luatex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine luajittex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine luajittex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine eptex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine eptex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine uptex ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-error-if-no-format --byengine uptex.
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --byfmt mf ...
done running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --byfmt mf.
tlmgr: package log updated: /usr/local/texlive/2018/texmf-var/web2c/tlmgr.log
```

texlive2019でtexコマンドが正しく使えることを確認したら古い方(2018)を削除しましょう。

以上です。
