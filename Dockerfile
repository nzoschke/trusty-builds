# nginx + ruby slug

FROM fabiokung/cedar
MAINTAINER Noah Zoschke <noah@heroku.com>

RUN mkdir -p /app/usr/local /app/usr/src

# Build nginx
WORKDIR /app/usr/src
ADD http://nginx.org/download/nginx-1.5.13.tar.gz /app/usr/src/
RUN tar xfvz nginx-1.5.13.tar.gz
RUN cd nginx-1.5.13 && ./configure --prefix=/app/usr --without-http_rewrite_module 
RUN cd nginx-1.5.13 && make && make install

# Build ruby
ADD http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz /app/usr/src/
ADD https://github.com/atgreen/libffi/archive/v3.0.13.tar.gz /app/usr/src/
ADD http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz /app/usr/src/
RUN tar xfvz ruby-2.1.1.tar.gz
RUN cd ruby-2.1.1 && ./configure --prefix=/app/usr --disable-install-doc
RUN cd ruby-2.1.1 && make && make install

# Clean up src
RUN rm -rf /app/usr/src

# Activate + test nginx + ruby + bundler
WORKDIR /app
ENV PATH /app/usr/bin:/app/usr/sbin:$PATH
RUN gem install bundler --no-rdoc --no-ri
RUN ruby -v ; gem -v ; bundle -v ; nginx -v

# Bundle gems
ADD /Gemfile /app/
RUN bundle install

# Add + configure service
ADD / /app/
ENV PORT 5000
CMD bin/web
