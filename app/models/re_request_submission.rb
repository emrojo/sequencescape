#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2013,2015 Genome Research Ltd.

class ReRequestSubmission < Order
  include Submission::LinearRequestGraph
  include Submission::Crossable

  def is_asset_applicable_to_type?(request_type, asset)
    true
  end
  private :is_asset_applicable_to_type?

  def all_samples_have_accession_numbers?
    input_asset_has_gone_through_submission_before? or super
  end
  private :all_samples_have_accession_numbers?

  # Returns true if the input asset is assumed to have passed through a submission before.  In that
  # case we can assume that it has passed through the accession number checks and is therefore
  # valid this time round.
  def input_asset_has_gone_through_submission_before?
    @input_asset ||= Asset.find(self.assets.first)
    [ MultiplexedLibraryTube, LibraryTube ].any? { |root_type| @input_asset.is_a?(root_type) }
  end
  private :input_asset_has_gone_through_submission_before?
end
