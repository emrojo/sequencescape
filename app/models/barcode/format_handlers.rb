# frozen_string_literal: true

require 'sanger_barcode_format'
# A collection of supported formats
module Barcode::FormatHandlers
  # Include in barcode formats which can not be rendered as EAN13s
  module Ean13Incompatible
    def ean13_barcode?
      false
    end

    def ean13_barcode
      nil
    end
  end
  #
  # The original Sequencescape barcode format. results in:
  # Human readable form: DN12345U
  # Ean13 compatible machine readable form: 1220012345855
  # This class mostly wraps the SBCF Gem
  #
  # @author [jg16]
  #
  class SangerEan13
    attr_reader :barcode_object
    def initialize(barcode)
      @barcode_object = SBCF::SangerBarcode.from_human(barcode)
    end

    delegate :human_barcode, to: :barcode_object
    delegate_missing_to :barcode_object

    # The gem was yielding integers for backward compatible reasons.
    # We'll convert for the time being, but should probably fix that.
    def machine_barcode
      barcode_object.machine_barcode.to_s
    end

    alias ean13_barcode machine_barcode
    alias code128_barcode machine_barcode
    alias serialize_barcode human_barcode

    def ean13_barcode?
      true
    end

    def code128_barcode?
      true
    end

    def barcode_prefix
      prefix.human
    end
  end

  # A basic class for barodes that can be validated and decomposed by simple regular expressions
  # Classes that inherit from this should define a regular expression with optional names matchers
  # for prefix, number and suffix. This regex should be assigned to self.format
  class BaseRegExBarcode
    include Ean13Incompatible
    attr_reader :human_barcode

    class_attribute :format

    def initialize(barcode)
      @human_barcode = barcode
      @matches = format.match(@human_barcode)
    end

    def barcode_prefix
      @matches[:prefix] if @matches&.names&.include?('prefix')
    end

    def number
      @matches[:number].to_i if @matches&.names&.include?('number')
    end

    def suffix
      @matches[:suffix] if @matches&.names&.include?('suffix')
    end

    def code128_barcode?
      true
    end

    def valid?
      format.match? @human_barcode
    end

    alias code128_barcode human_barcode
    alias machine_barcode human_barcode
    alias serialize_barcode human_barcode
  end

  # Infinium barcodes are externally generated barcodes on Illumina Infinium chips
  class Infinium < BaseRegExBarcode
    # Based on ALL existing examples (bar what appears to be accidental usage of the sanger barcode in 5 cases)
    # eg. WG0000001-DNA and WG0000001-BCD
    self.format = /\A(?<prefix>WG)(?<number>[0-9]{7})-(?<suffix>[DNA|BCD]{3})\z/
  end

  # Fluidigm barcodes are externally generated barcodes present on fluidigm plates. They are ten digits long.
  class Fluidigm < BaseRegExBarcode
    # Ten digit barcode
    self.format = /\A(?<number>[0-9]{10})\z/
  end

  # External barcodes are almost always valid.
  class External < BaseRegExBarcode
    # Extract prefix numbers and suffix if the format is fairly simple.
    # - A number, surrounded by JUST letters and underscores
    self.format = /\A(?<prefix>[\w&&[^\d]]*)(?<number>\d+)(?<suffix>[\w&&[^\d]]*)\z/

    def valid?
      true
    end
  end
end
