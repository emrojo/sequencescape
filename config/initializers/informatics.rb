# Initialisation for the Rails plugin

require "platform"
directory = File.dirname(__FILE__)
ActionController::Base.prepend_view_path File.join(directory, 'views/platform')
