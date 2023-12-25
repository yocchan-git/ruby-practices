#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
ROW_LENGTH = 3

option = nil
OptionParser.new do |opts|
  opts.on('-a [VAL]') { |_v| option = :all }
  opts.on('-A [VAL]') { |_v| option = :almost_all }
end.parse!

def create_file_or_directory(option)
  all_files_or_directories = Dir.entries('.')
  case option
  when :all
    all_files_or_directories
  when :almost_all
    all_files_or_directories.reject { |file| file.match(/^\.\.?$/) }
  else
    all_files_or_directories.reject { |file| file.match(/^\./) }
  end
end

def max_length(check_array)
  check_array.max_by(&:length).length
end

def grouped_files_or_directories(files_or_directories, column_length)
  files_or_directories.each_slice(column_length).map { |slice| slice.fill(nil, slice.length...column_length) }
end

file_or_directory = create_file_or_directory(option).sort

column_length, column_length_remainder = file_or_directory.length.divmod(ROW_LENGTH)
column_length += 1 unless column_length_remainder.zero?

groups = grouped_files_or_directories(file_or_directory, column_length)
max_lengths = groups.map { |group| max_length(group.compact) }

transposed_groups = groups.transpose
transposed_groups.each do |group|
  group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
  puts
end
