#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
ROW_LENGTH = 3

regex_file = /^\./
OptionParser.new do |opts|
  opts.on('-a [VAL]') { |_v| regex_file = nil }
  opts.on('-A [VAL]') { |_v| regex_file = /^\.\.?$/ }
end.parse!

def create_file_or_directory(regex_file)
  regex_file.nil? ? Dir.entries('.') : Dir.entries('.').reject { |file| file.match(regex_file) }
end

def max_length(check_array)
  check_array.max_by(&:length).length
end

def grouped_files_or_directories(files_or_directories, column_length)
  files_or_directories.each_slice(column_length).map { |slice| slice.fill(nil, slice.length...column_length) }
end

file_or_directory = create_file_or_directory(regex_file).sort

column_length, column_length_remainder = file_or_directory.length.divmod(ROW_LENGTH)
column_length += 1 unless column_length_remainder.zero?

groups = grouped_files_or_directories(file_or_directory, column_length)
max_lengths = groups.map { |group| max_length(group.compact) }

transposed_groups = groups.transpose
transposed_groups.each do |group|
  group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
  puts
end
