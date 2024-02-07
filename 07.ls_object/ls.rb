# frozen_string_literal: true

require 'optparse'
require_relative './file_detail'

class Ls
  def initialize
    @options = fetch_options
    @file_paths = fetch_file_paths
  end

  def run
    if @options.key?(:long_format)
      file_detail = FileDetail.new(@file_paths)
      file_detail.display
    else
      @column_file_groups = FileFormatter.fetch_column_file_groups(@file_paths)
      display
    end
  end

  private

  def fetch_options
    options = {}

    OptionParser.new do |opts|
      opts.on('-a') { |v| options[:all_files] = v }
      opts.on('-r') { |v| options[:reverse] = v }
      opts.on('-l') { |v| options[:long_format] = v }
    end.parse!

    options
  end

  def fetch_file_paths
    file_paths = Dir.entries('.').sort

    file_paths.reject! { |file| file.match(/^\./) } if !@options.key?(:all_files)
    file_paths.reverse! if @options.key?(:reverse)

    file_paths
  end

  def display
    max_lengths = @column_file_groups.map { |column_file_group| column_file_group.compact.max_by(&:length).length }

    transposed_file_groups = @column_file_groups.transpose
    transposed_file_groups.each do |transposed_file_group|
      transposed_file_group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
      puts
    end
  end
end
