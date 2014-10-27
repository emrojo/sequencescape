class RequestEvent < ActiveRecord::Base

  belongs_to :request

  validates :request, :presence => true, :to_state, :current_from, :event_name

  validates_inclusion_of :event_name, :in => ['created','state_changed','destroyed']

 scope :current, where( :current_to => nil )

  def expire!(date_time)
    raise StandardError, 'This event has already expired!' unless current_to.nil?
    self.update_attributes!(:current_to=>date_time)
  end

end
