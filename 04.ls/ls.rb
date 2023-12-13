#!/usr/bin/env ruby
# frozen_string_literal: true

ROW_LENGTH = 4

def max_length(check_array)
  check_array.max_by(&:length)&.length
end

def grouped_files_or_directories(files_or_directories, row_length)
  files_or_directories.each_slice(row_length).map { |slice| slice.fill(nil, slice.length...row_length) }
end

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort
if file_or_directory.length < ROW_LENGTH
  file_or_directory.each do |file_or_directory_output|
    puts file_or_directory_output
  end
  exit
end

transposed_groups = grouped_files_or_directories(file_or_directory, ROW_LENGTH).transpose
transposed_groups.each do |group|
  group.compact.each { |item| printf("%-#{max_length(file_or_directory)}s   ", item) }
  puts
end
