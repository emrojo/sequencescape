class Parsers::CuantCsvParser < Parsers::BioanalysisCsvParser
  def self.is_cuant?(content)
    # We don't go through the whole file
    content[0..10].detect do |line|
      /Version Created/ === line[0] && /^B.*/ === line[1]
    end.present?
  end
end
