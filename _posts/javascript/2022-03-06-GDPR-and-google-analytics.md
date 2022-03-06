---
layout:        post
title:         "アクセス元の国によってGoogle Analyticsを制限する"
date:          2022-03-06
category:      JavaScript
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

GDPR においてCookieは個人情報です。
Google AnalyticsなどのファーストパーティCookie (サイト運営者が発行しているCookie) は米国に個人情報を移転しているため、GDPRに違反しているという判決が出ています。
ここでは、Google Analytics (gtag.js) の動作を特定の地域に限定するための設定について紹介します。

Google Analytics を analytics.js から gtag.js に移行していない場合は、まず gtag.js に移行してください。
gtag.js では高度な同意機能として、ユーザーの地理的位置に基づいてデフォルト設定を調整することができます。

gtag で同意の設定をするには、consent コマンドを使用します。

- consent(同意) : 同意についての設定をします。引数は default か update のいずれかです。
  - default(標準) : デフォルトで使用する同意パラメータを設定します。
  - update(更新) : ユーザが同意を示した場合に、パラメータを更新するために使用します。

また、consent で対応しているフィールド名は、以下のものがあります。

- ad_storage : 広告に関連付くCookieの読み書き権限。allowed または denied を指定します。
- analytics_storage : アナリティクスCookieの読み書き権限。allowed または denied を指定します。
- region : 地域コード (2桁) の配列を指定します。

そして、同意に関する設定を `gtag('js', new Date());` をする前に行います。
以下の例では、EU域内の国を全てデフォルトで Google が発行する Cookie を拒否 (denied) する設定です。

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-XXXXXXXX-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}

  // EU域内の国で、GoogleがCookieを使用することを拒否する
  gtag('consent', 'default', {
    'analytics_storage': 'denied',
    'ad_storage': 'denied',
    'region': ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'GR', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE']
  });

  gtag('js', new Date());
  gtag('config', 'UA-XXXXXXXX-1');

  function consentGranted() {
    // EU域内の国で、GoogleがCookieを使用することを許可する
    gtag('consent', 'update', {
      'analytics_storage': 'granted',
      'ad_storage': 'granted',
      'region': ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'GR', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE']
    });
  }
</script>
```

画面上にCookie使用の同意を求めるダイアログなどを追加した場合は、同意ボタンクリック時に上記の `consentGranted()` 関数を呼び出して、GoogleがCookieが使用できるように更新します。

以上です。

### 参考文献
- [同意設定を管理する（ウェブ） \| タグ \| Google Developers](https://developers.google.com/tag-platform/devguides/consent)
- [グローバル サイトタグ API リファレンス \| グローバル サイトタグ（gtag.js） \| Google Developers](https://developers.google.com/tag-platform/gtagjs/reference#consent)
- [javascript - Blocking Google Analytics cookies by country - Stack Overflow](https://stackoverflow.com/questions/67999514/blocking-google-analytics-cookies-by-country)
