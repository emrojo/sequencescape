#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013,2015 Genome Research Ltd.

class IlluminaHtp::DownstreamPlatePurpose < PlatePurpose

  def source_wells_for(stock_wells)
    Well.in_column_major_order.stock_wells_for(stock_wells)
  end

  def library_source_plates(plate)
    super.map {|s| s.source_plates }.flatten.uniq
  end

  def library_source_plate(plate)
    super.source_plate
  end

end
