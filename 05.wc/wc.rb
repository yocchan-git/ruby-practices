#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = create_options

  file_contents = create_file_contents
  file_details = options.empty? ? create_file_details(file_contents) : create_file_details_with_options(file_contents, options)

  entered_files = ARGV
  entered_files << 'total' if require_total?
  file_details << entered_files unless pipe?

  display_file_details(file_details)
end

def create_options
  options = []

  OptionParser.new do |opts|
    opts.on('-l') { |_v| options << :lines }
    opts.on('-w') { |_v| options << :words }
    opts.on('-c') { |_v| options << :bytes }
  end.parse!

  options
end

def create_file_contents
  if pipe?
    $stdin = STDIN
    return [$stdin.read]
  end

  file_contents_draft = []
  ARGV.each do |file|
    file_contents_draft << File.read(file)
  end
  file_contents_draft
end

def pipe?
  ARGV.empty?
end

def create_file_details(file_contents)
  file_lines = create_file_lines(file_contents)
  file_words = create_file_words(file_contents)
  file_bytes = create_file_bytes(file_contents)

  [file_lines, file_words, file_bytes]
end

def create_file_details_with_options(file_contents, options)
  file_lines = create_file_lines(file_contents) if options.include?(:lines)
  file_words = create_file_words(file_contents) if options.include?(:words)
  file_bytes = create_file_bytes(file_contents) if options.include?(:bytes)

  [file_lines, file_words, file_bytes].compact
end

def create_file_lines(file_contents)
  file_lines = []
  file_contents.each do |file_content|
    file_lines << file_content.split(/\n/).length
  end

  file_lines << file_lines.sum if require_total?
  file_lines.map(&:to_s)
end

def create_file_bytes(file_contents)
  file_bytes = []
  file_contents.each do |file_content|
    file_bytes << file_content.bytesize
  end

  file_bytes << file_bytes.sum if require_total?
  file_bytes.map(&:to_s)
end

def create_file_words(file_contents)
  file_words = []
  file_contents.each do |file_content|
    file_words << file_content.split(/\s+/).length
  end

  file_words << file_words.sum if require_total?
  file_words.map(&:to_s)
end

def require_total?
  !ARGV[1].nil?
end

def display_file_details(file_details)
  file_name_number = file_details.length - 1

  max_lengths = file_details.map { |file_detail| file_detail.max_by(&:length).length }
  transformed_file_details = file_details.transpose

  transformed_file_details.each do |display_file_detail|
    display_file_detail.each_with_index do |file_detail, index|
      print '  '
      print file_name_number == index ? file_detail.ljust(max_lengths[index]) : file_detail.rjust(max_lengths[index])
    end
    puts
  end
end

main
