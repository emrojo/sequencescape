#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015 Genome Research Ltd.

class BroadcastEvent::PlateTransfer < BroadcastEvent

  set_event_type 'plate_transfer'

  # Created when a plate receives material. Should be as cloase to the actual lab event as possible
  # Eg AssetAudit/BedVerification in SM
  # Robot start (State chage?) in Library world

  # Subjects
  # Target Plate
  # Source Plates
  # Stock plates
  # origin_plate

  # Metadata
  # Plate purpose
end
