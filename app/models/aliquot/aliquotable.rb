
# Something that is aliquotable can be part of an aliquot.  So sample and tag are both examples.
module Aliquot::Aliquotable
  def self.included(base)
    base.class_eval do
      extend ClassMethods

      has_many :aliquots
      has_many :receptacles, ->() { distinct }, through: :aliquots
      has_one :primary_aliquot, ->() { order('created_at ASC, aliquots.id ASC').readonly }, class_name: 'Aliquot'
      has_one :primary_receptacle, ->() { order('aliquots.created_at ASC, aliquots.id ASC') }, through: :primary_aliquot, source: :receptacle

      has_many :requests, through: :assets
      has_many :submissions, through: :requests

      scope :contained_in, ->(receptacles) { joins(:receptacles).where(assets: { id: receptacles }) }
    end
  end

  module ClassMethods
    def receptacle_alias(name, options = {}, &block)
      has_many(name, ->() { distinct }, options.merge(through: :aliquots, source: :receptacle), &block)
    end
  end
end
