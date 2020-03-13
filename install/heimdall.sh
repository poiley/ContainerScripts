##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update 
apt upgrade -y

apt install git-core apache2 php libapache2-mod-php sqlite php-mbstring php-xml php-common php-sqlite3 php-zip -y

##########################
# Heimdall Installation  #
##########################
a2enmod rewrite

## Clone Repository into /opt folder
git clone https://github.com/linuxserver/Heimdall.git /opt/Heimdall

## Set up Users and Groups
chown -R www-data:www-data /opt/Heimdall/
chmod -R 755 /opt/Heimdall/

## Reconfigure www files
rm -R /var/www/html
ln -s /opt/Heimdall/public/ /var/www/html

rm /etc/apache2/sites-enabled/000-default.conf

echo "<VirtualHost *:80>
ServerAdmin webmaster@localhost
DocumentRoot /var/www/html/
DirectoryIndex index.php index.html default.php welcome.php
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
<Directory /var/www/html/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride all
    Order allow,deny
    allow from all
</Directory>" > /etc/apache2/sites-enabled/000-default.conf

## Generate Keys
cd /opt/Heimdall
php artisan key:generate

## Chown
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

## Restart Service
systemctl restart apache2