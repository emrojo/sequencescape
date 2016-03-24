#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015,2016 Genome Research Ltd.


module SharedBehaviour::Deprecatable

  def self.included(base)
    base.class_eval do
      scope :active, ->() { where(:deprecated_at => nil) }
    end
  end

  def deprecate!
    self.deprecated_at = DateTime.now
    save!
  end

  # If we have a datestamp we are deprecated
  def deprecated?
    deprecated_at?
  end

end
