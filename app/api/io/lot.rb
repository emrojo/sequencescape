#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014,2015 Genome Research Ltd.

class ::Io::Lot < ::Core::Io::Base
  set_model_for_input(::Lot)
  set_json_root(:lot)

  set_eager_loading { |model| model.include_lot_type.include_template }

  define_attribute_and_json_mapping(%Q{
                                           lot_number <=> lot_number
                                          received_at <=> received_at
                                        template.name  => template_name
                                         lot_type.name => lot_type_name
                                             lot_type <= lot_type
                                                 user <= user
                                             template <= template
  })
end
