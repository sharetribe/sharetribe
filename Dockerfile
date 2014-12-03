FROM ubuntu:14.04
MAINTAINER Sharetribe Team <team@sharetribe.com>
RUN apt-get -yqq update

# Install RVM, Ruby, and Bundler
RUN apt-get -yqq install curl git libxml2
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.2"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Install deps
RUN apt-get -yqq install build-essential mysql-client libmysqlclient-dev libxslt-dev libxml2-dev mysql-server-5.5 nodejs sphinxsearch imagemagick
RUN /bin/bash -l -c "gem install mysql2 -v 0.2.7"

# Create directory for Sharetribe
RUN /bin/bash -l -c "mkdir -p /opt/sharetribe"
WORKDIR /opt/sharetribe

# Run Bundle install
ADD Gemfile /opt/sharetribe/Gemfile
ADD Gemfile.lock /opt/sharetribe/Gemfile.lock
RUN /bin/bash -l -c "bundle install"

EXPOSE 3000