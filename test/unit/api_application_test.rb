require "test_helper"

class ApiApplicationTest < ActiveSupport::TestCase
  context "#create" do

    should_validate_presence_of :name, :contact, :key, :privilege

    setup do
      @app = ApiApplication.create(:name=>'test')
    end

    should "automatically generate a key if no present" do
      assert @app.key.present?
      assert @app.key.length > 20
    end


  end

end
