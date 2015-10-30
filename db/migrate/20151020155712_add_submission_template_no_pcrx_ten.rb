require 'submission_serializer'

class AddSubmissionTemplateNoPcrxTen < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do |t|
      st = SubmissionSerializer.construct!({
        :name => "Illumina-C - General no PCR - HiSeq-X sequencing",
        :submission_class_name => "LinearSubmission",
        :product_line => "Illumina-C",
        :submission_parameters => {
          :request_types => ["illumina_c_nopcr", "illumina_b_hiseq_x_paired_end_sequencing"],
          :workflow => "short_read_sequencing"
        }
      })
      lt = LibraryType.find_or_create_by_name("HiSeqX PCR free")
      rt = RequestType.find_by_key("illumina_c_nopcr").library_types << lt
      ["illumina_a_hiseq_x_paired_end_sequencing", "illumina_b_hiseq_x_paired_end_sequencing"].each do |xtlb_name|
        RequestType.find_by_key(xtlb_name).library_types << lt
      end

      tag_group = TagGroup.find_by_name('NEXTflex-96 barcoded adapters')

      TagLayoutTemplate.create!(
        :name                => "NEXTflex-96 barcoded adapters tags in rows (first oligo: AACGTGAT)",
        :direction_algorithm => 'TagLayout::InRows',
        :walking_algorithm   => 'TagLayout::WalkWellsOfPlate',
        :tag_group           => tag_group
      )
    end
  end

  def self.down
    ActiveRecord::Base.transaction do |t|
      hiseqlt = LibraryType.find_by_name("HiSeqX PCR free")
      unless hiseqlt.nil?
        ["illumina_c_nopcr", "illumina_a_hiseq_x_paired_end_sequencing", "illumina_b_hiseq_x_paired_end_sequencing"].each do |rt_name|
          RequestType.find_by_key(rt_name).library_types.reject!{|lt| lt == hiseqlt }
          RequestType.find_by_key(rt_name).library_types.save
        end
        hiseqlt.destroy
      end
      TagLayoutTemplate.find_by_name("NEXTflex-96 barcoded adapters tags in rows (first oligo: AACGTGAT)").destroy
      SubmissionTemplate.find_by_name("Illumina-C - General no PCR - HiSeq-X sequencing").destroy
    end
  end
end
