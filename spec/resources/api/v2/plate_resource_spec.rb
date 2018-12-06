# frozen_string_literal: true

require 'rails_helper'
require './app/resources/api/v2/plate_resource'

RSpec.describe Api::V2::PlateResource, type: :resource do
  let(:resource_model) { create :plate, barcode: 11, well_count: 3 }
  subject(:resource) { described_class.new(resource_model, {}) }

  shared_examples 'a plate resource' do
    # Test attributes
    it { is_expected.to have_attribute :uuid }
    it { is_expected.to have_attribute :name }
    it { is_expected.to have_attribute :labware_barcode }
    it { is_expected.to have_attribute :state }
    it { is_expected.to have_attribute :number_of_rows }
    it { is_expected.to have_attribute :number_of_columns }
    it { is_expected.to have_attribute :created_at }

    # Read only attributes (almost certainly id, uuid)
    it { is_expected.to_not have_updatable_field(:id) }
    it { is_expected.to_not have_updatable_field(:uuid) }
    it { is_expected.to_not have_updatable_field(:name) }
    it { is_expected.to_not have_updatable_field(:labware_barcode) }
    it { is_expected.to_not have_updatable_field(:state) }
    it { is_expected.to_not have_updatable_field(:pools) }
    it { is_expected.to_not have_updatable_field(:created_at) }

    # Updatable fields
    # eg. it { is_expected.to have_updatable_field(:state) }

    # Filters
    # eg. it { is_expected.to filter(:order_type) }
    it { is_expected.to filter(:barcode) }
    it { is_expected.to filter(:uuid) }
    it { is_expected.to filter(:purpose_name) }
    it { is_expected.to filter(:purpose_id) }

    # Associations
    it { is_expected.to have_one(:purpose).with_class_name('Purpose') }

    it { is_expected.to have_many(:wells).with_class_name('Well') }
    it { is_expected.to have_many(:projects).with_class_name('Project') }
    it { is_expected.to have_many(:studies).with_class_name('Study') }

    it { is_expected.to have_many(:ancestors) }
    it { is_expected.to have_many(:descendants) }
    it { is_expected.to have_many(:parents) }
    it { is_expected.to have_many(:children) }

    # Custom method tests
    # Add tests for any custom methods you've added.
    describe '#labware_barcode' do
      subject { resource.labware_barcode }
      it { is_expected.to eq(expected_barcode_hash) }
    end
  end

  context 'on a plate' do
    let(:expected_barcode_hash) do
      { 'ean13_barcode' => '1220000011748', 'machine_barcode' => 'DN11J', 'human_barcode' => 'DN11J' }
    end
    it_behaves_like 'a plate resource'
  end
end
