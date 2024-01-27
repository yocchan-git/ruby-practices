#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = create_options
  display_multiple_files? ? display_entered_content_details(options) : display_file_details(options)
end

def create_options
  options = {}

  OptionParser.new do |opts|
    opts.on('-l') { |is_option| options[:lines] = is_option }
    opts.on('-w') { |is_option| options[:words] = is_option }
    opts.on('-c') { |is_option| options[:bytes] = is_option }
  end.parse!

  options
end

def display_multiple_files?
  file_names = ARGV
  file_names.empty? || file_names[1].nil?
end

def display_entered_content_details(options)
  file_name = ARGV[0]
  entered_content = create_entered_content(file_name)

  content_details = []

  content_details << entered_content.split(/\n/).length  if display_lines?(options)
  content_details << entered_content.split(/\s+/).length if display_words?(options)
  content_details << entered_content.bytesize if display_bytes?(options)
  content_details << file_name if file_name

  puts content_details.join('  ')
end

def create_entered_content(file_name)
  if file_name
    File.read(file_name)
  else
    $stdin = STDIN
    $stdin.read
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

def display_file_details(options)
  file_details = create_file_details
  widths = create_max_lengths

  file_details.each do |file_detail|
    details = []

    details << file_detail[:lines].rjust(widths[:lines]) if display_lines?(options)
    details << file_detail[:words].rjust(widths[:words]) if display_words?(options)
    details << file_detail[:bytes].rjust(widths[:bytes]) if display_bytes?(options)
    details << file_detail[:file_name]

    puts details.join('  ')
  end
end

def create_file_details
  file_details = []

  ARGV.each { |file| file_details << create_file_content(file) }
  file_details << create_total_details

  file_details
end

def create_file_content(file_name)
  file_content = File.read(file_name)

  file_detail = {}
  file_detail[:lines] = file_content.split(/\n/).length.to_s
  file_detail[:words] = file_content.split(/\s+/).length.to_s
  file_detail[:bytes] = file_content.bytesize.to_s
  file_detail[:file_name] = file_name

  file_detail
end

def create_total_details
  file_contents = ARGV.map { |file| File.read(file) }
  total_details = {}

  total_details[:lines] = file_contents.sum { |file_content| file_content.split(/\n/).length }.to_s
  total_details[:words] = file_contents.sum { |file_content| file_content.split(/\s+/).length }.to_s
  total_details[:bytes] = file_contents.sum(&:bytesize).to_s
  total_details[:file_name] = 'total'

  total_details
end

def create_max_lengths
  widths = {}
  total_details = create_total_details

  widths[:lines] = total_details[:lines].length
  widths[:words] = total_details[:words].length
  widths[:bytes] = total_details[:bytes].length

  widths
end

main
