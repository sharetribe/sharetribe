FROM ubuntu:14.04
MAINTAINER Sharetribe Team <team@sharetribe.com>
RUN apt-get -yqq update
RUN apt-get -yqq install curl git libxml2

# install RVM, Ruby, and Bundler
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.2"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

RUN apt-get -yqq install build-essential mysql-client libmysqlclient-dev
RUN apt-get -yqq install libxslt-dev libxml2-dev mysql-server-5.5
RUN apt-get -yqq install nodejs
RUN /bin/bash -l -c "gem install mysql2 -v 0.2.7"

RUN /bin/bash -l -c "mkdir -p /opt/sharetribe"
WORKDIR /opt/sharetribe

ADD Gemfile /opt/sharetribe/Gemfile
ADD Gemfile.lock /opt/sharetribe/Gemfile.lock
RUN /bin/bash -l -c "bundle install"

ADD . /opt/sharetribe

RUN /bin/bash -l -c "cp /opt/sharetribe/config/database.docker.yml /opt/sharetribe/config/database.yml"

RUN apt-get -yqq install sphinxsearch

EXPOSE 3000