class SetCherrypickStrategyForPickablePlates < ActiveRecord::Migration
  class PlatePurpose < ActiveRecord::Base
    set_table_name('plate_purposes')
    set_inheritance_column(nil)
   scope :cherrypick_target, where( :cherrypickable_target => true } )
  end

  def self.up
    ActiveRecord::Base.transaction do
      PlatePurpose.cherrypick_target.find_each do |purpose|
        purpose.update_attributes!(:cherrypick_strategy => 'Cherrypick::Strategy::Default')
      end
    end
  end

  def self.down
    # Do nothing here
  end
end
