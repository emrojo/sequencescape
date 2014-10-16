module Named
  def self.included(base)
    base.class_eval do
     scope :with_name, lambda { |*names| { :conditions => { :name => names.flatten } } }
       scope :sorted_by_name, order('name ASC')
    end
  end
end
