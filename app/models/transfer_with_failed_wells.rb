class TransferWithFailedWells < Transfer
  def should_well_not_be_transferred?(well)
    well.nil? or well.aliquots.empty? or well.cancelled?
  end
end
