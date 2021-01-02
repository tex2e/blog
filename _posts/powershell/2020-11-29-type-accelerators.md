---
layout:        post
title:         "PowerShellで使える型の一覧"
date:          2020-11-29
category:      PowerShell
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

PowerShellの型アクセラレータ (Type Accelerators) は .NET のクラスや型の別名（エイリアス）として機能します。
例えば、PowerShellで [int] は [System.Int32] の別名です。
これにより、PowerShellでの型の扱いが簡単になります。
PowerShellで使える型（型アクセラレータ）の一覧を表示するには、以下のコマンドを実行します。

```powershell
$TypeAcc = [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$TypeAcc::Get.GetEnumerator()
```

以下はPowerShell 5.1での型一覧の出力結果です。int, string, regexとかは馴染み深いと思います。
あとは datetime, PSCustomObject, ipaddress とかは使う場面があると思います。

```output
Key                          Value
---                          -----
Alias                        System.Management.Automation.AliasAttribute
AllowEmptyCollection         System.Management.Automation.AllowEmptyCollectionAttribute
AllowEmptyString             System.Management.Automation.AllowEmptyStringAttribute
AllowNull                    System.Management.Automation.AllowNullAttribute
ArgumentCompleter            System.Management.Automation.ArgumentCompleterAttribute
array                        System.Array
bool                         System.Boolean
byte                         System.Byte
char                         System.Char
CmdletBinding                System.Management.Automation.CmdletBindingAttribute
datetime                     System.DateTime
decimal                      System.Decimal
double                       System.Double
DscResource                  System.Management.Automation.DscResourceAttribute
float                        System.Single
single                       System.Single
guid                         System.Guid
hashtable                    System.Collections.Hashtable
int                          System.Int32
int32                        System.Int32
int16                        System.Int16
long                         System.Int64
int64                        System.Int64
ciminstance                  Microsoft.Management.Infrastructure.CimInstance
cimclass                     Microsoft.Management.Infrastructure.CimClass
cimtype                      Microsoft.Management.Infrastructure.CimType
cimconverter                 Microsoft.Management.Infrastructure.CimConverter
IPEndpoint                   System.Net.IPEndPoint
NullString                   System.Management.Automation.Language.NullString
OutputType                   System.Management.Automation.OutputTypeAttribute
ObjectSecurity               System.Security.AccessControl.ObjectSecurity
Parameter                    System.Management.Automation.ParameterAttribute
PhysicalAddress              System.Net.NetworkInformation.PhysicalAddress
pscredential                 System.Management.Automation.PSCredential
PSDefaultValue               System.Management.Automation.PSDefaultValueAttribute
pslistmodifier               System.Management.Automation.PSListModifier
psobject                     System.Management.Automation.PSObject
pscustomobject               System.Management.Automation.PSObject
psprimitivedictionary        System.Management.Automation.PSPrimitiveDictionary
ref                          System.Management.Automation.PSReference
PSTypeNameAttribute          System.Management.Automation.PSTypeNameAttribute
regex                        System.Text.RegularExpressions.Regex
DscProperty                  System.Management.Automation.DscPropertyAttribute
sbyte                        System.SByte
string                       System.String
SupportsWildcards            System.Management.Automation.SupportsWildcardsAttribute
switch                       System.Management.Automation.SwitchParameter
cultureinfo                  System.Globalization.CultureInfo
bigint                       System.Numerics.BigInteger
securestring                 System.Security.SecureString
timespan                     System.TimeSpan
uint16                       System.UInt16
uint32                       System.UInt32
uint64                       System.UInt64
uri                          System.Uri
ValidateCount                System.Management.Automation.ValidateCountAttribute
ValidateDrive                System.Management.Automation.ValidateDriveAttribute
ValidateLength               System.Management.Automation.ValidateLengthAttribute
ValidateNotNull              System.Management.Automation.ValidateNotNullAttribute
ValidateNotNullOrEmpty       System.Management.Automation.ValidateNotNullOrEmptyAttribute
ValidatePattern              System.Management.Automation.ValidatePatternAttribute
ValidateRange                System.Management.Automation.ValidateRangeAttribute
ValidateScript               System.Management.Automation.ValidateScriptAttribute
ValidateSet                  System.Management.Automation.ValidateSetAttribute
ValidateTrustedData          System.Management.Automation.ValidateTrustedDataAttribute
ValidateUserDrive            System.Management.Automation.ValidateUserDriveAttribute
version                      System.Version
void                         System.Void
ipaddress                    System.Net.IPAddress
DscLocalConfigurationManager System.Management.Automation.DscLocalConfigurationManagerAttribute
WildcardPattern              System.Management.Automation.WildcardPattern
X509Certificate              System.Security.Cryptography.X509Certificates.X509Certificate
X500DistinguishedName        System.Security.Cryptography.X509Certificates.X500DistinguishedName
xml                          System.Xml.XmlDocument
CimSession                   Microsoft.Management.Infrastructure.CimSession
adsi                         System.DirectoryServices.DirectoryEntry
adsisearcher                 System.DirectoryServices.DirectorySearcher
wmiclass                     System.Management.ManagementClass
wmi                          System.Management.ManagementObject
wmisearcher                  System.Management.ManagementObjectSearcher
mailaddress                  System.Net.Mail.MailAddress
scriptblock                  System.Management.Automation.ScriptBlock
psvariable                   System.Management.Automation.PSVariable
type                         System.Type
psmoduleinfo                 System.Management.Automation.PSModuleInfo
powershell                   System.Management.Automation.PowerShell
runspacefactory              System.Management.Automation.Runspaces.RunspaceFactory
runspace                     System.Management.Automation.Runspaces.Runspace
initialsessionstate          System.Management.Automation.Runspaces.InitialSessionState
psscriptmethod               System.Management.Automation.PSScriptMethod
psscriptproperty             System.Management.Automation.PSScriptProperty
psnoteproperty               System.Management.Automation.PSNoteProperty
psaliasproperty              System.Management.Automation.PSAliasProperty
psvariableproperty           System.Management.Automation.PSVariableProperty
```

### 型アクセラレータの追加

型アクセラレータの取得は Get ですが、追加するための Add メソッドもあります。
例えば、.NETの型である System.IO.Path を別名「path」で型アクセラレータに追加するためには、以下のコマンドを実行します。

```powershell
$TypeAcc = [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$TypeAcc::Add('path', [System.IO.Path])
```

型アクセラレータを追加することで、[System.IO.Path] の代わりに、[path] と書くことができます。
以下は追加した型アクセラレータを使用した例です。

```powershell
[path]::GetExtension('c:\test.txt')
```

以上です。


