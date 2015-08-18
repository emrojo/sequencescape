#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012 Genome Research Ltd.
require "test_helper"

class Api::SubmissionsControllerTest < ActionController::TestCase

  context "submission" do
    setup do
      @controller = Api::SubmissionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @user = Factory :user
      @controller.stubs(:logged_in?).returns(@user)
      @controller.stubs(:current_user).returns(@user)
    end

    context "#create" do
      setup do
        @submission_count =  Submission.count
        template    = Factory :submission_template
        study       = Factory :study
        project     = Factory :project
        sample_tube = Factory :sample_tube
        workflow    = Factory :submission_workflow, :id => 1 # Submission needs a workflow
        rt          = Factory :request_type, :workflow => workflow
        template.request_types <<  rt

        post :create, :order => { :project_id => project.id, :study_id => study.id, :sample_tubes => [sample_tube.id.to_s], :number_of_lanes => "2", :type => template.key }
      end

      should "change Submission.count by 1" do
        assert_equal 1,  Submission.count  - @submission_count, "Expected Submission.count to change by 1"
      end

      should "output a correct error message" do
        assert_equal "\"Submission created\"", @response.body
      end
    end

  end
end
