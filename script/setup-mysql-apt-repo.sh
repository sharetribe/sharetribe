#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

# See https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
# and https://dev.mysql.com/doc/refman/8.0/en/checking-gpg-signature.html
DEB="mysql-apt-config_0.8.36-1_all.deb"

apt-get update --allow-releaseinfo-change && apt-get install -y lsb-release

wget -O "/tmp/$DEB" "http://repo.mysql.com/$DEB"

# The repo config package can configure any supported version of MySQL. We need
# to select 5.7. The package uses debconf, so we need to pass the correct
# selections non-interactively.

debconf-set-selections <<HERE
mysql-apt-config mysql-apt-config/tools-component string mysql-tools
mysql-apt-config mysql-apt-config/repo-codename select bullseye
mysql-apt-config mysql-apt-config/unsupported-platform select abort
mysql-apt-config mysql-apt-config/repo-url string http://repo.mysql.com/apt
mysql-apt-config mysql-apt-config/select-server select mysql-8.0
mysql-apt-config mysql-apt-config/dmr-warning note
mysql-apt-config mysql-apt-config/select-preview select Disabled
mysql-apt-config mysql-apt-config/preview-component string
mysql-apt-config mysql-apt-config/select-tools select Enabled
mysql-apt-config mysql-apt-config/repo-distro select debian
mysql-apt-config mysql-apt-config/select-product select Ok
HERE

cat <<HERE > /etc/apt/preferences.d/mysql
Package: libmysqlclient-dev
Pin: version 8.0*
Pin: origin repo.mysql.com
Pin-Priority: 1001

Package: mysql-common
Pin: version 8.0*
Pin: origin repo.mysql.com
Pin-Priority: 1001

Package: mysql-community-client
Pin: version 8.0*
Pin: origin repo.mysql.com
Pin-Priority: 1001
HERE

dpkg -i "/tmp/$DEB"

apt-get update

# Remove MariaDB packages
apt-get purge -y mariadb-common mysql-common
