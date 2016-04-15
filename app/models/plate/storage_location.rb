require 'lib/lab_where_client'

module Plate::StorageLocation
  def storage_location
    @storage_location ||= obtain_storage_location
  end

  def storage_location_service
    @storage_location_service
  end

  def obtain_storage_location
    # From LabWhere
    info_from_labwhere = LabWhereClient::Labware.find_by_barcode(ean13_barcode)
    unless info_from_labwhere.nil? || info_from_labwhere.location.nil?
      @storage_location_service = 'LabWhere'
      return info_from_labwhere.location.location_info
    end

    # From ETS
    @storage_location_service = 'ETS'
    return "Control" if self.is_a?(ControlPlate)
    return "" if self.barcode.blank?
    return ['storage_area', 'storage_device', 'building_area', 'building'].map do |key|
      self.get_external_value(key)
    end.compact.join(' - ')

  rescue LabWhereClient::LabwhereException => e
    @storage_location_service = 'None'
    return "Not found (#{e.message})"
  end
end
