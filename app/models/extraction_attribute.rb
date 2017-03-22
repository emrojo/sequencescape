
class ExtractionAttribute < ActiveRecord::Base
  include Uuid::Uuidable

  validates_presence_of :created_by

  # This is the target asset for which to update the state
  belongs_to :target, class_name: 'Asset', foreign_key: :target_id
  validates_presence_of :target

  validates_presence_of :attributes_update

  serialize :attributes_update

  before_save :update_performed

  def update_performed
    if attributes_update['wells']
      location_wells = target.wells.includes(:map, :sample).index_by(&:map_description)
      attributes_update['wells'].each do |w|
        location = w['location']
        next unless w['sample_tube_uuid']
        sample_tube = Uuid.find_by(external_id: w['sample_tube_uuid']).resource
        aliquots = sample_tube.aliquots.map(&:dup)
        samples = sample_tube.samples
        destination_well = location_wells[location]

        unless destination_well.samples.include?(samples)
          destination_well.aliquots << aliquots
          AssetLink.create_edge(sample_tube, destination_well)
        end
      end
    end
    if attributes_update['reracks']
      rerack_updates
    end
  end

  def rerack_updates
    attributes_update['reracks'].each do |t|
      previous_parent = Uuid.find_by(external_id: t['previous_plate_uuid']).resource
      well = previous_parent.well_at(t['previous_location'])
      actual_parent = Uuid.find_by(external_id: t['actual_plate_uuid']).resource
      actual_parent.well_at(t['actual_location']).destroy

      well.update_attributes(parent: actual_parent)
      actual_parent.wells << well
    end
  end

  private :update_performed
end
