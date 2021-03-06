
require 'test_helper'
require 'samples_controller'

module Admin
  module Roles
    class UsersControllerTest < ActionController::TestCase
      context 'Admin::Roles::UsersControllercontroller' do
        setup do
          @controller = Admin::Roles::UsersController.new
          @request    = ActionController::TestRequest.create(@controller)
        end

        should_require_login(:index, resource: 'user', parent: 'role')

        resource_test(
          'user', parent: 'role',
                  actions: ['index'],
                  ignore_actions: ['show', 'create'],
                  user: -> { FactoryBot.create(:admin) },
                  formats: ['html']
        )
      end
    end
  end
end
