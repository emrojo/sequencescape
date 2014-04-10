class BatchSubmenuPresenter
  attr_reader :options
  
  
  private
  
  def add_submenu_option_params(text, actionParams, tags=[])
    actionConfig = @defaults.dup
    actionParams.keys.each do |key, value|
       actionConfig[key] = value
    end
    @options += [{:label => text, :params => actionConfig, :tags => tags}]    
  end
  
  def prepare_list
    if @options == nil
      @options = Array.new
    end    
  end

  def set_defaults(defaults)
    @defaults=defaults
  end


  
  public
  
  def add_submenu_option_with_builder_url (text, builder, params_builder, tags=[])
    prepare_list
    
    @options += [{:label => text, :url_builder => builder, :url_params_builder => params_builder, :tags => tags}]
  end
  
  def add_submenu_option(text, actionParams, tags=[])    
    prepare_list
    
    if actionParams.is_a?(String)
      @options += [{:label => text, :url =>  actionParams, :tags => tags}]
    else
      if actionParams.is_a?(Symbol)
        actionParams = { :action => actionParams }
      end
      add_submenu_option_params(text, actionParams, tags)
    end
  end

  def to_s
    @options.each {|option| "#{option},"}
  end


 
  
  def initialize(current_user, batch)
    @current_user = current_user
    @batch = batch
    @pipeline = batch.pipeline

    set_defaults({:controller => :batches, :id => @batch.id})
      
    build_submenu
  end
  
  def build_submenu
    add_submenu_option "View summary", { :controller => :pipelines, :action => :summary }
    add_submenu_option_with_builder_url "comment", :batch_comments_path, [@batch], [:pluralize => @batch.comments.size]
    unless @current_user.is_owner? && ! @current_user.is_manager?
      add_submenu_option_with_builder_url "Edit batch", :edit_batch_path, [@batch]
      load_pipeline_options
    end
    add_submenu_option "NPG run data", "#{configatron.run_data_by_batch_id_url}#{@batch.id}" 
    add_submenu_option "SybrGreen images", "#{configatron.sybr_green_images_url}#{@batch.id}" 
  end
  
  def load_pipeline_options
    if  @pipeline.is_a?(PulldownMultiplexLibraryPreparationPipeline)
      add_submenu_option "Print labels", :print_labels
    elsif @batch.multiplexed?
      add_submenu_option "Print pool label", :print_multiplex_labels
      add_submenu_option "Print labels" ,  :print_labels
      add_submenu_option "Print stock pool label" , :print_stock_multiplex_labels
    elsif @pipeline.is_a?(CherrypickingPipeline) || @pipeline.is_a?(GenotypingPipeline) || @pipeline.is_a?(PacBioSequencingPipeline) 
      add_submenu_option "Print plate labels" , :print_plate_labels
    elsif (!@pipeline.is_a?(SequencingPipeline)) 
       if @batch.pipeline.can_create_stock_assets? 
         add_submenu_option "Print stock labels" , :print_stock_labels
       end 
       add_submenu_option "Print labels" , :print_labels
     end 
     unless @pipeline.is_a?(SequencingPipeline) 
       add_submenu_option "Vol' & Conc'", :edit_volume_and_concentration
     end 
     if @batch.pipeline.can_create_stock_assets? 
       add_submenu_option "Create stock tubes"  , :new_stock_assets
     end 
  
     if @pipeline.is_a?(PacBioSamplePrepPipeline) 
         add_submenu_option "Print worksheet" , :sample_prep_worksheet
     elsif @pipeline.prints_a_worksheet_per_task? 
       @tasks.each do |task| 
         add_submenu_option "Print worksheet for #{task.name}" , {:action => :print, :task_id => task.id} 
       end 
     else 
       add_submenu_option "Print worksheet" , :print 
     end 
  
     if @batch.has_limit? 
       unless @batch.has_event("Tube layout verified") 
         add_submenu_option "Verify tube layout" , :verify 
       end 
     end 
    
     if @pipeline.is_a?(PulldownMultiplexLibraryPreparationPipeline) 
       add_submenu_option "Batch Report", :pulldown_batch_report 
     end
  end
end