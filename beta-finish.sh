#!/bin/sh
# The last part of the Kassi build script. This is in a separate file so that the newest version from the repository
# is always run. 

KASSI_PATH=/var/datat/kassi/releases/manual

rm -rf log
ln -s /var/datat/kassi/shared/log log
ln -s /var/datat/kassi/shared/ferret_index index
rm -rf tmp/pids/
rm -rf tmp/performance/
cd tmp
ln -s /var/datat/kassi/shared/pids pids
ln -s /var/datat/kassi/shared/performance performance
cd ..
rm -rf public/images/listing_images/
cd public/images/
ln -s /var/datat/kassi/shared/listing_images/ listing_images
cd ..
cd ..
cd config
ln -s /var/datat/kassi/shared/system/database.yml database.yml
ln -s /var/datat/kassi/shared/system/config.yml config.yml
ln -s /var/datat/kassi/shared/system/session_secret session_secret
ln -s /var/datat/kassi/shared/system/gmaps_api_key.yml gmaps_api_key.yml
cd ..

#change production environment to use production COS
sed -i "s/cos\.alpha\.sizl/cos\.sizl/" config/environments/production.rb
# Actually the production Ressi is at alpha so change that line back... :D
sed -i "s/RESSI_URL = \"http:\/\/cos\.sizl\.org\/ressi\"/RESSI_URL = \"http:\/\/cos\.alpha\.sizl\.org\/ressi\"/" config/environments/production.rb
sed -i "s/kassi\.alpha\.sizl/kassi\.sizl/" config/environments/production.rb
sed -i "s/PRODUCTION_SERVER = \"alpha\"/PRODUCTION_SERVER = \"beta\"/" config/environments/production.rb
sed -i "s/LOG_TO_RESSI = false/LOG_TO_RESSI = true/" config/environments/production.rb

 REV=$((`svn info svn+ssh://alpha.sizl.org/svn/kassi | \
 grep "^Last Changed Rev" | \
 perl -pi -e "s/Last Changed Rev: //"`-`svn info svn+ssh://alpha.sizl.org/svn/kassi/tags | \
 grep "^Last Changed Rev" | \
 perl -pi -e "s/Last Changed Rev: //"`))
 
 #ensure new line at the end of file
echo "" >> config/environments/production.rb
 
echo "BETA_VERSION = \"1.0.$REV\"" >> config/environments/production.rb
BUILD_DATE=`svn info svn+ssh://alpha.sizl.org/svn/kassi | \
 grep "^Last Changed Date" | \
 perl -pi -e "s/Last Changed Date: //" | perl -pi -e "s/\+.+$//"`
echo "BUILT_AT = \"$BUILD_DATE\"" >> config/environments/production.rb


# Install required gems if needed (currently not allowed to sudo this)
sudo rake gems:install

rake db:migrate
# no tests on beta to make the downtime shorter
#rake test
rake db:migrate RAILS_ENV=production

# restart starling and workling before starting the server
starling -d -P tmp/pids/starling.pid -q log/
script/workling_client stop
RAILS_ENV=production ./script/workling_client start

#script/server -d -e production -p 8000
mongrel_rails cluster::configure -e production -p 8000 -N 5 -c $KASSI_PATH -a 127.0.0.1
mongrel_rails cluster::start
cd ..
cd ..
sudo /etc/init.d/apache2 restart