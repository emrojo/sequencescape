require 'spec_helper'

RSpec.describe Cherrypick::PlateLayout::PlateLayoutRenderer do
  let(:asset_shape) { create :asset_shape }
  let(:size) { 14 }
  let(:requests) { 7.times.map{|i| i } }
  let(:control_requests) { 2.times.map{|i| i } }
  let(:all_positions) { size.times.map{|i| i}}
  let(:control_positions) { [2,4] }
  let(:template_positions) { [12,13] }
  let(:partial_plate_positions) { [0,3,5]}
  let(:requests_positions) { all_positions - control_positions - template_positions - partial_plate_positions }
  let(:params) { {
      size: 96,
      shape: asset_shape,
      requests: requests,
      requests_positions: requests_positions,
    }
  }
  context '#initialize' do
    it 'can instantiate a plate layout' do
      expect{Cherrypick::PlateLayout::PlateLayoutRenderer.new}.not_to raise_error
    end
  end

  context '#valid?' do
    it 'is valid with the right params' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params)).to be_valid
    end

    it 'is not valid without requests' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:requests))).to be_invalid
    end
    it 'is not valid without size' do      
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:size))).to be_invalid
    end
    it 'is not valid without requests_positions' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:requests_positions))).to be_invalid
    end

    context 'when defining controls' do
      it 'is not valid if missing control params needed' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
        }))).to be_invalid
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is valid if contains all control params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_valid
      end
      it 'is not valid if there are requests without a position declared' do
        control_positions.pop
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is not valid if plate does not have enough wells for controls and requests' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          size: 2,
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is not valid if controls positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

    context 'when defining template params' do      
      it 'is valid with the right template params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          template_positions: template_positions
        }))).to be_valid        
      end

      it 'is not valid if template positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          template_positions: template_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

    context 'when defining partial_plate params' do

      it 'is valid with the right template params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          partial_plate_positions: partial_plate_positions
        }))).to be_valid        
      end

      it 'is not valid if partial plate positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          partial_plate_positions: partial_plate_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

  end

end