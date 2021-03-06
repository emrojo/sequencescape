# frozen_string_literal: true

class LocationReport < ApplicationRecord
  # includes / extends
  extend DbFile::Uploader

  # attributes / variables
  serialize :faculty_sponsor_ids, Array
  serialize :plate_purpose_ids, Array
  serialize :barcodes, Array
  self.per_page = 20
  enum report_type: %i[type_selection type_labwhere]

  # relations
  belongs_to :study, required: false
  belongs_to :user

  # scopes
  scope :for_user, ->(user) { where(user_id: user) }

  # actions
  after_create :schedule_report
  has_uploaded :report, serialization_column: 'report_filename'

  # validations
  validates :name, presence: true
  validates :report_type, presence: true
  validate :check_location_barcode, :check_any_select_field_present, :check_both_dates_present_if_used,
           :check_end_date_same_or_after_start_date, :check_maxlength_of_barcodes, :check_any_plates_found

  def check_any_select_field_present
    return unless report_type == 'type_selection'
    attr_list = %i[faculty_sponsor_ids study_id start_date end_date plate_purpose_ids barcodes]
    errors.add(:base, I18n.t('location_reports.errors.no_selection_fields_filled')) if attr_list.all? { |attr| send(attr).blank? }
  end

  def check_location_barcode
    return unless report_type == 'type_labwhere'
    return if location_barcode.present?
    errors.add(:location_barcode, I18n.t('location_reports.errors.no_location_barcode_found'))
  end

  def check_both_dates_present_if_used
    return unless report_type == 'type_selection'
    return if (start_date.blank? && end_date.blank?) || (start_date.present? && end_date.present?)
    errors.add(:start_date, I18n.t('location_reports.errors.both_dates_required'))
  end

  def check_end_date_same_or_after_start_date
    return unless report_type == 'type_selection'
    return if (start_date.blank? || end_date.blank?) || end_date >= start_date
    errors.add(:end_date, I18n.t('location_reports.errors.end_date_after_start_date'))
  end

  def check_any_plates_found
    return unless report_type == 'type_selection'
    return if search_for_plates_by_selection.any?
    errors.add(:base, I18n.t('location_reports.errors.no_rows_found'))
  end

  def check_maxlength_of_barcodes
    return unless report_type == 'type_selection'
    return if barcodes.blank? || (barcodes.to_yaml.size <= column_for_attribute(:barcodes).limit)
    errors.add(:barcodes_text, I18n.t('location_reports.errors.barcodes_maxlength_exceeded'))
  end

  def column_headers
    %w[ScannedBarcode HumanBarcode Type Created Location Service StudyName StudyId FacultySponsor]
  end

  def generate!
    csv_options = { row_sep: "\r\n", force_quotes: true }
    filename    = ['locn_rpt', name].join('_') + '.csv'

    ActiveRecord::Base.transaction do
      Tempfile.open(filename) do |tempfile|
        generate_report_rows do |fields|
          tempfile << CSV.generate_line(fields, csv_options)
        end
        tempfile.rewind
        update_attributes!(report: tempfile)
      end
    end
  end

  def schedule_report
    Delayed::Job.enqueue LocationReportJob.new(id)
  end

  def generate_report_rows
    generate_plates_list

    if @plates_list.empty?
      yield([I18n.t('location_reports.errors.plate_list_empty')])
      return
    end

    yield column_headers

    @plates_list.each do |cur_plate|
      if cur_plate.studies.present?
        cur_plate.studies.each do |cur_study|
          yield(generate_report_row(cur_plate, cur_study))
        end
      else
        yield(generate_report_row(cur_plate, nil))
      end
    end
  end

  #######

  private

  #######

  def generate_plates_list
    @plates_list = if type_selection?
                     search_for_plates_by_selection
                   elsif type_labwhere?
                     search_for_plates_by_labwhere_locn_bc
                   else
                     []
                   end
  end

  def generate_report_row(cur_plate, cur_study)
    row = generate_plate_cols_for_row(cur_plate)
    row + generate_study_cols_for_row(cur_study)
  end

  def generate_plate_cols_for_row(cur_plate)
    cols = [] << cur_plate.machine_barcode
    cols << cur_plate.human_barcode
    # NB. some older plates do not have a purpose
    cols << (cur_plate.plate_purpose&.name || 'Unknown')
    cols << cur_plate.created_at.strftime('%Y-%m-%d %H:%M:%S')
    cols << cur_plate.storage_location
    cols << cur_plate.storage_location_service
  end

  def generate_study_cols_for_row(cur_study)
    return %w[Unknown Unknown] if cur_study.blank?
    # NB. some older studies may not have a name
    cols = [] << (cur_study.name || cur_study.id)
    cols << cur_study.id
    # NB. some studies may not have a faculty sponsor
    cols << (cur_study.study_metadata.faculty_sponsor&.name || 'Unknown')
  end

  def search_for_plates_by_selection
    params = {
      faculty_sponsor_ids:  faculty_sponsor_ids,
      study_id:             study_id,
      start_date:           start_date,
      end_date:             end_date,
      plate_purpose_ids:    plate_purpose_ids,
      barcodes:             barcodes
    }
    Plate.search_for_plates(params)
  end

  def search_for_plates_by_labwhere_locn_bc
    @labware_barcodes = []
    begin
      get_labwares_per_location(location_barcode) unless location_barcode.nil?
    rescue LabWhereClient::LabwhereException
      return []
    end
    return [] if @labware_barcodes.blank?
    params = {
      barcodes: @labware_barcodes
    }
    Plate.search_for_plates(params)
  end

  def get_labwares_per_location(curr_locn_bc)
    # collect any labware barcodes at this level
    curr_locn_labwares = LabWhereClient::Location.labwares(curr_locn_bc)
    curr_locn_labwares.map { |curr_labware| @labware_barcodes << curr_labware.barcode } if curr_locn_labwares.present?
    # search recursively in any child locations
    curr_locn_children = LabWhereClient::Location.children(curr_locn_bc)
    curr_locn_children.each { |curr_locn| get_labwares_per_location(curr_locn.barcode) } if curr_locn_children.present?
  end
end
