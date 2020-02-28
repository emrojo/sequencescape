FROM starefossen/ruby-node
RUN apt-get update -qq && apt-get install -y
RUN apt-get -y install git vim mysql-server
WORKDIR /sequencescape
ADD Gemfile /sequencescape
ADD Gemfile.lock /sequencescape
ADD package.json /sequencescape
ADD yarn.lock /sequencescape
RUN gem update --system
RUN gem install bundler
RUN bundle update -bundler
RUN bundle install
ADD . /sequencescape/
RUN bundle exec rake db:create
RUN bundle exec rake db:setup
RUN bundle exec rake working:setup
RUN bundle exec rails webpacker:install
RUN yarn install
RUN rake jobs:work &
