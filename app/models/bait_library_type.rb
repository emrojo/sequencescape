class BaitLibraryType < ActiveRecord::Base
  has_many :bait_libraries

  # Types have names, need to be unique
  validates_presence_of :name
  validates_uniqueness_of :name

  scope :visible, where(:visible => true)

  def hide
    self.visible = false
    save!
  end

end
