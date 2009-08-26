#!/bin/sh
# A crude Kassi build script specific to the alpha.sizl.org machine.
# (original script for cos by Ville)
# Note that you must run this script twice until changes to this file take effect;
# changes to finish.sh take effect immediately.

KASSI_PATH=/var/datat/kassi/releases/manual

#sudo mongrel_rails stop -P $KASSI_PATH/tmp/pids/mongrel.pid
sudo mongrel_rails cluster::stop -C $KASSI_PATH/config/mongrel_cluster.yml
cd /
rm -rf $KASSI_PATH
svn export --force file:///svn/kassi/trunk $KASSI_PATH

cd $KASSI_PATH

mongrel_rails cluster::configure -e production -p 8000 -N 5 -c $KASSI_PATH -a 127.0.0.1
chmod a+x alpha-finish.sh
chgrp -R adm .
chmod -R 2775 . 
chmod o+rx .
chmod -R o+rx public
umask 002

./alpha-finish.sh

