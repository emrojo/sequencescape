#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012,2013,2015 Genome Research Ltd.
require "test_helper"


class EventFactoryTest < ActiveSupport::TestCase
  context "An EventFactory" do
    setup do
      @user = Factory :user, :login => "south", :email => "south@example.com"
      @bad_user = Factory :user, :login => "south", :email => ""
      @project = Factory :project, :name => "hello world"
      #@project = Factory :project, :name => "hello world", :user => @user
      role = Factory :owner_role, :authorizable => @project
      role.users << @user << @bad_user
      @request_type = Factory :request_type, :key => "library_creation", :name => "Library creation"
      @request = Factory :request, :request_type => @request_type, :user => @user, :project => @project
    end

    context "#new_project" do
      setup do
        admin = Factory :role, :name => "administrator"
        user1 = Factory :user, :login => "abc123"
        user1.roles << admin
        EventFactory.new_project(@project, @user)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context "send 1 email to 1 recipient" do
        should have_sent_email.
          with_subject(/Project/).
          bcc("abc123@example.com").
          with_body(/Project registered/)
        # should have_sent_email.bcc.size == 1
        should_not have_sent_email.bcc("")
      end
    end

    context "#new_sample" do
      setup do
        admin = Factory :role, :name => "administrator"
        user1 = Factory :user, :login => "abc123"
        user1.roles << admin
        @sample = Factory(:sample, :name => "NewSample")
      end

      context "project is blank" do
        setup do
          EventFactory.new_sample(@sample, [], @user)
        end

        should_change("Event.count", :by => 1) { Event.count }

        context "send an email to one recipient" do
          should have_sent_email.
            with_subject(/Sample/).
            bcc("abc123@example.com").
            with_body(/New 'NewSample' registered by south/)
        end
      end

      context "project is not blank" do
        setup do
          EventFactory.new_sample(@sample, @project, @user)
        end

        should_change("Event.count", :by => 2) { Event.count }

        context "send 2 emails each to one recipient" do
          should have_sent_email.
            with_subject(/Sample/).
            bcc("abc123@example.com").
            # && email.bcc.size == 1 \
            with_body(/New 'NewSample' registered by south/)


          should have_sent_email.
            with_subject(/Project/).
            bcc("abc123@example.com").
            # && email.bcc.size == 1 \
            with_body(/New 'NewSample' registered by south: NewSample. This sample was assigned to the 'hello world' project./)

          should_not have_sent_email.bcc("")
        end
      end
    end

    context "#project_approved" do
      setup do
        ::ActionMailer::Base.deliveries = [] # reset the queue
        role = Factory :manager_role, :authorizable => @project
        role.users << @user
        admin = Factory :role, :name => "administrator"
        user1 = Factory :user, :login => "west"
        user1.roles << admin
        EventFactory.project_approved(@project, @user)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context "send email to project manager" do
        should have_sent_email.
          with_subject(/Project approved/).
          bcc("south@example.com").
          with_body(/Project approved/)

        should_not have_sent_email.bcc("")
      end
    end

    context "#project_approved by administrator" do
      setup do
        ::ActionMailer::Base.deliveries = [] # reset the queue
        admin = Factory :role, :name => "administrator"
        @user1 = Factory :user, :login => "west"
        @user1.roles << admin
        @user2 = Factory :user, :login => "north"
        @user2.roles << admin
        role = Factory :manager_role, :authorizable => @project
        role.users << @user
        EventFactory.project_approved(@project, @user2)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context ": send emails to everyone administrators" do
        should have_sent_email.
          with_subject(/Project approved/).
          bcc("west@example.com").
          bcc("north@example.com").
          bcc("south@example.com").
          with_body(/Project approved/)

        should_not have_sent_email.bcc("")
      end

    end

    context "#project_approved but not by administrator" do
      setup do
        ::ActionMailer::Base.deliveries = []
        admin = Factory :role, :name => "administrator"
        @user1 = Factory :user, :login => "west"
        @user1.roles << admin
        follower = Factory :role, :name => "follower"
        @user2 = Factory :user, :login => "north"
        @user2.roles << follower
        role = Factory :manager_role, :authorizable => @project
        role.users << @user
        EventFactory.project_approved(@project, @user2)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context ": send email to project manager" do
        should have_sent_email.
          with_subject(/Project/).
          with_subject(/Project approved/).
          bcc("south@example.com").
          with_body(/Project approved/)

       should_not have_sent_email.bcc("")
      end

      context "send no email to adminstrator nor to approver" do
        should_not have_sent_email.bcc("west@example.com")
        should_not have_sent_email.bcc("north@example.com")
        should_not have_sent_email.bcc("")
      end
    end

    context "#study has samples added" do
      setup do
        ::ActionMailer::Base.deliveries = []
        role = Factory :manager_role, :authorizable => @project
        role.users << @user
        follower = Factory :role, :name => "follower"
        @user1 = Factory :user, :login => "north"
        @user1.roles << follower
        @user2 = Factory :user, :login => "west"
        @user2.roles << follower
        @study = Factory :study, :user => @user2
        @submission = Factory::submission :project => @project, :study => @study, :asset_group_name => 'to prevent asset errors'
        @samples = []
        @samples[0] = Factory :sample, :name => "NewSample-1"
        @samples[1] = Factory :sample, :name => "NewSample-2"
        EventFactory.study_has_samples_registered(@study, @samples, @user1)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context "send email to project manager" do
        should have_sent_email.
          with_subject(/Sample/).
          with_subject(/registered/).
          bcc("south@example.com")
      end

    end

    context "#request update failed" do
      setup do
        ::ActionMailer::Base.deliveries = []
        role = Factory :manager_role, :authorizable => @project
        role.users << @user
        @user1 = Factory :user, :login => "north"
        @request.user = @user1
        follower = Factory :role, :name => "follower"
        @user2 = Factory :user, :login => "west"
        @user2.roles << follower
        @study = Factory :study, :user => @user2
        @submission = Factory::submission(:project => @project, :study => @study, :assets => [Factory(:sample_tube)])
        @request = Factory :request, :study => @study, :project => @project,  :submission => @submission
        @user3 = Factory :user, :login => "east"
        message = "An error has occurred"
        EventFactory.request_update_note_to_manager(@request, @user3, message)
      end

      should_change("Event.count", :by => 1) { Event.count }

      context "send email to project manager" do
        should have_sent_email.
          with_subject(/Request update/).
          with_subject(/failed/).
          bcc("south@example.com")
      end
    end
  end

  def assert_did_not_send_email
# invocation with block tests absence of a specific email
    if block_given?
      emails = ::ActionMailer::Base.deliveries
      matching_emails = emails.select do |email|
        yield email
      end
      assert matching_emails.empty?
    else
# invocation without block lists any mails in the queue for test
# e.g. use as: 'should "list" do  assert_did_not_send_mail; end'
      msg = "Sent #{::ActionMailer::Base.deliveries.size} emails.\n"
      ::ActionMailer::Base.deliveries.each do |email|
        msg << "  '#{email.subject}' sent to #{email.bcc}:\n#{email.body}\n\n"
      end
      assert ::ActionMailer::Base.deliveries.empty?, msg
    end
  end

end
