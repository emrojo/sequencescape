
class Api::LaneIO < Api::Base
  module Extensions
    module ClassMethods
      def render_class
        Api::LaneIO
      end
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        scope :including_associations_for_json, -> { includes([:uuid_object]) }
      end
    end

    def related_resources
      ['parents']
    end
  end
  renders_model(::Lane)

  map_attribute_to_json_attribute(:uuid)
  map_attribute_to_json_attribute(:id, 'internal_id')
  map_attribute_to_json_attribute(:name)
  map_attribute_to_json_attribute(:qc_state)
  map_attribute_to_json_attribute(:external_release)
  map_attribute_to_json_attribute(:two_dimensional_barcode)
  map_attribute_to_json_attribute(:created_at)
  map_attribute_to_json_attribute(:updated_at)

  self.related_resources = [:requests]
end
