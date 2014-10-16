module ModelExtensions::Asset
  def self.included(base)
    base.class_eval do
      scope :include_barcode_prefix, includes(:barcode_prefix)
    end
  end
end
