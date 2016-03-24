#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2015 Genome Research Ltd.

class ::Io::PacBioLibraryTube < ::Io::Asset
  set_model_for_input(::PacBioLibraryTube)
  set_json_root(:pac_bio_library_tube)
  # set_eager_loading { |model| model }   # TODO: uncomment and add any named_scopes that do includes you need

  define_attribute_and_json_mapping(%Q{
        pac_bio_library_tube_metadata.prep_kit_barcode <=> prep_kit_barcode
     pac_bio_library_tube_metadata.binding_kit_barcode <=> binding_kit_barcode
    pac_bio_library_tube_metadata.smrt_cells_available <=> smrt_cells_available
            pac_bio_library_tube_metadata.movie_length <=> movie_length
  })
end
