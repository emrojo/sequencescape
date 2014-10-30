require "test_helper"

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    should belong_to :commentable
    should belong_to :user
    should have_many :comments
  end

end
