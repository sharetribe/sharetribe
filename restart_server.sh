sudo mongrel_rails cluster::stop -C /var/datat/kassi/releases/manual/config/mongrel_cluster.yml
mongrel_rails cluster::start
sudo /etc/init.d/apache2 restart
