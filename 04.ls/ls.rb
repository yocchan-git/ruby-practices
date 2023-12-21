#!/usr/bin/env ruby
# frozen_string_literal: true

ROW_LENGTH = 3

def max_length(check_array)
  check_array.max_by(&:length).length
end

def grouped_files_or_directories(files_or_directories, column_length)
  files_or_directories.each_slice(column_length).map { |slice| slice.fill(nil, slice.length...column_length) }
end

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort
column_length = file_or_directory.size / ROW_LENGTH
column_length += 1 unless (file_or_directory.size % ROW_LENGTH).zero?

transposed_groups = grouped_files_or_directories(file_or_directory, column_length).transpose
transposed_groups.each do |group|
  group.compact.each { |item| printf("%-#{max_length(file_or_directory)}s   ", item) }
  puts
end
