#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012,2013,2014 Genome Research Ltd.
Sequencescape::Application.routes.draw do
  resources :reference_genomes
  resources :barcode_printers
  resources :robot_verifications do
    collection do
  # postget :submission
  post :download
  end


  end

  resources :projects do


      resources :billing_events
  end

  match 'assets/:id/pass_qc_state' => 'npg_actions/assets#pass', :as => :pass_qc_state, :path_prefix => '/npg_actions', :via => 'post'
  match 'assets/:id/fail_qc_state' => 'npg_actions/assets#fail', :as => :fail_qc_state, :path_prefix => '/npg_actions', :via => ''
  resources :items
  resources :batches do


      resources :requests
    resources :comments
  end

  match 'pipelines/release/:id' => 'pipelines#release', :as => :release_batch
  match 'pipelines/finish/:id' => 'pipelines#finish', :as => :finish_batch
  match 'run/:run' => 'items#run_lanes'
  match 'run/:run.json' => 'items#run_lanes', :format => 'json'
  match 'run/:run.xml' => 'items#run_lanes', :format => 'xml'
  match '/login' => 'sessions#login', :as => :login
  match '/logout' => 'sessions#logout', :as => :logout
  resources :events
  resources :sources
  resources :samples do

    member do
  get :history
  end

  end

  resources :samples do


      resources :comments
    resources :studies
  end

  match '/taxon_lookup_by_term/:term' => 'samples#taxon_lookup'
  match '/taxon_lookup_by_id/:id' => 'samples#taxon_lookup'
  match '/studies/:study_id/workflows/:workflow_id/summary_detailed/:id' => 'studies/workflows#summary_detailed'
  match 'studies/accession/:id' => 'studies#accession'
  match 'studies/policy_accession/:id' => 'studies#policy_accession'
  match 'studies/dac_accession/:id' => 'studies#dac_accession'
  match 'studies/accession/show/:id' => 'studies#show_accession', :as => :study_show_accession
  match 'studies/accession/dac/show/:id' => 'studies#show_dac_accession', :as => :study_show_dac_accession
  match 'studies/accession/policy/show/:id' => 'studies#show_policy_accession', :as => :study_show_policy_accession
  match 'samples/accession/:id' => 'samples#accession'
  match 'samples/accession/show/:id' => 'samples#show_accession'
  match 'samples/destroy/:id' => 'samples#destroy', :as => :destroy_sample
  match 'samples/accession/show/:id' => 'samples#show_accession', :as => :sample_show_accession
  match '/taxon_lookup_by_term/:term' => 'samples#taxon_lookup'
  match '/taxon_lookup_by_id/:id' => 'samples#taxon_lookup'
  resources :studies do


    resources :sample_registration do
      collection do
        post :new
        get :upload
      end
    end

    resources :samples
    resources :events
    resources :requests do

        member do
    post :reset
    get :cancel
    end

    end

    resources :comments
    resources :asset_groups do

        member do
    post :search
    post :add
    get :print
    post :print_labels
    get :printing
    end

    end

    resources :plates do


          resources :wells
    end

    resources :workflows do


          resources :assets do
            collection do
      post :print
      end


      end
    end

    resources :documents
  end

  match 'bulk_submissions' => 'bulk_submissions#new'
  resources :submissions do
    collection do
  get :study_assets
  get :order_fields
  get :project_details
  end


  end

  resources :orders
  resources :documents
  match 'requests/:id/change_decision' => 'requests#filter_change_decision', :as => :filter_change_decision_request, :via => 'get'
  match 'requests/:id/change_decision' => 'requests#change_decision', :as => :change_decision_request, :via => 'put'
  resources :requests do


      resources :comments
  end

  resources :items do


      resource :request
  end

  match 'studies/:study_id/workflows/:id' => 'study_workflows#show', :as => :study_workflow_status
  resources :searches
  match 'admin' => 'admin#index', :as => :admin
  resources :custom_texts
  resources :settings do
    collection do
  get :reset
  get :apply
  end


  end

  resources :studies do
    collection do
  get :index
  post :filer
  end
    member do
  put :managed_update
  end

  end

  resources :projects do
    collection do
  get :index
  post :filer
  end
    member do
  put :managed_update
  end

  end

  resources :plate_purposes
  resources :delayed_jobs
  resources :faculty_sponsors
  resources :delayed_jobs
  resources :users do
    collection do
  post :filter
  end
    member do
  get :switch
  post :grant_user_role
  post :remove_user_role
  end

  end

  resources :profile do

    member do
  get :study_reports
  get :projects
  end

  end

  resources :roles do


      resources :users
  end

  resources :robots
  resources :bait_libraries
  resources :bait_library_types
  resources :bait_library_suppliers
  resources :verifications do
    collection do
  get :input
  post :verify
  end


  end

  resources :plate_templates
  match 'implements/print_labels' => 'implements#print_labels'
  resources :implements
  resources :pico_sets do
    collection do
  get :create_from_stock
  end
    member do
  get :analyze
  post :score
  get :normalise_plate
  end

  end

  resources :gels do
    collection do
  post :lookup
  get :find
  end
    member do
  get :show
  post :update
  end

  end

  resources :locations
  resources :request_information_types
  match '/logout' => 'sessions#logout', :as => :logout
  match '/login' => 'sessions#login', :as => :login
  match 'pipelines/assets/new/:id' => 'pipelines/assets#new', :via => 'get'
  resources :pipelines do
    collection do
  post :update_priority
  end
    member do
  get :reception
  get :show_comments
  end

  end

  resource :search
  resources :errors
  resources :events
  match 'batches/all' => 'batches#all'
  match 'batches/released' => 'batches#released'
  match 'batches/released/clusters' => 'batches#released'
  resources :items do
    collection do
  get :samples_for_autocomplete
  end


  end

  match 'workflows/refresh_sample_list' => 'workflows#refresh_sample_list'
  resources :workflows
  resources :tasks
  resources :asset_audits
  match 'assets/snp_import' => 'assets#snp_import'
  match 'assets/lookup' => 'assets#lookup', :as => :assets_lookup
  match 'assets/receive_barcode' => 'assets#receive_barcode'
  match 'assets/import_from_snp' => 'assets#import_from_snp'
  match 'assets/confirm_reception' => 'assets#confirm_reception'
  match 'assets/combine' => 'assets#combine'
  match 'assets/get_plate_layout' => 'assets#get_plate_layout'
  match 'assets/create_plate_layout' => 'assets#create_plate_layout'
  match 'assets/make_plate_from_rack' => 'assets#make_plate_from_rack'
  match 'assets/find_by_barcode' => 'assets#find_by_barcode', :as => :controller
  match 'lab_view' => 'assets#lab_view', :as => :lab_view
  resources :families
  resources :tag_groups do


      resources :tags
  end

  resources :assets do


      resources :comments
  end

  resources :plates do
    collection do
  post :upload_pico_results
  post :create
  get :to_sample_tubes
  post :create_sample_tubes
  end


  end

  resources :pico_set_results do
    collection do
  post :upload_pico_results
  post :create
  end


  end

  resources :receptions do
    collection do
  get :snp_register
  get :reception
  get :snp_import
  get :receive_snp_barcode
  end


  end

  match 'sequenom/index' => 'sequenom#index', :as => :sequenom_root, :via => 'get'
  match 'sequenom/search' => 'sequenom#search', :as => :sequenom_search, :via => 'post'
  match 'sequenom/:id' => 'sequenom#show', :as => :sequenom_plate, :constraints => 'id(?-mix:\d+)', :via => 'get'
  match 'sequenom/:id' => 'sequenom#update', :as => :sequenom_update, :constraints => 'id(?-mix:\d+)', :via => 'put'
  match 'sequenom/quick' => 'sequenom#quick_update', :as => :sequenom_quick_update, :via => 'post'
  resources :sequenom_qc_plates
  resources :pico_dilutions
  resources :study_reports
  resources :sample_logistics do
    collection do
  get :lab
  get :qc_overview
  end


  end

  match '/' => 'studies#index'
  match 'asset_audits' => 'api/asset_audits#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'asset_links' => 'api/asset_links#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'batch_requests' => 'api/batch_requests#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'batches' => 'api/batches#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'billing_events' => 'api/billing_events#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'events' => 'api/events#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'lanes' => 'api/lanes#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'library_tubes' => 'api/library_tubes#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'multiplexed_library_tubes' => 'api/multiplexed_library_tubes#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'pulldown_multiplexed_library_tubes' => 'api/pulldown_multiplexed_library_tubes#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'plate_purposes' => 'api/plate_purposes#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'plates' => 'api/plates#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'sample_tubes' => 'api/sample_tubes#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'study_samples' => 'api/study_samples#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'submissions' => 'api/submissions#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'orders' => 'api/orders#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'tags' => 'api/tags#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'wells' => 'api/wells#index', :as => :asset, :path_prefix => '/1', :read_only => 'true'
  match 'aliquots' => 'api/aliquots#index', :as => :model, :path_prefix => '/1', :read_only => 'true'
  match 'projects' => 'api/projects#index', :as => :model, :path_prefix => '/1', :read_only => 'false'
  match 'requests' => 'api/requests#index', :as => :model, :path_prefix => '/1', :read_only => 'false'
  match 'samples' => 'api/samples#index', :as => :model, :path_prefix => '/1', :read_only => 'false'
  match 'studies' => 'api/studies#index', :as => :model, :path_prefix => '/1', :read_only => 'false'
  resources :sample_manifests do
    collection do
  post :upload
  end
    member do
  get :export
  get :uploaded_spreadsheet
  end

  end

  resources :suppliers do

    member do
  get :sample_manifests
  get :studies
  end

  end

  match '/' => 'home#index', :namespace => 'sdb/', :path_prefix => '/sdb'
  match '/:controller(/:action(/:id))'
end
