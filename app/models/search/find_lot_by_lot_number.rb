#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014,2015 Genome Research Ltd.

class Search::FindLotByLotNumber < Search
  def scope(criteria)
    Lot.with_lot_number(criteria['lot_number'])
  end
end
