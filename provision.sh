##
# Settings
##

#Secondary database user info (primary is vagrant/vagrant)
DBUSER="vagrant"
DBPASS="vagrant"
#ERROR_REPORTING="E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED"
ERROR_REPORTING="E_ALL"
#File for error log
ERROR_LOG="/var/log/php_errors.log"
#Same as above, but regular expression friendly
ERROR_LOG_REGEXP="\/var\/log\/php_errors.log"
#Database script file, leave empty if not used
DATABASE_SCRIPT_FILE="archiveversionDatabase.sql"
#Wheter PHP should display errors
DISPLAY_ERRORS="On"

##
# MySQL root user
##
echo "*** Setting database user and password"
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant'

##
# Installation
##

echo "*** Installing Python software used when adding PHP5 repository"
##Installing tool for adding repository
sudo apt-get update -qq
sudo apt-get install python-software-properties -y -qq
echo "*** Adding PHP5 repository"
##PHP 5.5 repository for Ubuntu Precise
sudo add-apt-repository -y ppa:ondrej/php5
##Updating package list
sudo apt-get update -qq
echo "*** Installing server software"
##Installing MySQL, Apache2 and PHP
sudo apt-get -y -qq install apache2 mysql-server-5.5 php-pear php5-mysql php5
echo "*** Installing XDebug"
#sudo pecl install xdebug
sudo apt-get install php5-xdebug -qq

##
# Apache default www folder
##

##Create www folder and link to var/www
if [ ! -h /var/www ];
then
    #sudo mkdir /vagrant/public -m 0777
    #sudo chown -R /vagrant/public
    echo "*** Setting Apache directories and settings"
    sudo rm -rf /var/www
    sudo ln -s /vagrant /var/www
    sudo a2enmod rewrite
    #sudo sed -i "/(?<!#)\tAllowOverride None/c AllowOverride All" /etc/apache2/apache2.conf
    sudo sed -i -e "166s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf
    #Changing default www directory to /var/www
    sudo sed -i "s/\/var\/www\/html/\/var\/www/" /etc/apache2/sites-enabled/000-default.conf
    #sudo service apache2 restart
fi

##
# PHP error reporting and logs
##

##Set error reporting and log files
echo "*** Setting error reporting and log directory"
sudo sed -i "s/error_reporting = .*/error_reporting = ${ERROR_REPORTING}/" /etc/php5/apache2/php.ini
sudo touch $ERROR_LOG
sudo chown vagrant:vagrant $ERROR_LOG
#Display errors
echo "*** Setting diplay_errors settings"
sudo sed -i "s/display_errors = .*/display_errors = ${DISPLAY_ERRORS}/" /etc/php5/apache2/php.ini
#The ; in the next line is because the line is commented by default on RHEL5
echo "*** Setting error_log file"
sudo sed -i "s/;error_log = .*/error_log = ${ERROR_LOG_REGEXP}/" /etc/php5/apache2/php.ini

##
# MySQL
##

##Add Mysql user, if any
if [ ! -z ${DBUSER} ];
then
    echo "*** Adding MySQL user"
    mysql -uroot -pvagrant -e "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASS'; GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
fi
#Opens up MySQL for outside connections
sudo sed -i "s/bind-address.*/#bind-address = 127.0.0.1/" /etc/mysql/my.cnf
#lower case table names setting
sudo sed -i "$ i\  lower_case_table_names   = 1" /etc/mysql/my.cnf
#Restart
sudo service mysql restart

#Running database script, if given
if [ ! -z ${DATABASE_SCRIPT_FILE} ];
then
    echo "*** Running database import script"
    mysql -h localhost -u $DBUSER -p$DBPASS < /vagrant/${DATABASE_SCRIPT_FILE}
fi

##
# PHPUnit
##

##Install PHPUnit
echo "*** Installing PHPUnit"
wget -q https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

##Install PHP intl
echo "*** Installing PHP intl"
sudo apt-get install php5-intl -y -qq

##Install curl
echo "*** Installing curl"
sudo apt-get install curl -y -qq

##Install composer
echo "*** Installing composer"
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin

##
# XDebug
##

##Add xdebug
echo "*** Adding xdebug configuration"
#sed -i "$ \i xdebug.remote_autostart=on" /etc/php5/apache2/php.ini
sudo sed -i "$ i\ ; xdebug:" /etc/php5/apache2/php.ini
sudo sed -i "$ i\xdebug.remote_connect_back=on" /etc/php5/apache2/php.ini
sudo sed -i "$ i\xdebug.remote_enable=on" /etc/php5/apache2/php.ini

##
# MySQLND
##

echo "*** Installing MySQLND"
sudo apt-get install php5-mysqlnd -y -qq

##
# PHPMyAdmin
##

##Install PHPMyAdmin
#sudo apt-get install phpmyadmin -y
#sed -i "$ i\Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf

##
# Ready to go
##

##Restart Apache
sudo service apache2 restart
