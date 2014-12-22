class AddXtenPlatePurposeRelationships < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      PlatePurpose::Relationship.create!(
        :parent => Purpose.find_by_name!("Lib Norm"),
        :child => Purpose.find_by_name!("Lib Norm 2"),
        :transfer_request_type => RequestType.find_by_key("Illumina_htp_with_failed_wells")
        )

      PlatePurpose::Relationship.create!(
        :parent => Purpose.find_by_name!("Lib Norm 2"),
        :child => Purpose.find_by_name!("Lib Norm 2 Pool"),
        :transfer_request_type => RequestType.find_by_key("Illumina_htp_with_failed_wells")
        )

      PlatePurpose::Relationship.create!(
        :parent => Purpose.find_by_name!("Lib PCR-XP"),
        :child => Purpose.find_by_name!("Lib Norm"),
        :transfer_request_type => RequestType.find_by_key("Illumina_htp_with_failed_wells")
        )
    end
  end

  def self.down
  end
end
