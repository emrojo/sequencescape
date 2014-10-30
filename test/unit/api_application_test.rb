require "test_helper"

class ApiApplicationTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :contact
  should validate_presence_of :key
  should validate_presence_of :privilege

  context "#create" do

    setup do
      @app = ApiApplication.create(:name=>'test')
    end

    should "automatically generate a key if no present" do
      assert @app.key.present?
      assert @app.key.length > 20
    end


  end

end
