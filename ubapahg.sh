#!/bin/sh
echo "Installing stuff..." &&
sudo apt-get install apache2 mercurial &&
sudo a2enmod cgi &&
# Configuring mercurial
echo "Configuring hg..." &&
echo "[web]
allow_push = *
push_ssl = false
allow_archive = gz, zip, bz2
[trusted]
users = www-data" > /etc/mercurial/hgrc &&
# Configuring repos directory
cd / &&
sudo mkdir mercurial &&
sudo mkdir mercurial/repositories &&
sudo chown -R www-data:www-data /mercurial &&
# Configuring hgweb
cd /mercurial &&
echo "[web]
style = gitweb
[collections]
/mercurial/repositories = /mercurial/repositories" > hgweb.config &&
# Configuring CGI script
echo "Configuring Apache..." &&
sudo cp /usr/share/doc/mercurial/examples/hgweb.cgi /mercurial &&
cd /mercurial &&
sudo chmod a+x hgweb.cgi &&
# Replacing config file in CGI script
sed -i "s/^config.*/config = \"\/mercurial\/hgweb.config\"/" hgweb.cgi &&
# Apache configuration
cd /etc/apache2 &&
sudo mkdir mercurial &&
cd mercurial &&
echo "ScriptAliasMatch ^/mercurial(.*) /mercurial/hgweb.cgi$1
<Directory \"/mercurial/\">
        Options +Indexes +FollowSymLinks +ExecCGI
        AddHandler cgi-script .cgi .py
        AllowOverride All
        Allow from all
        Satisfy Any
</Directory>" > mercurial.conf &&
cd /etc/apache2/sites-available &&
echo "<VirtualHost *:80>

        ServerAdmin mercurial-admin@localhost

        Options +ExecCGI +Indexes +FollowSymLinks
        AddHandler cgi-script .cgi .py

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        Include /etc/apache2/mercurial/mercurial.conf
</VirtualHost>" > hg.conf
# Enabling hg site and reloading Apache
echo "Restarting Apache..." &&
sudo a2ensite hg &&
sudo service apache2 restart &&
sudo service apache2 reload
echo "Done! Your mercurial server is reachable at http://localhost/mercurial"



