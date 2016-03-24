#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2015,2016 Genome Research Ltd.

require "test_helper"

# Re-raise errors caught by the controller.
class Requests::CommentsController; def rescue_action(e) raise e end; end

class Requests::CommentsControllerTest < ActionController::TestCase
  context "Requests controller" do
    setup do
      @controller = Requests::CommentsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @user = create :user
      @controller.stubs(:current_user).returns(@user)
    end

    should_require_login

    resource_test('comment', {:actions => ['index'], :ignore_actions => ["new", "edit", "update", "show", 'destroy', 'create'], :formats => ['html'], :parent => "request"})

    context "with an ajax request" do
      setup do
        @rq = create :request

        ['this','is','a','test'].each do |description|
          create :comment, description: description, commentable: @rq
        end
      end

      should 'return a ul of comments' do
        xhr :get, :index, :request_id => @rq.id
        assert_template partial: '_simple_list'
      end

    end
  end
end
