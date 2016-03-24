#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2013,2014,2015 Genome Research Ltd.

class CherrypickForPulldownRequest < TransferRequest

  redefine_state_machine do
    # The statemachine for transfer requests is more promiscuous than normal requests, as well
    # as being more concise as it has less states.
    aasm_column :state
    aasm_state :pending
    aasm_state :started
    aasm_state :failed,     :enter => :on_failed
    aasm_state :passed
    aasm_state :cancelled,  :enter => :on_cancelled
    aasm_state :hold
    aasm_initial_state :pending

    aasm_event :hold do
      transitions :to => :hold, :from => [ :pending ]
    end

    # State Machine events
    aasm_event :start do
      transitions :to => :started, :from => [:pending,:hold]
    end

    aasm_event :pass do
      transitions :to => :passed, :from => [:pending, :started, :failed]
    end

    aasm_event :fail do
      transitions :to => :failed, :from => [:pending, :started, :passed]
    end

    aasm_event :cancel do
      transitions :to => :cancelled, :from => [:started, :passed]
    end

    aasm_event :cancel_before_started do
      transitions :to => :cancelled, :from => [:pending,:hold]
    end

    aasm_event :submission_cancelled do
      transitions :to => :cancelled, :from => [:pending, :cancelled]
    end

    aasm_event :detach do
      transitions :to => :pending, :from => [:pending, :cancelled]
    end
  end

  def on_failed
    # Do nothing
  end

  alias_method :on_cancelled, :on_failed

  def perform_transfer_of_contents
    on_started # Ensures we set the study/project
  end
  private :perform_transfer_of_contents

  after_create :build_stock_well_links

  def build_stock_well_links
    stock_wells = asset.plate.try(:plate_purpose).try(:can_be_considered_a_stock_plate?) ? [asset] : asset.stock_wells
    target_asset.stock_wells.attach!(stock_wells)
  end
  private :build_stock_well_links

end
