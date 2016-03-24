#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2011,2012,2015 Genome Research Ltd.

class ::Io::Transfer::FromPlateToTubeBySubmission < ::Core::Io::Base
  set_model_for_input(::Transfer::FromPlateToTubeBySubmission)
  set_json_root(:transfer)
  set_eager_loading { |model| model.include_source.include_transfers }

  define_attribute_and_json_mapping(%Q{
            user <=> user
          source <=> source
       transfers  => transfers
  })
end

