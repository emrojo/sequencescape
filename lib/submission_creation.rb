class SubmissionCreation

  attr_reader :plate, :slice_size

  def initialize(plate,slice_size=12)
    @plate = plate
    @slice_size = slice_size
  end

  def request_type_ids
    [
      RequestType.find_by_key('illumina_b_shared').id,
      RequestType.find_by_key('illumina_htp_library_creation').id,
      RequestType.find_by_key('illumina_htp_strip_tube_creation').try(:id)
    ].compact
  end

  def each_asset_group
    ('A'..'H').each do |row|
      wells = plate.wells.in_column_major_order.in_plate_row(row, 96)
      ags = wells.each_slice(slice_size).map do |assets|
        AssetGroup.create!(
          :name => "#{plate.barcode}-#{row}#{assets.first.id}",
          :assets => assets,
          :study => Study.first
        )
      end
      yield ags
    end
  end

  def build_submissions
    ActiveRecord::Base.transaction do
      each_asset_group do |asset_groups|
        Submission.create!(
          :name => "#{asset_groups.first.name}",
          :user => User.first,
          :state => "building",
          :orders => asset_groups.map do |asset_group|
              LinearSubmission.create!(
              :study => Study.first,
              :project => Project.first,
              :workflow_id => 1,
              :asset_group => asset_group,
              :user => User.first,
              :request_types => request_type_ids,
              :request_options => {
                :read_length => '150',
                'fragment_size_required_from' => '350',
                'fragment_size_required_to' => '350',
                'library_type' => 'Standard'
              }
            )
          end
        ).built!
      end
    end
  end
end


s = SubmissionCreation.new(Plate.find_by_barcode(5),6)
s.build_submissions
