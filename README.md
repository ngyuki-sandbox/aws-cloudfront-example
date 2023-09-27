
```sh
sudo amazon-linux-extras install nginx1
sudo yum install php-fpm

systemctl disable --now httpd
systemctl enable --now nginx
systemctl enable --now php-fpm
```

```sh
sudo tee /etc/nginx/default.d/app.conf <<'EOS'
try_files $uri @app;
location @app {
    fastcgi_pass  127.0.0.1:9000;
    include       fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/html/index.php;
}
location ~ \.(js)$ {
    add_header Cache-Control "public,no-cache,must-revalidate,max-age=10";
}
location ~ \.(css)$ {
    add_header Cache-Control "public,must-revalidate,max-age=10";
}
EOS
sudo systemctl restart nginx

echo '<?php session_start(); echo date("Y-m-d\TH:m:s\n");' | sudo tee /var/www/html/index.php
date +%Y-%m-%dT%H:%M:%S | sudo tee /usr/share/nginx/html/a.js
date +%Y-%m-%dT%H:%M:%S | sudo tee /usr/share/nginx/html/a.css
```
