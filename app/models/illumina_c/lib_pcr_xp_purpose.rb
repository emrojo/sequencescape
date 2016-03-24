#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013,2014,2015 Genome Research Ltd.

class IlluminaC::LibPcrXpPurpose < PlatePurpose

  include PlatePurpose::RequestAttachment

  self.connect_on = 'qc_complete'
  self.connected_class = IlluminaC::Requests::LibraryRequest
  self.connect_downstream = false

end
