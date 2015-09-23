#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012 Genome Research Ltd.
class StudyReport < ActiveRecord::Base
  extend DbFile::Uploader

  class ProcessingError < Exception
  end
  cattr_reader :per_page
  @@per_page = 50

 scope :for_study, lambda { |study| { :conditions => { :study_id => study.id } } }
 scope :for_user, lambda { |user| { :conditions => { :user_id => user.id } } }
  #named_scope :without_files, lambda { select_without_file_columns_for(:report) }

  has_uploaded :report, {:serialization_column => "report_filename"}

  belongs_to :study
  belongs_to :user
  validates_presence_of :study

  def headers
     ["Study","Sample Name","Plate","Supplier Volume","Supplier Concentration","Supplier Sample Name",
       "Supplier Gender", "Concentration","Sequenome Count", "Sequenome Gender",
       "Pico","Gel", "Qc Status", "Genotyping Status", "Genotyping Chip"]
   end

  def perform
    ActiveRecord::Base.transaction do
      csv_options =  {:row_sep => "\r\n", :force_quotes => true }
      Tempfile.open("#{self.study.dehumanise_abbreviated_name}_progress_report.csv") do |tempfile|
        Study.find(self.study_id).progress_report_on_all_assets do |fields|
          tempfile.puts(CSV.generate_line(fields, csv_options))
        end
        tempfile.open  # Reopen the temporary file
        self.update_attributes!(:report => tempfile)
      end
    end
  end
  handle_asynchronously :perform, :priority => Proc.new {|i| i.priority }

  def priority
    configatron.delayed_job.fetch(:study_report_priority) || 100
  end

end
