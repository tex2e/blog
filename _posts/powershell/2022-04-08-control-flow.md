---
layout:        post
title:         "[PowerShell] 制御フロー (if, switch, for, foreach) の使い方"
date:          2022-04-08
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

PowerShellの制御フローである if, switch, for, foreach, while の書き方について説明します。

### if-elseif-else文
PowerShellのif文は一般的な言語と同じように書くことができます。
条件による分岐を追加するときは elseif を使います。
```ps1
if ($false) {
    "case1"
} elseif ($true) {
    "case2"
} else {
    "case3"
}
```

### switch文
PowerShellのswitch文は、分岐条件に値だけではなく式を使うこともできます。
```ps1
$mailaddress = "test@example.com"
switch ($mailaddress) {
    { $_.Length -le 6 } { "Invalid Length" }
    "admin@example.com" { "Admin" }
    default             { "OK" }
}
```

switch文のオプションで -regex を指定すると、分岐条件の値を正規表現として入力とマッチするかを評価します。
```ps1
$mailaddress = "test@example.com"
switch -regex ($mailaddress) {
    "^[\w\d]+@[\w\d.]+$" { "OK" }
    default              { "NG" }
}
```

switch文のオプションで -wildcard を指定すると、分岐条件の値をワイルドカードとして入力とマッチするか評価します。
```ps1
$mailaddress = "test@example.com"
switch -wildcard ($mailaddress) {
    "*@*"   { "OK" }
    default { "NG" }
}
```

さらに、witch文のオプションの -file で入力ファイルを指定すると、LinuxのAWKコマンドのように、入力ファイルを1行ずつ読み込んで、パターンマッチの条件を満たすかを評価します。
```ps1
PS> Get-Content C:\test\test.txt
BEGIN {
  BEGIN {
    hello
  } END
} END

PS> switch -regex -file C:\test\test.txt {
>>     "^\s*BEGIN ([^\s]+)" { "begin! {0}" -f $matches[1] }
>>     "([^\s]+) END\s*$"   { "end! {0}" -f $matches[1] }
>>     default              { $_ }
>> }
begin! {
begin! {
        hello
end! }
end! }
```

### for文
PowerShellのfor文は一般的な言語と同じように書くことができます。
条件式で使用する比較演算子が -lt などのPowerShell独自のものを使用する点は、書く際に注意が必要です。
```ps1
PS> for ($i = 0; $i -lt 4; $i++) {
>>     "counter=$i"
>> }
counter=0
counter=1
counter=2
counter=3
```

### foreach文
PowerShellのforeach文も一般的な言語と同じように書くことができます。
```ps1
PS> $result = (dir)
PS> foreach ($item in $result) {
>>     "item=$item"
>> }
item=Desktop
item=Documents
item=Downloads
item=Favorites
...
```

### while文
PowerShellのwhile文も一般的な言語と同じように書くことができます。
フロー制御の break と continue も同じです。
```ps1
while ($true) {
    $command = Read-Host "Enter your command"
    if ($command -match "quit") {
        break
    }
}
```

以上です。
