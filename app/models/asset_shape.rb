#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013,2015 Genome Research Ltd.
class AssetShape < ActiveRecord::Base

  validates_presence_of :name, :horizontal_ratio, :vertical_ratio, :description_strategy
  validates_numericality_of :horizontal_ratio, :vertical_ratio

  def self.default_id
    AssetShape.find_by_name('Standard').id
  end

  def self.default
    AssetShape.find_by_name('Standard')
  end

  def standard?
    horizontal_ratio == 3 && vertical_ratio == 2
  end

  def multiplier(size)
    ((size/(vertical_ratio*horizontal_ratio))**0.5).to_i
  end
  private :multiplier

  def plate_height(size)
    multiplier(size)*vertical_ratio
  end

  def plate_width(size)
    multiplier(size)*horizontal_ratio
  end

  def horizontal_to_vertical(well_position,plate_size)
    alternate_position(well_position, plate_size, :width, :height)
  end

  def vertical_to_horizontal(well_position,plate_size)
    alternate_position(well_position, plate_size, :height, :width)
  end

  def interlaced_vertical_to_horizontal(well_position,plate_size)
    alternate_position(interlace(well_position,plate_size), plate_size, :height, :width)
  end

  def vertical_to_interlaced_vertical(well_position,plate_size)
    interlace(well_position,plate_size)
  end

  def interlace(i,size)
    m,d = (i-1).divmod(size/2)
    2*d+1+m
  end
  private :interlace

  def alternate_position(well_position, size, *dimensions)
    return nil unless Map.valid_well_position?(well_position)
    divisor, multiplier = dimensions.map { |n| send("plate_#{n}", size) }
    column, row = (well_position-1).divmod(divisor)
    return nil unless (0...multiplier).include?(column)
    return nil unless (0...divisor).include?(row)
    alternate = (row * multiplier) + column + 1
  end
  private :alternate_position

  def location_from_row_and_column(row, column, size=96)
    description_strategy.constantize.location_from_row_and_column(row, column,plate_width(size),size)
  end

end
