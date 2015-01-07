#Settings
#ERROR_REPORTING="E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED"
ERROR_REPORTING="E_ALL"
ERROR_LOG="/var/log/php_errors.log"
DISPLAY_ERRORS="On"
dbuser="vagrant"
dbpass="vagrant"
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
    #sudo mkdir /vagrant/public -m 0777
    #sudo chown -R /vagrant/public
    sudo rm -rf /var/www
    sudo ln -s /vagrant /var/www
    sudo a2enmod rewrite
    sudo sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
    sudo service apache2 restart
fi

##Set error reporting and log files
sed -i "s/error_reporting = .*/error_reporting = ${ERROR_REPORTING}/" /etc/php5/apache2/php.ini
touch $ERROR_LOG
chown apache:apache $ERROR_LOG
#Display errors
sed -i "s/display_errors = .*/display_errors = ${DISPLAY_ERRORS}/" /etc/php5/apache2/php.ini
#The ; in the next line is because the line is commented by default on RHEL5
sed -i "s/;error_log = .*/error_log = ${ERROR_LOG}/" /etc/php5/apache2/php.ini


##Add Mysql user
mysql -uroot -pvagrant -e "CREATE USER '$dbuser'@'%' IDENTIFIED BY '$dbpass'; GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo sed -i "s/bind-address.*/#bind-address = 127.0.0.1/" /etc/mysql/my.cnf
sudo sed -i "$ i\  lower_case_table_names   = 1" /etc/mysql/my.cnf
sudo service mysql restart

##Install PHPUnit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

##Add xdebug
#sed -i "$ \i xdebug.remote_autostart=on" /etc/php5/apache2/php.ini
sudo sed -i "$ i\ ; xdebug:" /etc/php5/apache2/php.ini
sudo sed -i "$ i\xdebug.remote_connect_back=on" /etc/php5/apache2/php.ini
sudo sed -i "$ i\xdebug.remote_enable=on" /etc/php5/apache2/php.ini

##Install PHPMyAdmin
#sudo apt-get install phpmyadmin -y
#sed -i "$ i\Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf

##Restart Apache
sudo service apache2 restart
