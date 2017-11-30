# CJK Workshop Website

The website for CJK Workshop held by Auto-ID Labs. in Asia.

---

## Environment

- ruby: 2.4.1
- bower: 1.8.2
- imagemagick: 6.7.8.9
- nginx: 1.10.2
- expected_structure: Sinatra+Unicorn+Nginx on CentOS 7.4


## Prerequisite
### ruby

1. Install required package

    ```
    $ yum install -y git gcc gcc-c++ openssl-devel readline-devel bzip2
    ```

2. Download rbenv

    ```
    $ cd /usr/local
    $ git clone git://github.com/rbenv/rbenv.git rbenv
    $ git clone git://github.com/rbenv/ruby-build.git rbenv/plugins/ruby-build
    ```

3. Path setting

    ```
    # /etc/profile.d/rbenv.sh
    export RBENV_ROOT="/usr/local/rbenv"
    export PATH="${RBENV_ROOT}/bin:${PATH}"
    eval "$(rbenv init --no-rehash -)"
    ```

4. Install ruby 2.4.1

    ```
    $ rbenv install 2.4.1
    ```

5. Switch ruby version

    ```
    $ rbenv global 2.4.1
    ```

6. Install bundler

    ```
    $ gem install bundler
    ```

### bower

1. Install nodejs

    ```
    $ yum install -y nodejs
    ```

2. Install bower

    ```
    $ npm install -g bower
    ```

### let's encrypt

1. Install letsencrypt

    ```
    $ yum install -y certbot
    ```

2. Get SSL certificate

    ```
    $ systemctl start nginx  # for initial confirmation
    $ certbot certonly --webroot -w /usr/share/nginx/html/ -d cjk.autoidlab.jp
    ```

3. Cron setting

    ```
    # /var/spool/cron/root
    5 0 15 * * /usr/bin/certbot renew --force-renewal
    ```

### ImageMagick

1. Install ImageMagick
Please make sure the version is less than 7.0

    ```
    $ yum install -y ImageMagick ImageMagick-devel
    ```

### Sqlite3

1. Install ImageMagick

    ```
    $ yum install -y sqlite-devel
    ```


## Sinatra & Unicorn

1. Download repository under '/opt' and execute 'cd /opt/cjk_web'
2. Install gem packages

    ```
    $ bundle install --path vendor/bundle
    ```

3. Install frontend packages

    ```
    $ bower install  # Installed under public/vendow
    ```

4. Edit rackup, unicorn and sinatra setting
Please match RACK_ENV between 'config.ru' and 'app_config.rb'

    ```
    $ vim config/config.ru  # edit RACK_ENV
    $ vim config/app_config.rb   # edit RACK_ENV
    $ vim config/unicorn.rb
    ```

5. Edit db/seeds.rb & create database

    ```
    $ vim db/seeds.rb  # edit as you like
    $ be rake db:setup  # :development
    or
    $ be rake db:setup DISABLE_DATABASE_ENVIRONMENT_CHECK=1  # :production
    ```

6. Create directories for log, files and photographs

    ```
    $ mkdir ./log
    $ mkdir ./tmp
    $ mkdir public/files
    $ mkdir public/photographs
    $ mkdir public/photographs/original
    $ mkdir public/photographs/thumbnail
    ```

7. Run application

    ```
    $ bundle exec unicorn -c config/unicorn.rb -D config/config.ru
    ```


## Nginx

1. Install nginx

    ```
    $ yum install -y nginx
    ```

2. Nginx config

    ```
    # /etc/nginx/conf.d/unicorn_cjkweb.conf

    upstream unicorn_cjkweb {
      server unix:/opt/cjk_web/tmp/unicorn.sock;
    }

    server {
      listen       80;
      server_name  cjk.autoidlab.jp;
      root /usr/share/nginx/html;

      location / {
        return 301 https://$server_name;
      }

      location /.well-known {
         # For letsencrypt
         # Certbot create .well-known directory under DocumentRoot(/usr/share/nginx/html)
       }
    }

    server {
      listen       443 ssl;
      server_name  cjk.autoidlab.jp;

      proxy_set_header X-Forwarded-Host $http_host;
      proxy_set_header X-Forwarded-Server $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-Proto https;
      proxy_redirect off;

      ssl_certificate      /etc/letsencrypt/live/cjk.autoidlab.jp/fullchain.pem;
      ssl_certificate_key  /etc/letsencrypt/live/cjk.autoidlab.jp/privkey.pem;

      error_page 403 404 /404.html;
      location = /404.html {
        root /usr/share/nginx/html;
      }

      error_page   500 502 503 504  /50x.html;
      location = /50x.html {
        root /usr/share/nginx/html;
      }

      # For static files
      location ~^/(css|js|files|images|photographs|vendor)/ {
        add_header Cache-Control "public";
        root   /opt/cjk_web/public;
        expires 7d;
      }

      location / {
        proxy_pass http://unicorn_cjkweb;
        proxy_intercept_errors on;  # Use nginx error page when app server return error
      }
    }
    ```

3. Start nginx

    ```
    $ systemctl enable nginx
    $ systemctl start nginx
    ```


## Tool
Scripts in ./tools directory only can be executed at app root directory because db path used in 'Activerecord::Base.configuration' is absolute path from app root dir.

- secret_login_url_generator.rb
This generate secret login url with user's name and email.

    ```
    $ bundle exec ruby ./tools/secret_login_url_generator.rb
    ```

- voting_result.rb
You can check voting result.

    ```
    $ bundle exec ruby ./tools/voting_result.rb
    ```

- email_secret_login.sh
Email secret login to attendees.
Install 'mail' command and edit 'MY_EMAIL' before executing this scripts.

    ```
    $ bundle exec ruby ./tools/secret_login_url_generator.rb | ./tools/email_secret_login.sh
    ```


## Note
- Reconstruct schema.rb

    ```
    $ be rake db:migrate:reset  # :development
    $ be rake db:migrate:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1  # :production
    ```

- Backup
Target files of backup are below:

    - db/*.sqlite3
    - public/files/
    - public/photographs/

You can use
```
$ rsync -av ./db/*sqlite3 ./public/files ./public/photographs [ssh_user]@[remote_host]:[backup_dir]
```
