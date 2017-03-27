require 'rails_helper'

RSpec.describe SampleManifestUploader, type: :model do

  before(:all) do
    SampleManifestExcel.configure do |config|
      config.folder = File.join('spec', 'data', 'sample_manifest_excel')
      config.tag_group = 'My Magic Tag Group'
      config.load!
    end
  end

  let(:test_file) { 'test_file.xlsx'}

  it 'will not be valid without a filename' do
    expect(SampleManifestUploader.new(nil, SampleManifestExcel.configuration)).to_not be_valid
  end

  it 'will not be valid without some configuration' do
    expect(SampleManifestUploader.new(test_file, nil)).to_not be_valid
  end

  it 'will not be valid without a tag group' do
    SampleManifestExcel.configuration.tag_group = nil
    expect(SampleManifestUploader.new(test_file, SampleManifestExcel.configuration)).to_not be_valid
  end

  it 'will upload a valid sample manifest' do
    download = build(:test_download, columns: SampleManifestExcel.configuration.columns.tube_library_with_tag_sequences.dup)
    download.save(test_file)
    uploader = SampleManifestUploader.new(test_file, SampleManifestExcel.configuration)
    uploader.run!
    expect(uploader.upload).to be_processed
  end

   it 'will not upload an invalid sample manifest' do
    download = build(:test_download, columns: SampleManifestExcel.configuration.columns.tube_library_with_tag_sequences.dup, manifest_type: 'multiplexed_library', validation_errors: [:tags])
    download.save(test_file)
    uploader = SampleManifestUploader.new(test_file, SampleManifestExcel.configuration)
    expect(uploader).to_not be_valid
    expect(uploader.errors).to_not be_empty
    expect(uploader.upload).to_not be_processed
  end

  after(:all) do
    SampleManifestExcel.reset!
  end
end