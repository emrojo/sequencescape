
Given /^I have a "([^"]*)" submission with plate "([^"]*)"$/ do |submission_template_name, plate_barcode|
  project = FactoryBot.create :project
  study = FactoryBot.create :study
  plate = Plate.find_from_barcode('DN' + plate_barcode)

  # Maintain the order of the wells as though they have been submitted by the user, rather than
  # relying on the ordering within sequencescape.  Some of the plates are created with less than
  # the total wells needed (which is bad).
  wells = []
  plate.wells.walk_in_column_major_order { |well, _| wells << well }
  wells.compact!

  submission_template = SubmissionTemplate.find_by(name: submission_template_name)
  order = submission_template.create_and_build_submission!(
    study: study,
    project: project,
    user: User.last,
    assets: wells,
    request_options: { :multiplier => { '1' => '1', '3' => '1' }, 'read_length' => '100', 'fragment_size_required_to' => '300', 'fragment_size_required_from' => '250', 'library_type' => 'Illumina cDNA protocol' }
  )
  step('1 pending delayed jobs are processed')
end

Given /^I have a cherrypicking submission for plate "([^"]*)"$/ do |plate_barcode|
  project = FactoryBot.create :project
  study = FactoryBot.create :study
  plate = Plate.find_by(barcode: plate_barcode)

  submission_template = SubmissionTemplate.find_by(name: 'Cherrypick')
  submission = submission_template.create_and_build_submission!(
    study: study,
    project: project,
    user: User.last,
    assets: plate.wells
  )
  step('1 pending delayed jobs are processed')
end
