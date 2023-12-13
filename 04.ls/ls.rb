#!/usr/bin/env ruby
# frozen_string_literal: true

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort
max_length = file_or_directory.max_by(&:length).length

grouped_files_or_directories = file_or_directory.each_slice(4).map { |slice| slice.fill(nil, slice.length...4) }
transposed_groups = grouped_files_or_directories.transpose
transposed_groups.each do |group|
  group.compact.each { |item| printf("%-#{max_length}s   ", item) }
  puts
end
