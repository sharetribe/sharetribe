#!/bin/sh
# A crude Kassi build script specific to the alpha.sizl.org machine.
# (original script for cos by Ville)
# Note that you must run this script twice until changes to this file take effect;
# changes to finish.sh take effect immediately.

KASSI_PATH=/var/datat/kassi/releases/manual

sudo mongrel_rails stop -P $KASSI_PATH/tmp/pids/mongrel.pid
cd /
rm -rf $KASSI_PATH
svn export --force file:///svn/kassi/trunk $KASSI_PATH
cd $KASSI_PATH
chmod a+x alpha-finish.sh
chgrp -R adm .
chmod -R 2770 . 
umask 007
./alpha-finish.sh