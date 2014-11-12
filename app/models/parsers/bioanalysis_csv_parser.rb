# encoding: utf-8
require 'csv'

class Parsers::BioanalysisCsvParser
	def initialize(filename, content)
		@filename = filename
		@content = CSV.parse(content)
	end

	def get_field_name(sym_name)
	  {
	  	:concentration => "Conc. [ng/µl]",
	  	:molarity => "Molarity [nmol/l]"
	  }[sym_name]
	end

	def concentration(plate_position)
		return get_parsed_attribute(plate_position, get_field_name(:concentration))
	end

	def molarity(plate_position)
		return get_parsed_attribute(plate_position, get_field_name(:molarity))
	end

	def table_content_hash(group)
		content_hash = {}
		starting_line = group[0]
		ending_line = group[1]
		type = @content[starting_line][0]
		fields = @content[starting_line+1]

		for pos in (starting_line+2) .. (ending_line) do
			values = @content[pos]
			unless values.nil? && (values.length != fields.length)
				content_hash.merge!(Hash[fields.zip(values)])
			end
		end
		content_hash
	end

	def build_range(range)
		if range == nil
			range = [0, @content.length-1]
		else
			range = range.dup
		end
		range.push(@content.length-1) if (range.length==1)
		range
	end

	# Finds groups of lines by range in which the beginning of the range contains the
	# matching regexp as text in the first column and the end of the range is an empty line
	# - regexp -> Regular expression to be matched in the first column as beginning of range
	# - range -> In case it is specified, restricts the searching process to this range of lines
  # instead of using all the content of the CSV file
	def get_groups(regexp, range=nil)
		groups = []
		group = []
		range = build_range(range)

		group_contents = get_group_content(range)

		group_contents.each_with_index do |line, pos|
			if (line[0].match(regexp) && group.length == 0)
				group.push(pos)
			else
				if ((line[0].match(" ") && line.length == 1) && group.length == 1)
					group.push(pos-1)
				end
			end

			if group.length == 2
				groups.push [group[0] + range[0], group[1] + range[0]]
				group = []
			end
			if ((group.length ==1) && (pos==(group_contents.length-1)))
				groups.push [group[0] + range[0], pos + range[0]]
			end
		end
		groups
	end

	def get_group_content(group)
		@content.slice(group[0], group[1]-group[0]+1)
	end

	def parse_peak_table(group)
		table_content_hash(get_groups(/Peak Table/m, group)[0])
	end

	def parse_region_table(group)
		table_content_hash(get_groups(/Region Table/m, group)[0])
	end

	def parse_overall(group)
		get_group_content(get_groups(/Overall.*/m, group)[0])[1][1]
	end

	def parse_cell(group)
		@cell = get_group_content(group)[0][1]
	end

	def parse_sample(group)
		{
			parse_cell(group) => {
				:peak_table => parse_peak_table(group),
				:region_table => parse_region_table(group),
				:overall => parse_overall(group)
		  }
		}
	end

	def parse_samples
		groups = get_groups(/Sample Name/)
		groups.each_with_index.map do |group, pos|
			if (pos == (groups.length - 1))
				next_index = @content.length - 1
			else
				next_index = groups[pos+1][0]-1
			end
			[group[0], next_index]
		end.reduce({}) do |memo, group|
			memo.merge(self.parse_sample group)
		end
	end

	def parse
		@parsed_content = parse_samples
	end

	def parsed_content
		@parsed_content.nil? ? parse : @parsed_content
	rescue NoMethodError
		nil
	end

	def get_parsed_attribute(plate_position, field)
		return nil if parsed_content.nil? || parsed_content[plate_position].nil?
		parsed_content[plate_position][:peak_table][field]
	end

	def is_bioanalysis_content?
		@content.each_with_index do |line, pos|
			if line[0].match(/Version Created/) && line[1].match(/^B.*/)
				return pos
			end
		end
		-1
	end

	def validates_content?
		is_bioanalysis_content? && !parsed_content.nil?
	end
end