#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2013,2014,2015 Genome Research Ltd.

class AssetGroup < ActiveRecord::Base

  include Uuid::Uuidable
  include ModelExtensions::AssetGroup

  belongs_to :study
  belongs_to :user
  belongs_to :submission      # Optional, present if created by a particular submission

  has_many :asset_group_assets
  has_many :assets, :through => :asset_group_assets

  validates :name, :presence => true, :uniqueness => true
  validates :study, :presence => true

 scope :for_search_query, ->(query,with_includes) { where([ 'name LIKE ?', "%#{query}%" ]) }

  def all_samples_have_accession_numbers?
    unaccessioned_samples.count == 0
  end

  def unaccessioned_samples
    Sample.find(:all,
      :joins => [
        'INNER JOIN aliquots ON aliquots.sample_id = samples.id',
        'INNER JOIN sample_metadata ON sample_metadata.sample_id = samples.id'
        ],
        :conditions => ['aliquots.receptacle_id IN (?) AND sample_ebi_accession_number IS NULL',assets.map(&:id)]
    )
  end

  def self.find_or_create_asset_group(new_assets_name, study)
    # Is new name set or create group
    asset_group = nil
    if ! new_assets_name.empty?
      asset_group = AssetGroup.find(:first,:conditions => [" name = ? ", new_assets_name ])
      if asset_group.nil?
        #create new asset group
        asset_group = AssetGroup.create(:name => new_assets_name, :study => study)
        asset_group.save
      end
    end
    return asset_group
  end

  def automatic_move?
    asset_types.one? && assets.first.automatic_move?
  end

  def asset_types
    assets.map(&:sti_type).uniq
  end

  def duplicate(project)
    # TODO: Implement me
  end

  def move(assets)
    # TODO: Implement me
  end


end
