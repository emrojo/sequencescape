#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2015 Genome Research Ltd.

class Api::SampleTubesController < Api::AssetsController
  self.model_class = SampleTube

  before_filter :prepare_object, :only => [ :show, :children, :parents ]
  before_filter :prepare_list_context, :only => [ :index ]

private

  def prepare_list_context
    @context = ::SampleTube.including_associations_for_json
    @context = ::SampleTube.with_sample_id(params[:sample_id]) unless params[:sample_id].nil?
  end
end
