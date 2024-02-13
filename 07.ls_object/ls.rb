# frozen_string_literal: true

require 'optparse'
require_relative './file_detail'

class Ls
  ROW_LENGTH = 3

  def initialize
    @options = fetch_options
    @file_paths = fetch_file_paths
  end

  def run
    if @options.key?(:long_format)
      file_formatter = FileFormatter.new(@file_paths)
      file_formatter.display
    else
      @column_file_groups = fetch_column_file_groups
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

  def fetch_column_file_groups
    column_length, column_length_remainder = @file_paths.length.divmod(ROW_LENGTH)
    column_length += 1 unless column_length_remainder.zero?

    @file_paths.each_slice(column_length).map { |file_path| file_path.fill(nil, file_path.length...column_length) }
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
