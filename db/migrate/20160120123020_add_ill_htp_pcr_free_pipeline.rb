class AddIllHtpPcrFreePipeline < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do |_t|
      stock_name = 'PF Cherrypicked'

      plate_flow = [stock_name, 'PF Shear', 'PF Post Shear', 'PF Post Shear XP', 'PF Lib', 'PF Lib XP', 'PF Lib XP2', 'PF EM Pool', 'PF Lib Norm']

      tube_flow = ['PF MiSeq Stock', 'PF MiSeq QC']

      IlluminaHtp::PlatePurposes.create_tube_flow(tube_flow)
      IlluminaHtp::PlatePurposes.create_tube_flow(['PF MiSeq QCR'])
      IlluminaHtp::PlatePurposes.create_plate_flow(plate_flow)
      IlluminaHtp::PlatePurposes.create_qc_plate_for('PF EM Pool')
    end
  end

  def down
    ActiveRecord::Base.transaction do |t|
    end
  end
end
