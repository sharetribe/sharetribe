FROM ruby:2.3.1
MAINTAINER Sharetribe Team <team@sharetribe.com>
RUN apt-get -yqq update
RUN apt-get -y install build-essential mysql-client libmysqlclient-dev libxslt-dev libxml2-dev nodejs nodejs-legacy npm imagemagick
# todo: sphinxsearch - package not found
# mysql-server-5.5 - er, that's another image guvnor

RUN gem install mysql2 -v 0.3.14

# Create directory for Sharetribe
RUN mkdir -p /opt/sharetribe
WORKDIR /opt/sharetribe

# Run Bundle install
ADD Gemfile /opt/sharetribe/Gemfile
ADD Gemfile.lock /opt/sharetribe/Gemfile.lock
RUN bundle install

# Run node install
ADD package.json /opt/sharetribe/package.json
RUN npm install

# Install webpack
RUN npm install webpack -g

EXPOSE 3000
