class AddTransferWithFailedWells < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      transfer_rt = RequestType.find_by_key!('Illumina_Cherrypicked_Shear')
      RequestType.create!(transfer_rt.attributes.merge({
        :key => 'Illumina_htp_with_failed_wells',
        :name => 'Illumina-HTP Transfer With Failed Wells',
        :request_class_name => "IlluminaHtp::Requests::TransferFailedWells"
      }))
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      RequestType.find_by_key('Illumina_htp_with_failed_wells').destroy
    end
  end
end
