#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
class ClearOutDuplicateAssetLocations < ActiveRecord::Migration
  class LocationAssociation < ActiveRecord::Base
    set_table_name('location_associations')
   scope :for_asset, lambda { |x| { :conditions => { :locatable_id => details['locatable_id'] } } }

    def self.duplicated(&block)
      connection.select_all("SELECT locatable_id, COUNT(*) AS total FROM location_associations GROUP BY locatable_id HAVING total > 1").each do |details|
        yield(LocationAssociation.for_asset(details['locatable_id']).all)
      end
    end
  end

  def self.up
    ActiveRecord::Base.transaction do
      LocationAssociation.duplicated do |locations|
        locations.pop             # Remove what is, in theory, the last location
        locations.map(&:destroy)  # Destroy all of the others
      end
    end
  end

  def self.down
    # Nothing to do here
  end
end
