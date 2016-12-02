#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2014,2015,2016 Genome Research Ltd.

require "test_helper"

class Sample
  def move(study_from, study_to, asset_group, new_assets_name, current_user, submission_to)
      asset_group ||=  AssetGroup.find_or_create_asset_group(new_assets_name, study_to)
    study_to.take_sample(self, study_from, current_user, asset_group)
  end
end
class SampleTest < ActiveSupport::TestCase
    def assert_accession_service(type)
      service = {
        ega: EgaAccessionService,
        ena: EnaAccessionService,
        none: NoAccessionService,
        unsuitable: UnsuitableAccessionService
      }[type]
      assert @sample.accession_service.is_a?(service), "Sent to #{@sample.accession_service.provider} not #{type}"
    end

  context "A Sample" do

    should have_many :study_samples
    should have_many :studies#, :through => :study_samples

    context "when used in older assets" do

      setup do
        @sample = create :sample
        @tube_a = create :empty_library_tube
        @tube_b = create :empty_sample_tube

       create(:aliquot, :sample=>@sample, :receptacle => @tube_b)
       create(:aliquot, :sample=>@sample, :receptacle => @tube_a)
      end

      should "have the first tube it was added to as a primary asset" do
        assert_equal @sample.reload.primary_receptacle, @tube_b
      end

    end

    context "move a Sample" do
      setup do
        @study_from = create :study
        @study_to   = create :study
        @sample_from = create :sample
          @sample_from_ok = create(:sample,:studies => [@study_from])
        @workflow = create :submission_workflow
        @new_assets_name = ""
        @current_user = create :user

        @asset_1 = create(:empty_sample_tube, :name => @sample_from.name).tap { |sample_tube| sample_tube.aliquots.create!(:sample => @sample_from) }

        @asset_group = create :asset_group, :name => "not mx"
        @asset_group_asset = create :asset_group_asset, :asset_id => @asset_1.id, :asset_group_id => @asset_group.id


        @request_type_1 = create :request_type, :name => "request type 1"
        @request_type_2 = create :request_type, :name => "request type 2"
        @request_type_3 = create :request_type, :name => "Pair end sequencing"

        @request_type_ids = [@request_type_1.id, @request_type_3.id]

        @request_options = {"read_length"=>"108", "fragment_size_required_from"=>"150", "fragment_size_required_to"=>"200"}

        @submission_to = FactoryHelp::submission :study => @study_to, :workflow => @workflow, :assets => [ @asset_1 ],
                         :request_types => @request_type_ids, :request_options => @request_options

      end

      context "only valid assets and without submissions" do
        setup do
          @asset_from = create(:empty_sample_tube, :name => @sample_from_ok.name).tap { |sample_tube| sample_tube.aliquots.create!(:sample => @sample_from_ok) }
          @asset_group_from_new = create :asset_group, :name => "Asset_Sample_New", :study => @study_from
          @asset_group_asset_from = create :asset_group_asset, :asset_id => @asset_from.id, :asset_group_id => @asset_group_from_new.id


          @asset_from.aliquots.each {|a| a.study= @study_from}
          @asset_from.save!

          @sample_to = create :sample
          @asset_to = create(:empty_sample_tube, :name => @sample_to.name).tap { |sample_tube| sample_tube.aliquots.create!(:sample => @sample_to) }
          @asset_group_to_new = create :asset_group, :name => "Asset_Sample"
          @asset_group_asset_to = create :asset_group_asset, :asset_id => @asset_to.id, :asset_group_id => @asset_group_to_new.id

        end

        should "return true" do
          @result = @sample_from_ok.move(@study_from, @study_to, @asset_group_to_new, @new_assets_name, @current_user, "0")
          assert_equal true, @result
          assert_equal @asset_group_to_new.id, @sample_from_ok.assets.first.asset_group_assets.first.asset_group_id
        end

        should "move aliquots" do
          @result = @sample_from_ok.move(@study_from, @study_to, @asset_group_to_new, @new_assets_name, @current_user, "0")
          assert @asset_from.aliquots(true).all? {|a| a.study  == @study_to}
        end
      end

      context  "With Study_from with submission and New assets or assets without submission" do
        setup do
          @sample_from_ok = create :sample
          @asset_from = create(:empty_sample_tube,
                                :name => @sample_from_ok.name).tap { |sample_tube|
            sample_tube.aliquots.create!(:sample => @sample_from_ok, :study => @study_from) }
          @asset_group_from_new = create :asset_group, :name => "Asset_Sample_From", :study => @study_from
          @asset_group_asset_from = create :asset_group_asset, :asset_id => @asset_from.id, :asset_group_id => @asset_group_from_new.id

          @sample_to = create :sample
          @asset_to = create(:empty_sample_tube, :name => @sample_to.name).tap { |sample_tube| sample_tube.aliquots.create!(:sample => @sample_to) }
          @asset_group_to_new = create :asset_group, :name => "Asset_Sample_To"
          @asset_group_asset_to = create :asset_group_asset, :asset_id => @asset_to.id, :asset_group_id => @asset_group_to_new.id

          @request_type_ids_from = [@request_type_2.id, @request_type_3.id]
          @item = create :item
          @submission_from_1 = FactoryHelp::submission :study => @study_from, :workflow => @workflow, :assets => [ @asset_from ],
                           :request_types => @request_type_ids_from, :request_options => @request_options
          @request = create :request, :submission => @submission_from_1, :request_type => @request_type_1, :study => @study_from, :workflow => @workflow, :item => @item
        end

        should "return true" do
          @result = @sample_from_ok.move(@study_from, @study_to, @asset_group_to_new, @new_assets_name, @current_user, "0")
          @new_sub_to = Submission.last
          asset_submission_to = @new_sub_to.orders.first.assets
          assert_equal true, @result
          #the assets of submission_from is now in submission_to
          assert_equal asset_submission_to, [ @asset_from ]

          # we don't move asset from submission anymore
          #the assets of submission_from is empty. @submission_from_1
          #@submission_from_1.reload
          #assert_equal [], @submission_from_1.assets

          #check link about AssetGroup
          assert_equal @asset_group_to_new.id, @sample_from_ok.assets.first.asset_group_assets.first.asset_group_id
        end
      end


      context  "With 2 submissions, with same requests" do
        setup do
          @sample_from_ok = create :sample
          @asset_from = create(:empty_sample_tube,
                                :name => @sample_from_ok.name).tap { |sample_tube|
            sample_tube.aliquots.create!(:sample => @sample_from_ok, :study => @study_from) }
          @asset_group_from_new = create :asset_group, :name => "Asset_Sample_From", :study => @study_from
          @asset_group_asset_from = create :asset_group_asset, :asset_id => @asset_from.id, :asset_group_id => @asset_group_from_new.id

          @sample_to = create :sample
          @asset_to = create(:empty_sample_tube,
                              :name => @sample_to.name).tap { |sample_tube| sample_tube.aliquots.create!(:sample => @sample_to) }
          @asset_group_to_new = create :asset_group, :name => "Asset_Sample_To"
          @asset_group_asset_to = create :asset_group_asset, :asset_id => @asset_to.id, :asset_group_id => @asset_group_to_new.id

          @request_type_ids_both = [@request_type_2.id, @request_type_3.id]
          @item = create :item
          @submission_from_1 = FactoryHelp::submission :study => @study_from, :workflow => @workflow, :assets => [ @asset_from ],
                           :request_types => @request_type_ids_both, :request_options => @request_options
          @request = create :request, :submission => @submission_from_1, :request_type => @request_type_1, :study => @study_from, :workflow => @workflow, :item => @item

          @item_to = create :item
          @submission_to_1 = FactoryHelp::submission :study => @study_to, :workflow => @workflow, :assets => [ @asset_to ],
                             :request_types => @request_type_ids_both, :request_options => @request_options
          @request = create :request, :submission => @submission_to_1, :request_type => @request_type_1, :study => @study_to, :workflow => @workflow, :item => @item_to
        end

        should "return true" do
          @result = @sample_from_ok.move(@study_from, @study_to, @asset_group_to_new, @new_assets_name, @current_user, @submission_to_1.id)
          assert_equal true, @result

          # we don't move stuff between submissin anymore
          #@submission_from_1.reload
          #@submission_to_1.reload
          ## the assets of submission_from is now in submission_to
          #assert_equal @submission_to_1.assets, [ @asset_to, @asset_from ]
          ## the assets of submission_from is empty. @submission_from_1
          #assert_equal [], @submission_from_1.assets
          #check link about AssetGroup
          assert_equal @asset_group_to_new.id, @sample_from_ok.assets.first.asset_group_assets.first.asset_group_id
        end
      end
    end

    context "#accession_number?" do
      setup do
        @sample = create :sample
      end
      context "with nil accession number" do
        setup do
          @sample.sample_metadata.sample_ebi_accession_number = nil
        end
        should "return false" do
          assert ! @sample.accession_number?
        end
      end
      context "with a blank accession number" do
        setup do
          @sample.sample_metadata.sample_ebi_accession_number = ''
        end
        should "return false" do
          assert ! @sample.accession_number?
        end
      end
      context "with a valid accession number" do
        setup do
          @sample.sample_metadata.sample_ebi_accession_number = 'ERS00001'
        end
        should "return true" do
          assert @sample.accession_number?
        end
      end
    end

    context "#accession service" do
      context 'with one study' do
        setup do
          @sample = create :sample
          @study = create :open_study, accession_number: 'ENA123'
          create :study_sample, study: @study, sample: @sample
        end
        should 'delegate to the study' do
          assert_equal @study, @sample.primary_study
          assert_accession_service(:ena)
        end
      end
      context 'with one un-accessioned study' do
        setup do
          @sample = create :sample
          @study = create :open_study
          create :study_sample, study: @study, sample: @sample
        end
        should 'not delegate to the study' do
          assert_accession_service(:unsuitable)
        end
      end
      context 'with one un-accessioned, never study' do
        setup do
          @sample = create :sample
          @study = create :not_app_study
          create :study_sample, study: @study, sample: @sample
        end
        should 'not delegate to the study' do
          assert_accession_service(:none)
        end
      end

      # We priorities the ega, as its the more conservative of the two
      # and it reduces the risk of accidentally making human data public
      context 'with an ena and an ega study' do
        setup do
          @sample = create :sample
          @study = create :open_study, accession_number: 'ENA123'
          @study_b = create :managed_study, accession_number: 'ENA123'
          create :study_sample, study: @study, sample: @sample
          create :study_sample, study: @study_b, sample: @sample
        end
        should 'delegate to the ega study' do
          assert_accession_service(:ega)
        end
      end

      context 'with an ena and an ega study in the other order' do
        setup do
          @sample = create :sample
          @study = create :open_study, accession_number: 'ENA123'
          @study_b = create :managed_study, accession_number: 'ENA123'
          create :study_sample, study: @study_b, sample: @sample
          create :study_sample, study: @study, sample: @sample
        end
        should 'still delegate to the ega study' do
          assert_accession_service(:ega)
        end
      end

      # We err on the side of caution here. Sending stuff to the ENA
      # could be an issue.
      context 'with an accessioned ena but un-accessioned ena' do
        setup do
          @sample = create :sample
          @study = create :open_study, accession_number: 'ENA123'
          @study_b = create :managed_study
          create :study_sample, study: @study_b, sample: @sample
          create :study_sample, study: @study, sample: @sample
        end
        should 'not delegate to either study' do
          assert_accession_service(:unsuitable)
        end
      end

    end

    context "accessioning" do

      attr_reader :metadata_with_an, :metadata_wo_an

      setup do
        create(:user, api_key: configatron.accession_local_key)
        @metadata_with_an = {sample_taxon_id: "1", sample_common_name: "A common name", sample_ebi_accession_number: "ENA123" }
        @metadata_wo_an = metadata_with_an.except(:sample_ebi_accession_number)
      end

      should 'proceed if the sample meets accessioning requirements' do
        assert create(:sample, studies: [create(:open_study)], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
      end

      should 'not proceed if the sample has already been accessioned' do

        refute create(:sample, studies: [create(:open_study, accession_number: 'ENA123')], sample_metadata: Sample::Metadata.new(metadata_with_an)).accessionable?
      end

      should 'not proceed if the sample metadata has no taxon and common name' do
        refute create(:sample, sample_metadata: Sample::Metadata.new(metadata_wo_an.except(:sample_taxon_id))).accessionable?
        refute create(:sample, sample_metadata: Sample::Metadata.new(metadata_wo_an.except(:sample_common_name))).accessionable?
      end

      should 'not proceed if the studies are not suitable' do
        open_study = create(:open_study)
        assert create(:sample, studies: [open_study], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
        assert create(:sample, studies: [create(:managed_study)], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
        refute create(:sample, studies: [create(:not_app_study)], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
        open_study.study_metadata.update_attributes(data_release_timing: Study::DATA_RELEASE_TIMING_NEVER, data_release_prevention_reason: 'data validity', data_release_prevention_approval: 'Yes', data_release_prevention_reason_comment: "blah, blah, blah") 
        refute create(:sample, studies: [open_study], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
      end

      should 'not proceed if the current user is not valid' do
        configatron.accession_local_key = nil
        refute create(:sample, studies: [create(:open_study)], sample_metadata: Sample::Metadata.new(metadata_wo_an)).accessionable?
        configatron.accession_local_key = "abc"
      end

      context 'delayed job' do

        setup do
          Delayed::Worker.delay_jobs = false
          WebMock.stub_request(:post, "#{configatron.accession_url}#{configatron.ena_accession_login}").to_return( {
            headers: {'Content-Type' => 'text/xml'},
            body: '<RECEIPT success="true"><SAMPLE accession="EGA00001000240" /></RECEIPT>',
            status: 200
          })
        end

        should 'succeed if the sample is acccessionable' do
          sample = create(:sample, studies: [create(:open_study, accession_number: 'ENA123')], sample_metadata: Sample::Metadata.new(metadata_wo_an))
          Delayed::Job.enqueue SampleAccessioningJob.new(sample)
          assert(sample.sample_metadata.sample_ebi_accession_number.present?)
        end

        should 'fail if the sample is not accessionable' do
          sample = create(:sample, studies: [create(:open_study)], sample_metadata: Sample::Metadata.new(metadata_wo_an.except(:sample_taxon_id)))
          Delayed::Job.enqueue SampleAccessioningJob.new(sample)
          refute(sample.sample_metadata.sample_ebi_accession_number.present?)
        end

        teardown do
          Delayed::Worker.delay_jobs = true
        end
      end

    end
  end

end
