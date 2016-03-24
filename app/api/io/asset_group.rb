#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2015 Genome Research Ltd.

class ::Io::AssetGroup < ::Core::Io::Base
  set_model_for_input(::AssetGroup)
  set_json_root(:asset_group)
  set_eager_loading { |model| model.include_study.include_assets }

  define_attribute_and_json_mapping(%Q{
          name  => name
    study.name  => study.name
  })
end
