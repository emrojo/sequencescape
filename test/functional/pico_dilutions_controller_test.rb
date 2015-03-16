#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011 Genome Research Ltd.
require "test_helper"

class PicoDilutionsControllerTest < ActionController::TestCase

  context "Dilution Plate" do
    setup do
      @controller = PicoDilutionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new

      @pico_assay_plates_purpose = PlatePurpose.find_by_name("Pico Assay Plates")
      @dilution_plates_purpose = PlatePurpose.find_by_name("Dilution Plates")
    end

    context "with assay plates " do
      setup do
        pico_assay_a_plate_purpose = PlatePurpose.find_by_name("Pico Assay A")
        pico_assay_b_plate_purpose = PlatePurpose.find_by_name("Pico Assay B")

        @pico_dilution_plate = Factory :plate, :barcode => "2222"
        @assay_plate_a = Factory :plate, :barcode => "9999", :plate_purpose => pico_assay_a_plate_purpose
        @assay_plate_b = Factory :plate, :barcode => "8888", :plate_purpose => pico_assay_b_plate_purpose
        AssetLink.create_edge!(@pico_dilution_plate,@assay_plate_a)
        AssetLink.create_edge!(@pico_dilution_plate,@assay_plate_b)
      end

      context "#index" do
        setup do
          @request.accept = 'application/json'
        end


        context "no page passed in " do
          setup do
            get :index
          end
          should respond_with :success
          should respond_with_content_type :json
        end
        context "page passed in" do
          setup do
            get :index, :page => 3
          end
          should respond_with :success
          should respond_with_content_type :json
        end
      end
    end
  end

end
