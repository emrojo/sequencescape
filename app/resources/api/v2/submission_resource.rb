# frozen_string_literal: true

module Api
  module V2
    # Provides a JSON API representation of submission
    # See: http://jsonapi-resources.com/ for JSONAPI::Resource documentation
    class SubmissionResource < BaseResource
      # Constants...

      immutable # uncomment to make the resource immutable

      # model_name / model_hint if required

      default_includes :uuid_object

      # Associations:

      # Attributes
      attribute :uuid, readonly: true
      attribute :name, readonly: true
      attribute :used_tags, readonly: true
      attribute :number_of_lanes, readonly: true
      attribute :bait_library_name, readonly: true

      # Filters

      # Custom methods
      # These shouldn't be used for business logic, and a more about
      # I/O and isolating implementation details.

      def number_of_lanes
        multipliers = _model.orders.map(&:request_options).pluck(:multiplier).map(&:values).flatten.uniq
        return multipliers.first if multipliers.length == 1
        nil
      end

      def bait_library_name
        bait_library_names = _model.orders.map(&:request_options).pluck(:bait_library_name)
        return bait_library_names.first if bait_library_names.length == 1
        nil
      end

      # Class method overrides
    end
  end
end
