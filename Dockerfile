FROM ruby:2.6.6

WORKDIR /code
ADD . /code/

RUN gem install bundler

RUN bundle install
RUN bundle exec rails webpacker:install

CMD ["bundle", "exec", "rails", "server", "-p", "8000", "-b", "0.0.0.0"]