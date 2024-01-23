# frozen_string_literal: true

require 'etc'

class FileName
  ROW_LENGTH = 3

  def initialize
    @file_paths = Dir.entries('.').sort
  end

  def run_ls(options)
    @file_paths.reject! { |file| file.match(/^\./) } if options.none?(:all_files)
    @file_paths.reverse! if options.include?(:reverse)

    create_file_groups
    display_file_groups
  end

  private

  def create_file_groups
    column_length, column_length_remainder = @file_paths.length.divmod(ROW_LENGTH)
    column_length += 1 unless column_length_remainder.zero?

    @file_groups = @file_paths.each_slice(column_length).map { |file_path| file_path.fill(nil, file_path.length...column_length) }
  end

  def display_file_groups
    max_lengths = @file_groups.map { |file_group| file_group.compact.max_by(&:length).length }

    shaped_groups = @file_groups.transpose
    shaped_groups.each do |shaped_group|
      shaped_group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
      puts
    end
  end
end
