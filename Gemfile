source 'https://rubygems.org'

gem "rails", '3.2.19'

gem "aasm", "~>2.4.0"
gem "configatron"
gem "rest-client" # curb substitute.
gem "formtastic", "~>2.3"
gem "activerecord-jdbc-adapter", ">= 1.2.6", :platforms => :jruby
gem "jdbc-mysql", :platforms => :jruby
gem "mysql", :platforms => :mri
gem "spreadsheet"
gem "will_paginate"
gem 'net-ldap'
gem 'carrierwave'
gem 'jruby-openssl', :platforms => :jruby
gem 'rdoc'

# Provides legacy form helpers
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'

# Provides eg. error_messages_for previously in rails 2, now deprecated.
gem 'dynamic_form'

gem 'trinidad', :platforms => :jruby

# This was once a plugin, now it's a gem:
gem 'catch_cookie_exception',
  :github => 'mhartl/catch_cookie_exception'

gem 'sanger_barcode', '~>0.2',
  :github => 'sanger/sanger_barcode', :branch => 'ruby-1.9'
# The graph library (1.x only because 2.x uses Rails 3).  This specific respository fixes an issue
# seen in creating asset links during the assign_tags_handler (which blew up in rewire_crossing in the
# gem code).
gem "acts-as-dag", '~>3.0.0'

# Better table alterations
# gem "alter_table",
#   :github => "sanger/alter_table"

# For background processing
# Locked for ruby version
gem "delayed_job_active_record"

gem "ruby_walk",  ">= 0.0.3",
  :github => "sanger/ruby_walk"

gem "irods_reader", '>=0.0.2',
  :github => 'sanger/irods_reader'

# For the API level
gem "uuidtools"
gem "sinatra", "~>1.1.0"
gem "rack-acceptable", :require => 'rack/acceptable'
# gem "json_pure" #gem "yajl-ruby", :require => 'yajl'
gem "json"
gem "cancan"

gem "bunny"
#gem "amqp", "~> 0.9.2"

gem "spoon"
# Spoon lets jruby spawn processes, such as the dbconsole. Part of launchy,
# but we'll need it in production if dbconsole is to work

group :warehouse do
  #the most recent one that actually compiles
  gem "ruby-oci8", "1.0.7", :platforms => :mri
  # No ruby-oci8, (Need to use Oracle JDBC drivers Instead)
  #any newer version requires ruby-oci8 => 2.0.1
  gem "activerecord-oracle_enhanced-adapter" , "1.2.3"

end

group :development do
  gem "flay", :require => false
  gem "flog", :require => false
  gem "roodi", :require => false
  gem "rcov", :require => false, :platforms => :mri
  #gem "rcov_rails" # gem only for Rails 3, plugin for Rails 2.3 :-/
  # ./script/plugin install http://svn.codahale.com/rails_rcov
  gem "bullet", "<=4.5.0", :require => false
  gem "debugger", :platforms => :mri
  gem "ruby-debug", :platforms => :jruby
  gem "utility_belt"
#  gem 'rack-perftools_profiler', '~> 0.1', :require => 'rack/perftools_profiler'
#  gem 'rbtrace', :require => 'rbtrace'
  gem 'pry'
end

group :test do
  # bundler requires these gems while running tests
  gem "factory_girl", '~>1.3.1', :require => false
  gem "launchy", :require => false
  gem "mocha", :require => false # avoids load order problems
  gem "nokogiri", :require => false
  gem "shoulda", "~>3.4.0", :require => false
  gem "timecop", :require => false
  gem "treetop", :require => false
  gem 'parallel_tests', :require => false
  gem 'rgl', :require => false
end

group :cucumber do
  # We only need to bind cucumber-rails here, the rest are its dependencies which means it should be
  # making sensible choices.  Should ...
  # Yeah well, it doesn't.
  gem "rubyzip", "~>0.9"
  gem "capybara", :require => false
  gem 'mime-types', '< 2'
  gem "database_cleaner", :require => false
  gem "cucumber", :require => false
  gem "cucumber-rails", :require => false
  gem "poltergeist"
end

group :deployment do
  gem "psd_logger",
    :github => "sanger/psd_logger"
  gem "gmetric", "~>0.1.3"
  gem "trinidad_daemon_extension", :platforms => :jruby
end

