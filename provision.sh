#Password for Mysql: vagrant
#User: vagrant


sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant'
sudo apt-get update
sudo apt-get -y install mysql-server-5.5 php-pear php5-mysql apache2 php5
#sudo pecl install xdebug
sudo apt-get install php5-xdebug

##Create www folder and link to var/www
if [ ! -h /var/www ];
then
    mkdir /vagrant/public
    rm -rf /var/www
    ln -s /vagrant/public /var/www
    a2enmod rewrite
    sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
    service apache2 restart
fi

##Set error reporting
#ERROR_REPORTING="E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED"
ERROR_REPORTING="E_ALL"
ERROR_LOG="/var/log/php_errors.log"
#CREATE LOG FILE
sed -i "s/error_reporting = .*/error_reporting = ${ERROR_REPORTING}/" /etc/php5/apache2/php.ini
touch $ERROR_LOG
chown apache:apache $ERROR_LOG
#The ; in the next line is because the line is commented by default on RHEL5
sed -i "s/;error_log = .*/error_log = ${ERROR_LOG}/" /etc/php5/apache2/php.ini


##Add Mysql user
mysql -uroot -pvagrant -e "CREATE USER 'vagrant'@'%' IDENTIFIED BY 'vagrant'; GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo sed -i "s/bind-address.*/#bind-address = 127.0.0.1/" /etc/mysql/my.cnf
sudo service mysql restart

##Install PHPUnit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

##Add xdebug
#sed -i "$ \i xdebug.remote_autostart=on" /etc/php5/apache2/php.ini
sed -i "$ i\ ; xdebug:" /etc/php5/apache2/php.ini
sed -i "$ i\xdebug.remote_connect_back=on" /etc/php5/apache2/php.ini
sed -i "$ i\xdebug.remote_enable=on" /etc/php5/apache2/php.ini

##Restart Apache
sudo service apache2 restart
