class Identifier < ActiveRecord::Base
  validates :resource_name, :presence => true, :identifiable_id
  validates_uniqueness_of :external_id, :scope => [:identifiable_id, :resource_name] # only one external per asset per resource

  belongs_to :identifiable, :polymorphic => true
  belongs_to :external, :polymorphic => true
end
