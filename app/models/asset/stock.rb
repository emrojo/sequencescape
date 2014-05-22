module Asset::Stock
  # Extending this module will allow an asset to have a stock asset and be able to
  # create it.
  module CanCreateStockAsset
    def self.extended(base)
      base.class_eval do
        has_one_as_child(:stock_asset, :class_name => stock_asset_type.name)

        stock_asset_factory(:create_stock_asset!, :create!)
        stock_asset_factory(:new_stock_asset, :new)
        deprecate :new_stock_asset

        delegate :is_a_stock_asset?, :to => 'self.class'

        def can_create_stock_asset?
          return ! has_stock_asset?# && ! is_a_stock_asset?
        end
      end
    end
    
    def stock_asset_factory(name, ctor)
      line = __LINE__
      class_eval(%Q{
        def #{name}(attributes = {}, &block)
          if ! can_create_stock_asset?
            if name.end_with? "!"
              raise ActiveRecord::RecordInvalid, self
            else
              return nil
            end
          end
          self.class.stock_asset_type.#{ctor}(attributes.reverse_merge(
            :name     => "(s) \#{self.name}",
            :barcode  => AssetBarcode.new_barcode,
            :aliquots => self.aliquots.map(&:clone),
            :purpose  => self.class.stock_asset_purpose
          ), &block)
        end
      }, __FILE__, line)
    end
    
    
  end

  def can_create_stock_asset?
    false
  end
  
  def is_a_stock_asset?
    true
  end
  
end
