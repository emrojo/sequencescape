
require 'test_helper'

class AssetLinkTest < ActiveSupport::TestCase
  context 'AssetLink::Job' do
    setup do
      @source_well      = create :well
      @destination_well = create :well
      @job_count = Delayed::Job.count
      AssetLink::Job.create(@source_well, [@destination_well])
    end

    should 'create a job' do
      assert_equal 1, Delayed::Job.count - @job_count
    end

    context 'When processed' do
      setup do
        Delayed::Worker.new.work_off
      end

      should 'create a link' do
        assert_includes @destination_well.reload.parents, @source_well
      end

      should 'remove the job from the queue' do
        assert_equal 0, Delayed::Job.count - @job_count
      end
    end
  end
end
