
class ControlRequest < CustomerRequest
  include Request::HasNoTargetAsset
  include Api::Messages::FlowcellIO::ControlLaneExtensions
end
