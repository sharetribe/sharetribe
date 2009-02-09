#!/bin/sh
# The last part of the Kassi build script. This is in a separate file so that the newest version from the repository
# is always run. 


rm -rf log
ln -s /var/datat/kassi/shared/log log
rm -rf tmp/pids/
cd tmp
ln -s /var/datat/kassi/shared/pids pids
cd ..
rm -rf public/images/listing_images/
cd public/images/
ln -s /var/datat/kassi/shared/listing_images/ listing_images
cd ..
cd ..

#change production environment to use production COS
sed -i "s/cos\.alpha\.sizl/cos\.sizl/" config/environments/production.rb

 REV=$((`svn info svn+ssh://alpha.sizl.org/svn/kassi | \
 grep "^Last Changed Rev" | \
 perl -pi -e "s/Last Changed Rev: //"`-`svn info svn+ssh://alpha.sizl.org/svn/kassi/tags | \
 grep "^Last Changed Rev" | \
 perl -pi -e "s/Last Changed Rev: //"`))
echo "BETA_VERSION = \"0.6.$REV\"" >> config/environments/production.rb
BUILD_DATE=`svn info svn+ssh://alpha.sizl.org/svn/kassi | \
 grep "^Last Changed Date" | \
 perl -pi -e "s/Last Changed Date: //" | perl -pi -e "s/\+.+$//"`
echo "BUILT_AT = \"$BUILD_DATE\"" >> config/environments/production.rb




rake db:migrate
rake test
rake db:migrate RAILS_ENV=production
script/server -d -e production -p 8000
cd ..
cd ..
sudo /etc/init.d/apache2 restart
