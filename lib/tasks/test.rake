namespace :test do
  # lib/tasks/factory_girl.rake
  namespace :factory_girl do
    desc 'Verify that all FactoryGirl factories are valid'
    task lint: :environment do
      require 'factory_girl'
      require File.expand_path(File.join(Rails.root, %w{test factories.rb}))
      Dir.glob(File.expand_path(File.join(Rails.root, %w{test factories ** *.rb}))) do |factory_filename|
       require factory_filename
      end
      Dir.glob(File.expand_path(File.join(Rails.root, %w{test lib sample_manifest_excel factories ** *.rb}))) do |factory_filename|
       require factory_filename
      end

      if Rails.env.test?

        # All these factories should be updated to make them valid
        # Any tests which break as a result should be fixed.
        invalid_factories = [
          :comment,
          :aliquot,
          :tagged_aliquot,
          :untagged_aliquot,
          :single_tagged_aliquot,
          :dual_tagged_aliquot,
          :report,
          :request_metadata_for_standard_sequencing_with_read_length,
          :sample_submission,
          :search,
          :section,
          :sequence,
          :setting,
          :multiplexed_library_tube,
          :stock_multiplexed_library_tube,
          :transfer_request,
          :full_multiplexed_library_tube,
          :broken_multiplexed_library_tube,
          :tube_sample_manifest_with_samples,
          :uuid,
          :barcode_printer_type,
          :plate_creator_purpose,
          :sequenom_qc_plate,
          :task,
          :lab_workflow,
          :delayed_message,
          :request_information,
          :pico_set,
          :asset_link,
          :gel_qc_task,
          :cherrypick_task,
          :assign_plate_purpose_task,
          :plate_barcode,
          :product_product_catalogue,
          :pooling_plate,
          :transfer_template,
          :pooling_transfer_template,
          :multiplex_transfer_template,
          :tag_layout_template,
          :inverted_tag_layout_template,
          :entire_plate_tag_layout_template,
          :tag_layout,
          :parent_plate_purpose,
          :pooling_plate_purpose,
          :child_plate_purpose,
          :initial_downstream_plate_purpose,
          :plate_creation,
          :child_tube_purpose,
          :tube_creation,
          :bait_library_supplier,
          :bait_library_type,
          :bait_library,
          :pulldown_sc_request,
          :request_with_submission,
          :sequencing_request,
          :multiplex_request,
          :illumina_htp_requests_std_library_request_metadata,
          :request_without_assets,
          :request_without_item,
          :multiplex_request_type,
          :library_types_request_type,
          :sequencing_request_type_validator,
          :library_request_type_validator,
          :submission__,
          :order_with_submission,
          :library_submission,
          :user_query,
          :tag2_lot
        ]

        factories_to_lint = if ENV.fetch('LINT_ALL', false)
                              FactoryGirl.factories
                            else
                              FactoryGirl.factories.reject do |factory|
                                invalid_factories.include?(factory.name)
                              end
                            end
        begin
          DatabaseCleaner.start
          puts "Linting #{factories_to_lint.length} factories. (Ignored #{invalid_factories.length})"
          FactoryGirl.lint factories_to_lint
          puts 'Linted'
        ensure
          DatabaseCleaner.clean
        end

      else
        system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
      end
    end
  end
end

task test: 'test:factory_girl:lint'
