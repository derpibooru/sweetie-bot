FROM ruby:3.4.7-alpine3.22

COPY . /opt/sweetie-bot

WORKDIR /opt/sweetie-bot

RUN apk add --no-cache build-base git sqlite-dev \
    && gem install bundler \
    && bundle install

CMD ["/opt/sweetie-bot/bin/sweetie-bot"]
