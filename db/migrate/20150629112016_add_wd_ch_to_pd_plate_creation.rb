class AddWdChToPdPlateCreation < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      Plate::Creator::PurposeRelationship.create!({
        :plate_creator => Plate::Creator.find_by_name!("Pico Dilution"),
        :plate_purpose => Purpose.find_by_name!("Pico Dilution"),
        :parent_purpose => Purpose.find_by_name!("Cherrypicked Working Dilution")
      })
    end
  end

  def self.down
  end
end
