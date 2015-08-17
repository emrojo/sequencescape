  configatron.amqp.url = "amqp://localhost:5672"
  configatron.amqp.persistent = false
  configatron.amqp.burst_size = 1000
  configatron.amqp.lims_id = "SQSCP"
  configatron.accession_login = "accession_login"
  configatron.accession_url = "http://localhost:9999/accession_service/"
  configatron.accession_view_url = "http://localhost:9999/view_accession/"
  configatron.admin_email = "admin@test.com"
  configatron.exception_recipients = "exceptions@test.com"
  configatron.api_documentation_url = "http://localhost:3000/documentation"
  configatron.api_url = "http://localhost:3000"
  configatron.array_express_accession_login = nil
  configatron.auth_cookie = nil
  configatron.authentication = "local"
  configatron.barcode_service_url = "http://localhost:9998/barcode_service.wsdl"
  configatron.default_policy_text = "https://www.example.com/"
  configatron.default_policy_title = "Default Policy Title"
  configatron.fluidigm_data.source = "directory"
  configatron.fluidigm_data.directory = "#{Rails.root}/data/fluidigm"
  configatron.irods_audience = "http://localhost:3000"
  configatron.ega_accession_login = "ega_accession_login"
  configatron.era_accession_login = "era_accession_login"
  configatron.login_url = "/login"
  configatron.mail_prefix = "[DEVELOPMENT]"
  configatron.pac_bio_instrument_api = "http://example.com"
  configatron.pac_bio_smrt_portal_api = "http://example.com"
  configatron.phyx_tag.tag_group_name = "Control Tag Group 888"
  configatron.phyx_tag.tag_map_id = 888
  configatron.pico_green_url = "http://localhost:3003"
  configatron.r_and_d_division = "RandD"
  configatron.sanger_auth_service = "http://localhost:9999/cgi-bin/prodsoft/SSO/isAuth.pl"
  configatron.site_url = "localhost:3000"
  configatron.studies_url = "http://localhost:3000"
  configatron.sanger_auth_freshness = 60
  configatron.taxon_lookup_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
  configatron.tecan_files_location = "#{Rails.root}/data"

if Rails.env == 'development'

  configatron.asset_audits_url = "http://localhost:3014/process_plates/new"

  configatron.barcode_images_url = "http://localhost:10000"
  configatron.barcode_prefix = "CT"
  configatron.invalid_policy_url_domains = []

  configatron.delayed_job.study_report_priority = 100
  configatron.delayed_job.submission_process_priority = 0

  configatron.disable_accession_check = true
  configatron.disable_api_authentication = true
  # configatron.disable_web_proxy = true

  configatron.ldap_port = 13890
  configatron.ldap_secure_port = 6360
  configatron.ldap_server = "localhost"

  configatron.pipelines_url = "http://localhost:3000"

  configatron.plate_barcode_service = "http://localhost:3011"
  configatron.plate_volume_files = "#{Rails.root}/data/plate_volume/"

  configatron.proxy = "http://example.com"

  configatron.sanger_login_service = "http://localhost:9999/LOGIN"
  configatron.site_name = "Projects (DEVELOPMENT)"

  configatron.tecan_precision = 2
  configatron.tecan_minimum_volume = 1.0
  configatron.two_d_barcode_files_location = "#{Rails.root}/data/2d"
  configatron.uploaded_spreadsheet.max_number_of_samples = 384
  configatron.uploaded_spreadsheet.max_number_of_move_samples = 0
  configatron.xml_files_location = "#{Rails.root}/data/"
  configatron.data_sharing_contact.name = "John Doe"
  configatron.data_sharing_contact.email = "foo"
  configatron.accession_local_key = "abc"
  configatron.sequencescape_email = "sequencescape@example.com"
  configatron.default_email_domain = "example.com"
  configatron.run_information_url = "http://example.com/"
  configatron.sso_logout_url = "https://example.com/logout"
  configatron.run_data_by_batch_id_url = "http://example.com/search?query="
  configatron.sybr_green_images_url = "http://example.com/batches/"
  configatron.sequencing_admin_email = "admin@example.com"
  configatron.api.authorisation_code = "development"
  configatron.api.flush_response_at = 32768
end
if (Rails.env == 'test')||(Rails.env == 'cucumber')

  # configatron.asset_audits_url = NOT DEFINED

  configatron.barcode_images_url = "http://example.com/deliberately_broken_url"
  configatron.barcode_prefix = "NT"
  configatron.invalid_policy_url_domains = ["internal.example.com", "invalid.example.com"]

  # configatron.delayed_job.study_report_priority = 100
  # configatron.delayed_job.submission_process_priority = 0

  configatron.disable_accession_check = false
  configatron.disable_api_authentication = true
  configatron.disable_web_proxy = true

  configatron.ldap_port = 389
  configatron.ldap_secure_port = 636
  configatron.ldap_server = "ldap.internal.sanger.ac.uk"

  # configatron.pipelines_url = "http://localhost:3000"

  configatron.plate_barcode_service = "http://localhost:9998/plate_barcode_service/"
  configatron.plate_volume_files = "#{Rails.root}/test/data/plate_volume/"

  # configatron.proxy = "http://example.com"


  configatron.site_name = "Projects (TEST)"



  configatron.taxon_lookup_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
  configatron.tecan_files_location = "#{Rails.root}/data"
  configatron.tecan_precision = 1
  configatron.tecan_minimum_volume = 1.0
  configatron.uploaded_spreadsheet.max_number_of_samples = 380
  configatron.uploaded_spreadsheet.max_number_of_move_samples = 0

  configatron.data_sharing_contact.name = "John Doe"
  configatron.data_sharing_contact.email = "foo"
  configatron.accession_local_key = "abc"
  configatron.sequencescape_email = "sequencescape@example.com"
  configatron.default_email_domain = "example.com"
  configatron.run_information_url = "http://example.com/"
  configatron.sso_logout_url = "https://example.com/logout"
  configatron.run_data_by_batch_id_url = "http://example.com/search?query="
  configatron.sybr_green_images_url = "http://example.com/batches/"
  configatron.sequencing_admin_email = "admin@example.com"
  configatron.api.authorisation_code = "cucumber"
  configatron.api.flush_response_at = 32768
end
