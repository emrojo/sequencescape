#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015 Genome Research Ltd.

class RenameSupplierUrlColumn < ActiveRecord::Migration
  def up
    rename_column :suppliers, :url, :supplier_url
  end

  def down
    rename_column :suppliers, :supplier_url, :url
  end
end
