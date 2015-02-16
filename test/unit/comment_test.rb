#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011 Genome Research Ltd.
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    should belong_to :commentable
    should belong_to :user
    should have_many :comments
  end

end
