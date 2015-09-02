require 'capybara/poltergeist'
Capybara.save_and_open_page_path = 'tmp/capybara'
Capybara.javascript_driver = :poltergeist
