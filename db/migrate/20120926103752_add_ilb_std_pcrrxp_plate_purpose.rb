#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
class AddIlbStdPcrrxpPlatePurpose < ActiveRecord::Migration
  class Purpose < ActiveRecord::Base
    class Relationship < ActiveRecord::Base
      self.table_name =('plate_purpose_relationships')
      belongs_to :child, :class_name => 'AddIlbStdPcrrxpPlatePurpose::Purpose'
      belongs_to :transfer_request_type, :class_name => 'AddIlbStdPcrrxpPlatePurpose::RequestType'

      scope :with_child,  lambda { |plate_purpose| { :conditions => { :child_id  => plate_purpose.id } } }
    end

    self.table_name =('plate_purposes')
    self.inheritance_column =

    has_many :child_relationships, :class_name => 'AddIlbStdPcrrxpPlatePurpose::Purpose::Relationship', :foreign_key => :parent_id, :dependent => :destroy
  end

  class RequestType < ActiveRecord::Base
    self.table_name =('request_types')
    self.inheritance_column =
  end

  def self.up
    ActiveRecord::Base.transaction do
      pcr_xp   = Purpose.find_by_name('ILB_STD_PCRXP') or raise "Cannot find ILB_STD_PCRXP"
      pcr_r_xp = pcr_xp.clone.tap { |p| p.name = 'ILB_STD_PCRRXP' ; p.save! }

      # Ensure the child transfers are correctly setup
      pcr_xp.child_relationships.each do |relationship|
        request_type = relationship.transfer_request_type.clone.tap do |r|
          r.name = r.name.sub(pcr_xp.name, pcr_r_xp.name)
          r.key  = r.name.gsub(/\W+/, '_')
          r.save!
        end
        pcr_r_xp.child_relationships.create!(:child => relationship.child, :transfer_request_type => request_type)
      end

      # Ensure that the PCR-R plate goes into the appropriate type
      pcr_r = Purpose.find_by_name('ILB_STD_PCRR') or raise "Cannot find ILB_STD_PCRR"
      pcr_r.child_relationships.with_child(pcr_xp).all.each do |relationship|
        relationship.child = pcr_r_xp
        relationship.save!
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      pcr_xp   = Purpose.find_by_name('ILB_STD_PCRXP')  or raise "Cannot find ILB_STD_PCRXP"
      pcr_r_xp = Purpose.find_by_name('ILB_STD_PCRRXP') or raise "Cannot find ILB_STD_PCRRXP"
      pcr_r    = Purpose.find_by_name('ILB_STD_PCRR')   or raise "Cannot find ILB_STD_PCRR"

      pcr_r.child_relationships.with_child(pcr_r_xp).all.each do |relationship|
        relationship.child = pcr_xp
        relationship.save!
      end

      pcr_r_xp.destroy
    end
  end
end
