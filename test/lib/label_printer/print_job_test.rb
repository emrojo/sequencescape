require 'test_helper'

class PrintJobTest < ActiveSupport::TestCase
  attr_reader :print_job, :plates, :plate, :plate_purpose, :barcode_printer, :attributes

  def setup
    @barcode_printer = create :barcode_printer
    LabelPrinter::PmbClient.stubs(:get_label_template_by_name).returns('data' => [{ 'id' => 15 }])
    @plates = create_list :child_plate, 1
    @plate = plates[0]
    @plate_purpose = plate.plate_purpose
    @attributes = { printer_name: barcode_printer.name,
                    labels: { body:
                  [{ main_label:
                    { top_left: (Date.today.strftime('%e-%^b-%Y')).to_s,
                      bottom_left: plate.human_barcode.to_s,
                      top_right: plate_purpose.name.to_s,
                      bottom_right: "user #{plate.find_study_abbreviation_from_parent}",
                      top_far_right: plate.parent.try(:barcode_number).to_s,
                      barcode: plate.ean13_barcode.to_s } }] },
                    label_template_id: 15, }
    @print_job = LabelPrinter::PrintJob.new(barcode_printer.name, LabelPrinter::Label::PlateCreator, plates: plates, plate_purpose: plate_purpose, user_login: 'user')
  end

  test 'should have attributes' do
    assert print_job.printer_name
    assert print_job.label_class
    assert print_job.options
  end

  test 'should build attributes' do
    assert_equal attributes, print_job.build_attributes
  end

  test 'should know number of labels, return correct success message' do
    print_job.build_attributes
    assert_equal 1, print_job.number_of_labels
    assert_equal "Your 1 label(s) have been sent to printer #{barcode_printer.name}", print_job.success
  end

  test 'should contact pmb to print labels' do
    LabelPrinter::PmbClient.expects(:print).with(attributes)
    assert print_job.execute
  end

  test '#execute is false if printer is not registered in ss' do
    print_job = LabelPrinter::PrintJob.new('not_registered', LabelPrinter::Label::PlateCreator, {})
    refute print_job.execute
    assert_equal 1, print_job.errors.count
  end

  test '#execute is false if pmb is down' do
    print_job = LabelPrinter::PrintJob.new(barcode_printer.name, LabelPrinter::Label::PlateCreator, {})
    RestClient.expects(:post).raises(Errno::ECONNREFUSED)
    refute print_job.execute
    assert_equal 1, print_job.errors.count
  end

  test '#execute is false if something goes wrong within pmb' do
    RestClient.expects(:post).raises(RestClient::UnprocessableEntity)
    refute print_job.execute
    assert_equal 1, print_job.errors.count
  end
end
