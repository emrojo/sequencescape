class Supplier < ActiveRecord::Base
  include Uuid::Uuidable
  include ::Io::Supplier::ApiIoSupport
  include SampleManifest::Associations

  has_many :studies, :through => :sample_manifests, :uniq => true
  validates_presence_of :name


  # Named scope for search by query string behaviour
 scope :for_search_query, lambda { |query,with_includes|
    {
      :conditions => [
        'suppliers.name IS NOT NULL AND (suppliers.name LIKE :like)', { :like => "%#{query}%", :query => query } ]
    }
  }

end
