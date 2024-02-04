#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = create_options
  file_details = create_file_details

  display_file_details(file_details, options)
end

def create_options
  options = {}

  OptionParser.new do |opts|
    opts.on('-l') { |v| options[:lines] = v }
    opts.on('-w') { |v| options[:words] = v }
    opts.on('-c') { |v| options[:bytes] = v }
  end.parse!

  options.empty? ? { lines: true, words: true, bytes: true } : options
end

def create_file_details
  file_name_and_contents = create_file_name_and_contents

  file_details = file_name_and_contents.each.map { |file_name_and_content| create_file_details_hash(file_name_and_content) }
  file_details << create_total_details(file_details) if file_details.size > 1

  file_details
end

def create_file_name_and_contents
  return [{ file_name: '', content: $stdin.read }] if ARGV.empty?

  ARGV.map { |file_name| { file_name:, content: File.read(file_name) } }
end

def create_file_details_hash(file_content)
  file_detail = {}

  file_detail[:lines] = file_content[:content].split(/\n/).length
  file_detail[:words] = file_content[:content].split(/\s+/).length
  file_detail[:bytes] = file_content[:content].bytesize
  file_detail[:file_name] = file_content[:file_name]

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

def display_file_details(file_details, options)
  widths = create_max_lengths(file_details)

  file_details.each do |file_detail|
    details = []

    details << file_detail[:lines].to_s.rjust(widths[:lines]) if options.key?(:lines)
    details << file_detail[:words].to_s.rjust(widths[:words]) if options.key?(:words)
    details << file_detail[:bytes].to_s.rjust(widths[:bytes]) if options.key?(:bytes)
    details << file_detail[:file_name]

    puts details.join('  ')
  end
end

def create_max_lengths(file_details)
  last_file_details = file_details.last

  {
    lines: last_file_details[:lines].to_s.length,
    words: last_file_details[:words].to_s.length,
    bytes: last_file_details[:bytes].to_s.length
  }
end

main
