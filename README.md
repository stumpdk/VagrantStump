Ultimate Vagrant Box.
Included:
Ubuntu (12.04)
Apache (2.4)
PHP5 (5.5)
Mysql (5.5)

PHPUnit
Xdebug

All set up and ready for outside connections (Mysql and Xdebug). Which is of cause NOT safe.

Default database and SSH user: vagrant/vagrant

MySQL root password: vagrant

In the provision.sh, the follow options are available:
    DBUSER and DBPASS: Settings for a new user (other than vagrant/vagrant)
    ERROR_REPORTING: Default PHP error reporting
    ERROR_LOG: Placement of PHP error log
    DATABASE_SCRIPT_FILE: If given, the database will run this script after installation
    DISPLAY_ERRORS: Whether or not PHP should display errors


When using XDEBUG, path mapping is necessary in NetBeans:
"/vagrant/" : "D:/YOURPROJECT/webroot"

To do when setting up a new server:
    * Change the share folder to the wanted one (default is "./"). To change it, alter line 43 in the vagrant file.
    * Install PHPMyAdmin if needed. This is done with the following commands:
        sudo apt-get install phpmyadmin -y
        sudo sed -i "$ i\Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf
