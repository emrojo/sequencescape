module Cherrypick
  module PlateLayout
    class PlateLayoutRenderer
      EMPTY_WELL          = [0, 'Empty', ''].freeze
      TEMPLATE_EMPTY_WELL = [0, '---', ''].freeze

      include ActiveModel::Model

      attr_accessor :size
      attr_accessor :shape
      attr_accessor :requests
      attr_accessor :control_requests

      attr_accessor :control_positions
      attr_accessor :requests_positions
      attr_accessor :template_positions
      attr_accessor :partial_plate_positions

      validates_presence_of :size, :shape, :requests, :requests_positions
      validates_presence_of :control_positions, if: :control_requests
      validates_presence_of :control_requests, if: :control_positions
      validate :same_requests_size_and_positions_size
      validate :same_controls_size_and_controls_positions_size
      validate :no_clash_between_positions
      validate :enough_space
      
      
      def render(position)
        return TEMPLATE_EMPTY_WELL if template_positions.include?(position)
        return EMPTY_WELL if partial_plate_positions.include?(position)        
        return render_request(control_requests[control_positions.find_index(position)]) if control_positions.include?(position)
        render_request(requests[requests_positions.find_index(position)])
      end

      def render_request(request)
        [request.id, request.asset.plate.human_barcode, request.asset.map_description]
      end

      def by_column
        size.times.map {|p| render(shape.vertical_to_horizontal(p+1, size))}
        #shape.vertical_to_horizontal(requests.length + 1, size).map {|p| render(p)}
      end

      def by_row
        size.times.map {|p| render(p)}
      end

      # Like the bishop in chess
      def by_interleaced_column
        size.times.map {|p| render(shape.interlaced_vertical_to_horizontal(p+1, size))}
        #shape.interlaced_vertical_to_horizontal(requests.length + 1, size)
      end

      def by_direction(direction)
        return by_column if direction == 'column'
        return by_row if direction == 'row'
        return by_interleaced_column if direction == 'interleaced_column'
        by_column
      end

      protected
      # Validations 
      def same_requests_size_and_positions_size
        return unless requests && requests_positions
        return if requests.length == requests_positions.length
        errors.add(:requests, 'Different number of positions and requests provided')
      end

      def same_controls_size_and_controls_positions_size
        return unless control_requests && control_positions
        return if control_requests.length == control_positions.length
        errors.add(:requests, 'Different number of positions and controls provided')
      end

      def no_clash_between_positions
        elems = [control_positions, requests_positions, template_positions, partial_plate_positions].flatten.compact
        return if elems.length == elems.uniq.length
        errors.add(:base, "There are duplicates in the positions provided")
      end

      def enough_space
        return if requests.nil? || size.nil?
        size_for_controls = control_requests ? control_requests.length : 0
        return if requests.length + size_for_controls <= size
        errors.add(:size, "There are not enough space to allocate requests and control requests")
      end
    end
  end
end
