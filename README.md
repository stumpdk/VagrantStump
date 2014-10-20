Ultimate Vagrant Box.
Included:
Ubuntu
Apache
PHP5
Mysql

PHPUnit
Xdebug

All set up and ready for outside connections (Mysql and Xdebug). Which is of cause NOT safe.
Database user:
vagrant/vagrant

When using XDEBUG:
Path mapping is necessary:
"/vagrant/" : "D:/YOURPROJECT/webroot"

If PHPMyAdmin is needed:
sudo apt-get install phpmyadmin -y
sed -i "$ i\Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf
