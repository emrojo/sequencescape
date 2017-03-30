
class ExtractionAttribute < ActiveRecord::Base
  include Uuid::Uuidable

  validates_presence_of :created_by

  # This is the target asset for which to update the state
  belongs_to :target, class_name: 'Asset', foreign_key: :target_id
  validates_presence_of :target

  validates_presence_of :attributes_update

  serialize :attributes_update

  before_save :update_performed

  def is_reracking_attribute?(well)
    !well['previous_plate_uuid'].nil?
  end

  def update_performed
    if attributes_update['wells']
      attributes_update['wells'].each do |w|
        if is_reracking_attribute?(w)
          rerack_well(w)
        else
          rack_well(w)
        end
      end
    end
  end

  def location_wells
    target.wells.includes(:map, :sample).index_by(&:map_description)
  end

  def rack_well(well_data)
    return unless well_data['sample_tube_uuid']
    sample_tube = Uuid.find_by(external_id: well_data['sample_tube_uuid']).resource
    aliquots = sample_tube.aliquots.map(&:dup)
    samples = sample_tube.samples
    location = well_data['location']
    destination_well = location_wells[location]

    unless destination_well.samples.include?(samples)
      destination_well.aliquots << aliquots
      AssetLink.create_edge(sample_tube, destination_well)
    end    
  end

  def rerack_well(well_data)
    previous_parent = Uuid.find_by(external_id: well_data['previous_plate_uuid']).resource
    well = previous_parent.well_at(well_data['previous_location'])
    unless well.aliquots.empty?
      actual_parent = Uuid.find_by(external_id: well_data['actual_plate_uuid']).resource
      actual_parent.well_at(well_data['actual_location']).destroy

      well.update_attributes(parent: actual_parent)
      actual_parent.wells << well
    end    
  end

  private :update_performed
end
