class ReattachGeneratedSampleManifests < ActiveRecord::Migration
  class Document < ActiveRecord::Base
    set_table_name('documents')
    set_inheritance_column(nil)

   scope :unattached, where( :documentable_id => nil )
   scope :for, lambda { |m| { :conditions => { :documentable_type => m } } }
   scope :extended_type, lambda { |m| { :conditions => { :documentable_extended => m } } }

    validates_presence_of :documentable_type
    validates_presence_of :documentable_id
  end

  def self.up
    ActiveRecord::Base.transaction do
      Document.unattached.extended_type('generated').for('SampleManifest').find_each do |document|
        match = /^sm-generated-(\d+)\.xls.+$/.match(document.filename)
        document.update_attributes!(:documentable_id => match[1].to_i) if match.present?
      end
    end
  end

  def self.down
    # Nothing to do here
  end
end
