##########################
# Universal Requirements #
##########################

## Update base Ubuntu

apt update
apt upgrade -y

##########################
# Nginx Installation     #
##########################

##########################
##
## BEFORE STARTING
## Run the following commands on host
## $ pct push <ctid> /etc/pve/local/pve-ssl.pem /root/pve-ssl.pem
## $ pct push <ctid> /etc/pve/local/pve-ssl.key /root/pve-ssl.key
##
##########################

apt install nginx -y

## Unlink default config file
unlink /etc/nginx/sites-enabled/default

## Write Config file: /etc/nginx/sites-available/reverse-proxy.conf
echo "map $host $theme {
    default \"plex\";
}

server {
    listen 80 default;
    server_name tardis.lan 192.168.1.122;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect off;
    proxy_set_header Host $host;

    location /radarr {
        proxy_pass http://radarr.lan:7878;

        set $app radarr;
        include /etc/nginx/theme-park.conf;
    }

    location /sonarr {
        proxy_pass http://sonarr.lan:8989;

        set $app sonarr;
        include /etc/nginx/theme-park.conf;
    }

    location /lidarr {
        proxy_pass http://lidarr.lan:8686;

        set $app lidarr;
        include /etc/nginx/theme-park.conf;
    }

    location /jackett {
        proxy_pass http://jackett.lan:9117;

        set $app jackett;
        include /etc/nginx/theme-park.conf;
    }

    location /deluge {
        proxy_pass http://deluge.lan:8112/;
        proxy_set_header X-Deluge-Base \"/deluge/\";
        include /etc/nginx/conf.d/proxy-control.conf;
        add_header X-Frame-Options SAMEORIGIN;

        set $app deluge;
        include /etc/nginx/theme-park.conf;
    }

    location /tautulli {
        proxy_pass http://tautulli.lan:8181;

        set $app tautulli;
        include /etc/nginx/theme-park.conf;
    }

    location /ombi {
        proxy_pass http://ombi.lan:5000;

        set $app ombi;
        include /etc/nginx/theme-park.conf;
    }

    location / {
        proxy_pass http://heimdall.lan/;
    }

    location /nginx {
        stub_status on;
        access_log off;
    }
}" > /etc/nginx/sites-available/reverse-proxy.conf

echo "    proxy_set_header Accept-Encoding \"\";
    sub_filter
    '</head>'
    '<link rel=\"stylesheet\" type=\"text/css\" href=\"https://gilbn.github.io/theme.park/CSS/themes/$app/$theme.css\">
    </head>';
    sub_filter_once on;" > /etc/nginx/theme-park.conf

echo "proxy_connect_timeout   59s;
proxy_send_timeout      600;
proxy_read_timeout      36000s;  ## Timeout after 10 hours
proxy_buffer_size       64k;
proxy_buffers           16 32k;
proxy_pass_header       Set-Cookie;
proxy_hide_header       Vary;

proxy_busy_buffers_size         64k;
proxy_temp_file_write_size      64k;

proxy_set_header        Accept-Encoding         '';
proxy_ignore_headers    Cache-Control           Expires;
proxy_set_header        Referer                 $http_referer;
proxy_set_header        Host                    $host;
proxy_set_header        Cookie                  $http_cookie;
proxy_set_header        X-Real-IP               $remote_addr;
proxy_set_header        X-Forwarded-Host        $host;
proxy_set_header        X-Forwarded-Server      $host;
proxy_set_header        X-Forwarded-For         $proxy_add_x_forwarded_for;
proxy_set_header        X-Forwarded-Port        '443';
proxy_set_header        X-Forwarded-Ssl         on;
proxy_set_header        X-Forwarded-Proto       https;
proxy_set_header        Authorization           '';

proxy_buffering         off;
proxy_redirect          off;

## Required for Plex WebSockets
proxy_http_version      1.1;
proxy_set_header        Upgrade         $http_upgrade;
proxy_set_header        Connection      \"upgrade\";" > /etc/nginx/conf.d/proxy-control.conf

## Link new config file
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

## Restart linux service
systemctl restart nginx