# frozen_string_literal: true

# Will construct plates with well_count wells filled with samples
class UatActions::GeneratePlates < UatActions
  self.title = 'Generate Plate'
  self.description = 'Generate plates in the selected study.'

  form_field :plate_purpose_id, :select, label: 'Plate Purpose', help: 'Select the plate purpose to create', select_options: -> { PlatePurpose.pluck(:name, :id) }
  form_field :plate_count, :number_field, label: 'Plate Count', help: 'The number of plates to generate', options: { minimum: 1, maximum: 20 }
  form_field :well_count, :number_field, label: 'Well Count', help: 'The number of occupied wells on each plate', options: { minimum: 1 }
  form_field :study_id, :select, label: 'Study', help: 'The study under which samples begin. List includes all active studies.', select_options: -> { Study.active.pluck(:name, :id) }
  form_field :well_layout, :select, label: 'Well layout', help: 'The order in which wells are laid out. Affects where empty wells are located.', select_options: %w[Column Row Random]

  def self.default
    new(
      plate_count: 1,
      well_count: 96,
      study_id: UatActions::StaticRecords.study.id,
      plate_purpose_id: PlatePurpose.stock_plate_purpose.id,
      well_layout: 'Column'
    )
  end

  def perform
    plate_count.to_i.times do |i|
      plate_purpose.create!.tap do |plate|
        construct_wells(plate)
        report["plate_#{i}"] = plate.human_barcode
      end
    end
  end

  private

  def construct_wells(plate)
    wells(plate).each do |well|
      well.aliquots.create!(sample: Sample.create!(name: "sample_#{plate.human_barcode}_#{well.map.description}", studies: [study]))
    end
  end

  def wells(plate)
    case well_layout
    when 'Column' then plate.wells.in_column_major_order.limit(well_count)
    when 'Row' then plate.wells.in_row_major_order.limit(well_count)
    when 'Random' then plate.wells.all.sample(well_count.to_i)
    else
      raise StandardError, "Unknown layout: #{well_layout}"
    end
  end

  def study
    @study ||= Study.find(study_id)
  end

  def plate_purpose
    Purpose.find(plate_purpose_id)
  end
end