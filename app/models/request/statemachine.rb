# This is a module containing the standard statemachine for a request that needs it.
# It provides various callbacks that can be hooked in to by the derived classes.
module Request::Statemachine
  COMPLETED_STATE = [ 'passed', 'failed' ]
  OPENED_STATE    = [ 'pending', 'blocked', 'started' ]
  QUOTA_COUNTED   = [ 'passed', 'pending', 'blocked', 'started' ]
  QUOTA_EXEMPTED  = [ 'failed', 'cancelled', 'aborted' ]

  def self.included(base)
    base.class_eval do
      include Request::BillingStrategy


      ## State machine
      state_machine :initial => :pending do
        event :hold do
          transition :to => :hold, :from => [ :pending ]
        end

        # State Machine events
        event :start do
          transition :to => :started, :from => [:pending, :started, :hold]
        end

        event :pass do
          transition :to => :passed, :from => [:passed, :pending, :started, :failed]
        end

        event :fail do
          transition :to => :failed, :from => [:pending, :failed]
          transition :to => :failed, :from => [:started]
          transition :to => :failed, :from => [:passed]
        end

        event :block do
          transition :to => :blocked, :from => [:pending]
        end

        event :unblock do
          transition :to => :pending, :from => [:blocked]
        end

        event :detach do
          transition :to => :pending, :from => [:cancelled, :started, :pending]
        end

        event :reset do
          transition :to => :pending, :from => [:started, :pending, :passed, :failed, :hold]
        end

        event :cancel do
          transition :to => :cancelled, :from => [:started, :pending, :passed, :failed, :hold]
        end

        after_transition all => :started,   :do => :on_started

        after_transition :started => :failed,    :do => :charge_internally
        after_transition :passed  => :failed,    :do => :refund_project
        after_transition      all => :failed,    :do => :on_failed

        after_transition [:started, :failed] => :passed,    :do => :charge_to_project
        after_transition                 all => :passed,    :do => :on_passed

        after_transition all => :cancelled, :do => :on_cancelled
        after_transition all => :blocked,   :do => :on_blocked
        after_transition all => :hold,      :do => :on_hold
      end

      after_save :release_unneeded_quotas!

      # new version of combinable named_scope
      named_scope :for_state, lambda { |state| { :conditions => { :state => state } } }

      named_scope :completed, :conditions => {:state => COMPLETED_STATE}
      named_scope :passed, :conditions => {:state => "passed"}
      named_scope :failed, :conditions => {:state => "failed"}
      named_scope :pipeline_pending, :conditions => {:state => "pending"} #  we don't want the blocked one here
      named_scope :pending, :conditions => {:state => ["pending", "blocked"]} # block is a kind of substate of pending

      named_scope :started, :conditions => {:state => "started"}
      named_scope :cancelled, :conditions => {:state => "cancelled"}
      named_scope :aborted, :conditions => {:state => "aborted"}

      named_scope :open, :conditions => {:state => OPENED_STATE}
      named_scope :closed, :conditions => {:state => ["passed", "failed", "cancelled", "aborted"]}
      named_scope :quota_counted, :conditions => {:state => QUOTA_COUNTED}
      named_scope :quota_exempted, :conditions => {:state => QUOTA_EXEMPTED}
      named_scope :hold, :conditions => {:state => "hold"}
    end
  end

  #--
  # These are the callbacks that will be made on entry to a given state.  This allows
  # derived classes to override these and add custom behaviour.  You are advised to call
  # super in any method that you override so that they can be stacked.
  #++

  # On starting a request the aliquots are copied from the source asset to the target 
  # and updated with the project and study information from the request itself.
  def on_started
    target_asset.aliquots << asset.aliquots.map do |aliquot|
      aliquot.clone.tap do |clone|
        clone.study_id   = initial_study_id   || aliquot.study_id
        clone.project_id = initial_project_id || aliquot.project_id
      end
    end
  end

  def on_failed

  end

  def release_unneeded_quotas!
    self.request_quotas(true).destroy_all unless quota_counted?
  end

  def on_passed

  end

  def on_cancelled

  end

  def on_blocked

  end

  def on_hold

  end

  def quota_counted?
    return QUOTA_COUNTED.include?(state)
  end

  def finished?
    self.passed? || self.failed?
  end

  def closed?
    ["passed", "failed", "cancelled", "aborted"].include?(self.state)
  end

  def open?
    ["pending", "started"].include?(self.state)
  end
end
