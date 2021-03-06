require 'test_helper'

class DummyTaskGroup
  attr_reader :params
  include Tasks::GenerateManifestHandler
  def initialize(params)
    @params = params
  end
end

class GenerateManifestTaskTest < ActiveSupport::TestCase
  context 'GenerateManifestHandler' do
    context '#generate_manifest_task' do
      context 'when obtaining a new manifest' do
        should 'filter incorrect characters' do
          @batch                = create :batch, id: 1
          @study                = create :study, name:           "Study name with any content:’'[](){}⟨⟩:,،、‒–—―…......!.‐-?‘’“”'';/⁄·&*@•^†" +
                                                                 '‡°″¡¿#№÷×ºª%‰+−=‱¶′″‴§~_|‖‗¦©℗®℠™¤₳฿₵¢₡₢$₫₯₠€ƒ₣₲₴₭₺ℳ₥₦₧₱₰£៛₽₹₨₪৳₸₮₩¥⁂❧☞‽⸮◊※' +
                                                                 '⁀and no more'
          @task = DummyTaskGroup.new(study_id: @study.id, batch_id: @batch.id)
          name = 'Study_name_with_any_content.......-_and_no_more_1_manifest.csv'
          assert_equal name, @task.manifest_filename(@study.name, @batch.id)
        end
      end
    end
  end
end
