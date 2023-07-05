FROM ruby:3.2.2-bullseye

MAINTAINER Sharetribe Team <team@sharetribe.com>

ENV REFRESHED_AT 2023-02-01

RUN apt-get update && apt-get dist-upgrade -y

# Prevent GPG from trying to bind on IPv6 address even if there are none
RUN mkdir ~/.gnupg \
  && chmod 600 ~/.gnupg \
  && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

#
# Node (based on official docker node image)
#

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
  ; do \
    gpg --batch --keyserver hkp://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 18.16.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

  # Add helper for decrypting secure environment variables
RUN curl -sfSL \
  -o /usr/sbin/secure-environment \
  "https://github.com/convox/secure-environment/releases/download/v0.0.1/secure-environment" \
  && echo "4e4c1ed98f1ff4518c8448814c74d6d05ba873879e16817cd6a02ee5013334ea */usr/sbin/secure-environment" \
  | sha256sum -c - \
  && chmod 755 /usr/sbin/secure-environment

#
# Sharetribe
#

# Install:
# - nginx - used to serve maintenance mode page
# - MySQL 5.7 repo and client libs
COPY script/setup-mysql-apt-repo.sh /root/
RUN apt-get install -y nginx \
  && /root/setup-mysql-apt-repo.sh \
  && apt-get install -y libmysqlclient-dev

# Install latest bundler
ENV BUNDLE_BIN=
# Get new ruby gems and bundler, resolves issue with installation of mini_racer and libv8-node
RUN gem update --system 3.4.6

# Run as non-privileged user
RUN useradd -m -s /bin/bash app \
	&& mkdir /opt/app /opt/app/client /opt/app/log /opt/app/tmp && chown -R app:app /opt/app

WORKDIR /opt/app

COPY Gemfile Gemfile.lock /opt/app/

ENV RAILS_ENV production

USER app

RUN bundle config set --local deployment true && \
    bundle config set --local without test,development && \
    bundle install

COPY package.json package-lock.json /opt/app/
COPY client/package.json client/package-lock.json /opt/app/client/

ENV NODE_ENV production
ENV NPM_CONFIG_LOGLEVEL error
ENV NPM_CONFIG_PRODUCTION true

RUN npm ci && cd client && npm ci

COPY . /opt/app

EXPOSE 3000

CMD ["script/startup.sh"]
ENTRYPOINT ["script/entrypoint.sh"]

#
# Assets
#

# Fix ownership of directories that need to be writable
USER root
RUN mkdir -p \
          app/assets/webpack \
          public/assets \
          public/webpack \
    && chown -R app:app \
       app/assets/javascripts \
       app/assets/webpack \
       client/app/ \
       public/assets \
       public/webpack
USER app

# If assets.tar.gz file exists in project root
# assets will be extracted from there.
# Otherwise, assets will be compiled with `rake assets:precompile`.
# Useful for caching assets between builds.
RUN script/prepare-assets.sh
