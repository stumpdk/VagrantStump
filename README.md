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

When using XDEBUG, path mapping is necessary in NetBeans:
"/vagrant/" : "D:/YOURPROJECT/webroot"

WHEN SET UP, THIS IS WHAT HAVE TO BE DONE:

    * Change the share folder to the wanted one (default is "./"). To change it, alter line 43 in the vagrant file.
    * Install PHPMyAdmin if wanted. This is done with the following commands:
        sudo apt-get install phpmyadmin -y
        sudo sed -i "$ i\Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf
    * Create a database user if vagrant/vagrant isn't good enough
    * Import database(s), if needed
