---
layout:        post
title:         "[Windows] Railsをサービス化する方法（Redmineの例）"
date:          2025-05-03
category:      Ruby
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windows ServerでRailsアプリケーションをWindowsサービスに登録して、サーバ再起動後にも自動的にRailsが起動するように設定する方法について説明します。
ここではRailsで動作するアプリケーションとして、Redmineを想定しています。

Windowsサーバ再起動時もRailsアプリケーションが起動するようにするには、以下のページを参考に、rubyスクリプトを作成します。

[HowTo run Redmine as a Windows service (win32-service + taskill approach) - Redmine](https://www.redmine.org/projects/redmine/wiki/HowTo_run_Redmine_as_a_Windows_service_(win32-service_+_taskill_approach))

以下は `D:\redmine` フォルダの直下に `service.rb` を作成する場合のスクリプト例です。

```rb
REDMINE_DIR = 'D:\redmine'
LOG_FILE = "#{REDMINE_DIR}\\log\\service.log"

puts REDMINE_DIR
puts LOG_FILE

begin
  require 'win32/daemon'
  include Win32

  class RedmineService < Daemon

    def service_init
      File.open(LOG_FILE, 'a'){ |f| f.puts "Initializing service #{Time.now}" }

      @server_pid = Process.spawn 'bundle exec rails server -e production', :chdir => REDMINE_DIR, :err => [LOG_FILE, 'a']
    end

    def service_main
      File.open(LOG_FILE, 'a'){ |f| f.puts "Service is running #{Time.now} with pid #{@server_pid}" }
      while running?
        sleep 10
      end
    end

    def service_stop
      File.open(LOG_FILE, 'a'){ |f| f.puts "Stopping server thread #{Time.now}" }
      system "taskkill /PID #{@server_pid} /T /F"
      Process.waitall
      File.open(LOG_FILE, 'a'){ |f| f.puts "Service stopped #{Time.now}" }
      exit!
    end
  end

  RedmineService.mainloop

rescue Exception => e
  File.open(LOG_FILE,'a+'){ |f| f.puts " ***Daemon failure #{Time.now} exception=#{e.inspect}\n#{e.backtrace.join($/)}" }
  raise
end
```

続いて、上記のスクリプトの依存ライブラリである「win32-service」をインストールします。

```bat
gem install win32-service
```

次に、以下のコマンド実行して、Windowsサービスに登録します。
コマンドのbinPath以降に空白が含まれていて気になるかもしれませんが、この空白はコマンド実行時に必須なので注意ください。

```bat
sc delete "Redmine Service"
sc create "Redmine Service" binPath= "C:\Ruby33-x64\bin\rubyw -C D:\redmine\ service.rb"
```

必要に応じて、サービスの設定からスタートアップの種類を「自動（遅延開始）」に変更しておきます。

最後に、サーバ再起動後もRailsアプリケーションが立ち上がってくれば設定完了です。

以上です。


### 参考資料

- [HowTo run Redmine as a Windows service (win32-service + taskill approach) - Redmine](https://www.redmine.org/projects/redmine/wiki/HowTo_run_Redmine_as_a_Windows_service_(win32-service_+_taskill_approach))
