FROM centos:latest
MAINTAINER NuMedik <sysadmin@numedik.com>


ENV RUBY_MAJOR 2.2 
ENV RUBY_VERSION 2.2.3

RUN yum -y update && yum install -y gcc make openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel bzip2 automake autoconf git-core zlib zlib-devel gcc-c++ patch readline libtool bison curl sqlite-devel mariadb-devel epel-release nodejs

# Build ruby
RUN mkdir -p /usr/src/ruby \
  && curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
  | tar -xjC /usr/src/ruby --strip-components=1 \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
#  && (yum remove -y openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel bzip2 automake autoconf || exit 0) \
  && yum clean -y all \
  && rm -r /usr/src/ruby \
# Do not create documentation on gem install
  && echo -e "install: --no-ri --no-rdoc\nupdate: --no-ri --no-rdoc" >> /usr/local/etc/gemrc

# Install bundler
ENV GEM_HOME /usr/local/bundle 
ENV PATH $GEM_HOME/bin:$PATH 
RUN gem install bundler \
      && bundle config --global path "$GEM_HOME" \
      && bundle config --global bin "$GEM_HOME/bin"

# Do not create .bundle in apps directory 
ENV BUNDLE_APP_CONFIG $GEM_HOME

# Add defaults file for ruby 
#ADD ruby.conf /etc/default/ruby.conf
#ADD profile.d-ruby.sh /etc/profile.d/ruby.sh
#WORKDIR /

