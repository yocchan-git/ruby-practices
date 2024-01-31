#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = create_options
  file_details = create_file_details
  widths = create_max_lengths(file_details)

  display_file_details(file_details, widths, options)
end

def create_options
  options = {}

  OptionParser.new do |opts|
    opts.on('-l') { |v| options[:lines] = v }
    opts.on('-w') { |v| options[:words] = v }
    opts.on('-c') { |v| options[:bytes] = v }
  end.parse!

  options
end

def create_file_details
  file_contents = create_file_content

  file_details = file_contents.each_with_index.map { |file_content, index| create_file_details_hash(file_content, index) }
  file_details << create_total_details(file_details) if display_multiple_files?

  file_details
end

def create_file_content
  return [$stdin.read] if ARGV.empty?

  ARGV.map { |file_name| File.read(file_name) }
end

def create_file_details_hash(file_content, index)
  file_detail = {}

  file_detail[:lines] = file_content.split(/\n/).length
  file_detail[:words] = file_content.split(/\s+/).length
  file_detail[:bytes] = file_content.bytesize
  file_detail[:file_name] = ARGV[index]

  file_detail
end

def create_total_details(file_details)
  lines = 0
  words = 0
  bytes = 0

  file_details.each do |file_detail|
    lines += file_detail[:lines]
    words += file_detail[:words]
    bytes += file_detail[:bytes]
  end

  { lines:, words:, bytes:, file_name: 'total' }
end

def display_multiple_files?
  file_names = ARGV
  file_names.length > 1
end

def create_max_lengths(file_details)
  widths = {}
  longest_character_details = file_details.last

  widths[:lines] = longest_character_details[:lines].to_s.length
  widths[:words] = longest_character_details[:words].to_s.length
  widths[:bytes] = longest_character_details[:bytes].to_s.length

  widths
end

def display_file_details(file_details, widths, options)
  file_details.each do |file_detail|
    details = []

    details << file_detail[:lines].to_s.rjust(widths[:lines]) if display_lines?(options)
    details << file_detail[:words].to_s.rjust(widths[:words]) if display_words?(options)
    details << file_detail[:bytes].to_s.rjust(widths[:bytes]) if display_bytes?(options)
    details << file_detail[:file_name]

    puts details.join('  ')
  end
end

def display_lines?(options)
  options.key?(:lines) || options.empty?
end

def display_words?(options)
  options.key?(:words) || options.empty?
end

def display_bytes?(options)
  options.key?(:bytes) || options.empty?
end

main
