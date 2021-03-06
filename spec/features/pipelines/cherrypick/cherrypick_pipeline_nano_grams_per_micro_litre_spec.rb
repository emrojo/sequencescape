# frozen_string_literal: true

require 'rails_helper'
require 'pry'

feature 'cherrypick pipeline - nano grams per micro litre', js: true do
  include FetchTable

  let(:user) { create :admin, barcode: 'ID41440E' }
  let(:project) { create :project, name: 'Test project' }
  let(:study) { create :study }
  let(:pipeline_name) { 'Cherrypick' }
  let(:pipeline) { Pipeline.find_by(name: pipeline_name) }
  let(:plate1) { create :plate_with_untagged_wells, well_order: :row_order, sample_count: 2, barcode: '1' }
  let(:plate2) { create :plate_with_untagged_wells, well_order: :row_order, sample_count: 2, barcode: '10' }
  let(:plate3) { create :plate_with_untagged_wells, well_order: :row_order, sample_count: 2, barcode: '5' }
  let(:plates) { [plate1, plate2, plate3] }
  let(:barcode) { 99999 }
  let(:robot) { create :robot, barcode: '444' }
  let!(:plate_template) { create :plate_template }

  before(:each) do
    assets = plates.each_with_object([]) do |plate, assets|
      assets.concat(plate.wells)
      plate.wells.each_with_index do |well, index|
        well.well_attribute.update_attributes!(
          current_volume: 30 + (index % 30),
          concentration: 205 + (index % 50)
        )
      end
    end
    submission_template_hash = {
      name: 'Cherrypick',
      submission_class_name: 'LinearSubmission',
      product_catalogue: 'Generic',
      submission_parameters: { info_differential: 6,
                               asset_input_methods: ['select an asset group', 'enter a list of sample names found on plates'],
                               request_types: ['cherrypick'] }
    }
    submission_template = SubmissionSerializer.construct!(submission_template_hash)
    submission = submission_template.create_and_build_submission!(
      study: study,
      project: project,
      user: user,
      assets: assets
    )
    Delayed::Worker.new.work_off
    # Make sure everything has built correctly, as otherwise downstream
    # failures are quite uninformative
    expect(submission.state).not_to eq('failed'), "Submission failed: #{submission.message}"

    stub_request(:post, "#{configatron.plate_barcode_service}plate_barcodes.xml").to_return(
      headers: { 'Content-Type' => 'text/xml' },
      body: "<plate_barcode><id>42</id><name>Barcode #{barcode}</name><barcode>#{barcode}</barcode></plate_barcode>"
    )

    robot.robot_properties.create(key: 'max_plates', value: '21')
    robot.robot_properties.create(key: 'SCRC1', value: '1')
    robot.robot_properties.create(key: 'SCRC2', value: '2')
    robot.robot_properties.create(key: 'SCRC3', value: '3')
    robot.robot_properties.create(key: 'DEST1', value: '20')

    create :plate_type, name: 'ABgene_0765', maximum_volume: 800
    create :plate_type, name: 'ABgene_0800', maximum_volume: 180
    create :plate_type, name: 'FluidX075', maximum_volume: 500
    create :plate_type, name: 'FluidX03', maximum_volume: 280
  end

  # from 6628187_tests_for_fix_tecan_volumes.feature
  # Feature: The Tecan file has the wrong buffer volumes, defaulting to 13 total volume
  scenario 'required volume is 65' do
    login_user(user)
    visit pipeline_path(pipeline)
    check('Select DN1S for batch')
    check('Select DN10I for batch')
    check('Select DN5W for batch')
    first(:select, 'action_on_requests').select('Create Batch')
    first(:button, 'Submit').click
    click_link 'Select Plate Template'
    select('testtemplate', from: 'Plate Template')
    select('Infinium 670k', from: 'Output plate purpose')
    fill_in('nano_grams_per_micro_litre_volume_required', with: '65')
    fill_in('nano_grams_per_micro_litre_robot_minimum_picking_volume', with: '1.0')
    click_button 'Next step'
    click_button 'Next step'
    click_button 'Release this batch'
    expect(page).to have_content('Batch released!')

    batch = Batch.last
    batch.update_attributes!(barcode: Barcode.number_to_human(550000555760))

    visit robot_verifications_path
    fill_in('Scan user ID', with: '2470041440697')
    fill_in('Scan Tecan robot', with: '4880000444853')
    fill_in('Scan worksheet', with: '550000555760')
    fill_in('Scan destination plate', with: '1220099999705')
    click_button 'Check'
    expect(page).to have_content('Scan robot beds and plates')

    table = [['Bed', 'Scanned robot beds', 'Plate ID', 'Scanned plates', 'Plate type'],
             ['SCRC 1', '', '1220000001831', '', 'ABgene_0765 ABgene_0800 FluidX075 FluidX03'],
             ['SCRC 2', '', '1220000010734', '', 'ABgene_0765 ABgene_0800 FluidX075 FluidX03'],
             ['SCRC 3', '', '1220000005877', '', 'ABgene_0765 ABgene_0800 FluidX075 FluidX03'],
             ['DEST 1', '', '1220099999705', '', 'ABgene_0800']]

    expect(fetch_table('table#source_beds')).to eq(table)

    fill_in('SCRC 1', with: '4880000001780')
    fill_in('1220000001831', with: '1220000001831')
    fill_in('SCRC 2', with: '4880000002794')
    fill_in('1220000005877', with: '1220000005877')
    fill_in('SCRC 3', with: '4880000003807')
    fill_in('1220000010734', with: '1220000010734')
    fill_in('DEST 1', with: '4880000020729')
    fill_in('1220099999705', with: '1220099999705')

    click_button 'Verify'
    click_link('Download TECAN file')
    # Tecan file generation is slow. Can probably be sped up, but for the moment...
    generated_file = DownloadHelpers.downloaded_file("#{batch.id}_batch_DN99999F.gwl")

    generated_lines = generated_file.lines
    generated_lines.shift(2)
    expect(generated_lines).to be_truthy
    tecan_file = <<~TECAN
      C;
      A;BUFF;;96-TROUGH;1;;49.1
      D;1220099999705;;ABgene 0800;1;;49.1
      W;
      A;BUFF;;96-TROUGH;2;;49.2
      D;1220099999705;;ABgene 0800;2;;49.2
      W;
      A;BUFF;;96-TROUGH;3;;49.1
      D;1220099999705;;ABgene 0800;3;;49.1
      W;
      A;BUFF;;96-TROUGH;4;;49.2
      D;1220099999705;;ABgene 0800;4;;49.2
      W;
      A;BUFF;;96-TROUGH;5;;49.1
      D;1220099999705;;ABgene 0800;5;;49.1
      W;
      A;BUFF;;96-TROUGH;6;;49.2
      D;1220099999705;;ABgene 0800;6;;49.2
      W;
      C;
      A;1220000001831;;ABgene 0765;1;;15.9
      D;1220099999705;;ABgene 0800;1;;15.9
      W;
      A;1220000001831;;ABgene 0765;9;;15.8
      D;1220099999705;;ABgene 0800;2;;15.8
      W;
      A;1220000010734;;ABgene 0765;1;;15.9
      D;1220099999705;;ABgene 0800;3;;15.9
      W;
      A;1220000010734;;ABgene 0765;9;;15.8
      D;1220099999705;;ABgene 0800;4;;15.8
      W;
      A;1220000005877;;ABgene 0765;1;;15.9
      D;1220099999705;;ABgene 0800;5;;15.9
      W;
      A;1220000005877;;ABgene 0765;9;;15.8
      D;1220099999705;;ABgene 0800;6;;15.8
      W;
      C;
      C; SCRC1 = 1220000001831
      C; SCRC2 = 1220000010734
      C; SCRC3 = 1220000005877
      C;
      C; DEST1 = 1220099999705
      TECAN

    tecan_file_lines = tecan_file.lines

    expect(generated_lines.length).to eq(tecan_file_lines.length)

    tecan_file_lines.each_with_index do |expected_line, index|
      expect(expected_line).to eq(generated_lines[index])
    end
  end
end
