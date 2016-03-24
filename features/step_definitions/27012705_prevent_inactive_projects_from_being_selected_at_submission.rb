#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012,2015 Genome Research Ltd.

Given /^I have an inactive project called "([^"]*)"$/ do |project_name|
  project = FactoryGirl.create :project, :name => project_name
  project.update_attributes(:state => 'pending')
end
