#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require 'optparse'

display_bytes = nil
display_lines = nil
display_words = nil

OptionParser.new do |opts|
  opts.on('-l') { |is_option| display_lines = is_option }
  opts.on('-c') { |is_option| display_bytes = is_option }
  opts.on('-w') { |is_option| display_words = is_option }
end.parse!

def is_require_total
  !ARGV[1].nil?
end

def create_file_lines(file_contents)
  file_lines = []
  file_contents.each do |file_content|
    file_lines << file_content.split(/\n/).length
  end

  file_lines << file_lines.sum if is_require_total
  file_lines.map(&:to_s)
end

def create_file_bytes(file_contents)
  file_bytes = []
  file_contents.each do |file_content|
    file_bytes << file_content.split(/\s+/).length
  end

  file_bytes << file_bytes.sum if is_require_total
  file_bytes.map(&:to_s)
end

def create_file_words(file_contents)
  file_words = []
  file_contents.each do |file_content|
    file_words << file_content.length
  end

  file_words << file_words.sum if is_require_total
  file_words.map(&:to_s)
end

def create_file_details_with_options(file_contents, options)
  file_lines = create_file_lines(file_contents) if options.include?('lines')
  file_bytes = create_file_bytes(file_contents) if options.include?('bytes')
  file_words = create_file_words(file_contents) if options.include?('words')

  [file_lines, file_bytes, file_words].compact
end

def create_file_details(file_contents)
  file_lines = create_file_lines(file_contents)
  file_bytes = create_file_bytes(file_contents)
  file_words = create_file_words(file_contents)

  [file_lines, file_bytes, file_words]
end

def create_max_length(check_files_or_details)
  check_files_or_details.max_by(&:length).length
end

def create_max_lengths(files_or_details)
  files_or_details.map { |file_or_detail| create_max_length(file_or_detail.compact) }
end

set_files = ARGV

file_contents = []
set_files.each do |file|
  file_contents << File.read(file)
end

def create_file_options(is_display_lines, is_display_bytes, is_display_words)
  file_options = []

  file_options << 'lines' if is_display_lines
  file_options << 'bytes' if is_display_bytes
  file_options << 'words' if is_display_words

  file_options
end

file_options = create_file_options(display_lines, display_bytes, display_words)

file_details = file_options.empty? ? create_file_details(file_contents) : create_file_details_with_options(file_contents, file_options)

set_files << "total" if is_require_total
file_details << set_files

max_lengths = create_max_lengths(file_details)

display_file_details = file_details.transpose
FILE_NAMES = file_details.length - 1

display_file_details.each do |display_file_detail|
  display_file_detail.each_with_index do |file_detail, index|
    print '  '
    print FILE_NAMES == index ? file_detail.ljust(max_lengths[index]) : file_detail.rjust(max_lengths[index])
  end
  puts
end
