class SetIlluminaPipelinesToOptimumPackingStrategy < ActiveRecord::Migration
  class PlatePurpose < ActiveRecord::Base
    set_table_name('plate_purposes')
    set_inheritance_column(nil)

    scope :illumina_plate_purposes, where(
      :name => (IlluminaB::PlatePurposes::PLATE_PURPOSE_FLOWS + Pulldown::PlatePurposes::PLATE_PURPOSE_FLOWS).flatten)
   scope :cherrypickable_as_target, where( :cherrypickable_target => true )
  end

  def self.up
    ActiveRecord::Base.transaction do
      PlatePurpose.cherrypickable_as_target.illumina_plate_purposes.find_each do |purpose|
        purpose.update_attributes!(:cherrypick_strategy => 'Cherrypick::Strategy::Optimum')
      end
    end
  end

  def self.down
    # Do nothing here
  end
end
