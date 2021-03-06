# frozen_string_literal: true

require 'rails_helper'
require 'support/barcode_helper'
require_relative 'shared_examples'

describe '/api/1/plate-uuid/submission_pools' do
  let(:authorised_app) { create :api_application }
  let(:uuid) { plate.uuid }
  let(:custom_metadata_uuid) { collection.uuid }
  let(:purpose_uuid) { '00000000-1111-2222-3333-666666666666' }
  let(:submission) { create :submission }
  let(:tag2_layout_template) { create :tag2_layout_template }
  let(:tag_layout_template) { create :tag_layout_template }

  context '#get' do
    subject { '/api/1/' + uuid + '/submission_pools' }
    let(:response_code) { 200 }

    context 'a plate without submissions' do
      let(:plate) { create :plate }
      let(:response_body) do
        %({
          "actions": {
            "read": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
             "first": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
             "last": "http://www.example.com/api/1/#{uuid}/submission_pools/1"
           },
           "size": 0,
           "submission_pools": []
       })
      end
      it_behaves_like 'an API/1 GET endpoint'
    end

    context 'a submission and a used tag 2 template' do
      let(:plate) { create :input_plate, well_count: 2 }

      before do
        plate.wells.each do |well|
          create :library_creation_request, asset: well, submission: submission
        end
        create :tag2_layout_template_submission, submission: submission, tag2_layout_template: tag2_layout_template
      end

      let(:response_body) do
        %({
            "actions": {
              "read": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "first": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "last": "http://www.example.com/api/1/#{uuid}/submission_pools/1"
            },
            "size":1,
            "submission_pools":[{
              "plates_in_submission":1,
              "used_tag2_layout_templates":[{"uuid":"#{tag2_layout_template.uuid}","name":"#{tag2_layout_template.name}"}],
              "used_tag_layout_templates":[]
           }]
       })
      end
      it_behaves_like 'an API/1 GET endpoint'
    end

    context 'a submission and a used tag template' do
      let(:plate) { create :input_plate, well_count: 2 }

      before do
        plate.wells.each do |well|
          create :library_creation_request, asset: well, submission: submission
        end
        create :tag_layout_template_submission, submission: submission, tag_layout_template: tag_layout_template
      end

      let(:response_body) do
        %({
            "actions": {
              "read": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "first": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "last": "http://www.example.com/api/1/#{uuid}/submission_pools/1"
            },
            "size":1,
            "submission_pools":[{
              "plates_in_submission":1,
              "used_tag2_layout_templates":[],
              "used_tag_layout_templates":[{"uuid":"#{tag_layout_template.uuid}","name":"#{tag_layout_template.name}"}]
           }]
       })
      end
      it_behaves_like 'an API/1 GET endpoint'
    end

    context 'a multi plate submission' do
      let(:plate) { create :input_plate, well_count: 2 }
      let(:plate_b) { create :input_plate, well_count: 2 }

      before do
        plate.wells.each do |well|
          create :library_creation_request, asset: well, submission: submission
        end
        plate_b.wells.each do |well|
          create :library_creation_request, asset: well, submission: submission
        end
      end

      let(:response_body) do
        %({
            "actions":{
              "read": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "first": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "last": "http://www.example.com/api/1/#{uuid}/submission_pools/1"
            },
           "size":1,
           "submission_pools":[{
              "plates_in_submission":2,
              "used_tag2_layout_templates":[],
              "used_tag_layout_templates":[]
           }]
       })
      end
      it_behaves_like 'an API/1 GET endpoint'
    end

    context 'a multi plate submission and a used template on children' do
      let(:plate_b) { create :input_plate, well_count: 2 }
      let(:plate) { create :plate, well_count: 2, parents: [plate_b] }

      before do
        plate_b.wells.each do |well|
          create :library_creation_request, asset: well, submission: submission
        end
        create :tag2_layout_template_submission, submission: submission, tag2_layout_template: tag2_layout_template
      end

      let(:response_body) do
        %({
            "actions":{
              "read": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "first": "http://www.example.com/api/1/#{uuid}/submission_pools/1",
              "last": "http://www.example.com/api/1/#{uuid}/submission_pools/1"
            },
           "size":1,
           "submission_pools":[{
              "plates_in_submission":1,
              "used_tag2_layout_templates":[],
              "used_tag_layout_templates":[]
           }]
       })
      end
      it_behaves_like 'an API/1 GET endpoint'
    end
  end
end
