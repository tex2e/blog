---
layout:        post
title:         "PowerShellのエスケープシーケンス"
date:          2022-04-04
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellのエスケープシーケンスは、バッククオート <code>`</code> です。
プログラムの行末に書くと行継続します。
\$ などの特殊な意味を持つ記号の前にエスケープシーケンスを書くと、そのままの文字として評価します。
また、バッククオートに続けて特定の英数字を書くと、改行やタブなどの特殊文字として評価します。

#### 行継続
PowerShellは一行ずつ評価して完結していればそこで式の評価を終了します。
行末にバッククオート <code>`</code> を付けることで、式の評価を行をまたいで継続するようになります。
```ps1
PS> "Hello" `
>>    + " world!"
Hello world!
```

#### 特殊文字
特殊文字として評価されるエスケープ文字は以下の通りです。

| エスケープ文字 | 意味 |
|-----|-----|
| <code>`t</code> | タブ文字
| <code>`n</code> | 改行文字
| <code>`r</code> | キャリッジリターン
| <code>`0</code> | null文字 (レコードの区切り文字)
| <code>`a</code> | アラート文字 (ビープ音を発生させる)
| <code>`f</code> | フォームフィード (印刷時のページ区切り文字)
| <code>`v</code> | 垂直タブ

#### 文字列内
文字列の中でダブルクオート「"」やシングルクオート「'」の文字を含めたい場合は、その文字を2回繰り返すことで、そのまま表示されます。
```ps1
PS> "He says ""Hello world""!"
He says "Hello world"!

PS> 'It''s nice to meet you!'
It's nice to meet you!
```

以上です。

### 参考文献
- [文字列 - Windows PowerShell \| ++C++; // 未確認飛行 C](https://ufcpp.net/study/powershell/string.html#format)
- Lee Holmes (著), 菅野 良二 (訳)『[Windows PowerShellクックブック](https://amzn.to/3QwwEsn)』O'REILLY, 2018/6
