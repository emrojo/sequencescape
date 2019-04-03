# A {Task} used in {PacBioSequencingPipeline}
# Assigns a binding kit barcode to the {PacBioLibraryTube}
#
# @note At time of writing (3/4/2019) this is used in:
#   "PacBio Sequencing"
#
# @see Tasks::BindingKitBarcodeHandler for behaviour included in the {WorkflowsController}
class BindingKitBarcodeTask < Task
  class BindingKitBarcodeData < Task::RenderElement
    def initialize(request)
      super(request)
    end
  end

  def create_render_element(request)
    request.asset && BindingKitBarcodeData.new(request)
  end

  def partial
    'binding_kit_barcode_batches'
  end

  def render_task(workflow, params)
    super
    workflow.render_binding_kit_barcode_task(self, params)
  end

  def do_task(workflow, params)
    workflow.do_binding_kit_barcode_task(self, params)
  end
end
