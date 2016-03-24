#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015 Genome Research Ltd.

class AddEventFluidigmToCorrespondingPlates < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      # We mark the fluidigm processed plates with the new event
      fluidigm_request_id = RequestType.find_by_key!('pick_to_fluidigm').id
      selection = 'DISTINCT assets.*, plate_metadata.fluidigm_barcode AS fluidigm_barcode'
      joins = [

            'INNER JOIN plate_metadata ON plate_metadata.plate_id = assets.id AND plate_metadata.fluidigm_barcode IS NOT NULL', # The fluidigm metadata
            'INNER JOIN container_associations AS fluidigm_plate_association ON fluidigm_plate_association.container_id = assets.id', # The fluidigm wells
            "INNER JOIN requests ON requests.target_asset_id = fluidigm_plate_association.content_id AND state = \'passed\' AND requests.request_type_id = #{fluidigm_request_id}", # Link to their requests

            'INNER JOIN well_links AS stock_well_link ON stock_well_link.target_well_id = fluidigm_plate_association.content_id AND type= \'stock\'',
            'LEFT OUTER JOIN events ON eventful_id = stock_well_link.source_well_id AND eventful_type = "Asset" AND (family = "update_gender_markers" OR family = "update_sequenom_count") AND content = "FLUIDIGM" '
          ]

      plates_with_fluidigm_events_updated = Plate.find(:all,{
          :select => selection,
          :joins => joins,
          :conditions => 'events.id IS NOT NULL'
        })

      plates_without_fluidigm_events_updated = Plate.find(:all,{
          :select => selection,
          :joins => joins,
          :conditions => 'events.id IS NULL'
      })

      plates_to_update = plates_with_fluidigm_events_updated - (plates_with_fluidigm_events_updated & plates_without_fluidigm_events_updated)


      plates_to_update.each do |p|
        p.events.updated_fluidigm_plate!('FLUIDIGM_DATA')
      end

    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      # We remove all the FLUIDIGM_DATA events
      events = Event.find_by_content("FLUIDIGM_DATA")
      events.each {|e| e.destroy } unless events.nil?
    end
  end
end
