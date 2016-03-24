#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2013,2014,2015 Genome Research Ltd.


require 'aasm'

module Submission::StateMachine
  def self.extended(base)
    base.class_eval do
      include AASM
      include InstanceMethods

      configure_state_machine
      configure_named_scopes

      def editable?
        state=="building"
      end

    end
  end

  module InstanceMethods
    # TODO[xxx]: This should be a guard but what the heck ...
    def left_building_state?
      not self.building? or !!@leaving_building_state
    end

    def valid_for_leaving_building_state
      @leaving_building_state = true
      raise ActiveRecord::RecordInvalid, self unless valid?
    ensure
      @leaving_building_state = false
    end
    # TODO[xxx]: ... to here

    def complete_building
      orders(true).each(&:complete_building)
    end

    def process_submission!
      # Does nothing by default!
    end

    def process_callbacks!
      callbacks.each do |_,callback|
        callback.call
      end
    end

    def callbacks
      @callbacks ||= {}
    end

    def register_callback(key=nil,&block)
      key ||= "k#{@callbacks.size}"
      callbacks[key] = block
    end

    def unprocessed?
      UnprocessedStates.include?(state)
    end

    def cancellable?
      (pending? || ready?) && requests_cancellable?
    end

    def requests_cancellable?
      # Default behaviour, overidden in the model itself
      false
    end

    def broadcast_events
      orders.each(&:generate_broadcast_event)
    end
  end

  def configure_state_machine
    aasm_column :state
    aasm_initial_state :building
    aasm_state :building, :exit => :valid_for_leaving_building_state
    aasm_state :pending, :enter => :complete_building
    aasm_state :processing, :enter => :process_submission!, :exit => :process_callbacks!
    aasm_state :ready, :enter => :broadcast_events
    aasm_state :failed
    aasm_state :cancelled, :enter => :cancel_all_requests

    aasm_event :built do
      transitions :to => :pending, :from => [ :building ]
    end

    aasm_event :cancel do
      transitions :to => :cancelled, :from => [ :pending, :ready, :cancelled ], :guard => :requests_cancellable?
    end

    aasm_event :process do
      transitions :to => :processing, :from => [:processing, :failed, :pending]
    end

    aasm_event :ready do
      transitions :to => :ready, :from => [:processing, :failed]
    end

    aasm_event :fail do
      transitions :to => :failed, :from => [:processing, :failed, :pending]
    end
  end
  private :configure_state_machine

  UnprocessedStates = ["building", "pending", "processing"]
  def configure_named_scopes
   scope :unprocessed, -> { where(:state => UnprocessedStates) }
   scope :processed, -> { where(:state => ["ready", "failed"]) }
  end

  private :configure_named_scopes
end
