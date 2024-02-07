# frozen_string_literal: true

require 'etc'
require_relative './file_formatter'

class FileDetail
  HARD_LINK = 1
  FILE_SIZE = 4

  def initialize(file_paths)
    @file_paths = file_paths
    @total_blocks = 0
    @file_details = fetch_file_details
  end

  def display
    max_lengths = @file_details.map { |file_detail| file_detail.compact.max_by(&:length).length }

    puts "total #{@total_blocks}"
    @file_details.transpose.each do |file_detail|
      file_detail.compact.each_with_index do |item, index|
        print [HARD_LINK, FILE_SIZE].include?(index) ? item.rjust(max_lengths[index]) : item.ljust(max_lengths[index])
        print '  '
      end
      puts
    end
  end

  private

  def fetch_file_details
    type_and_permissions = []
    hard_links = []
    owners = []
    groups = []
    file_sizes = []
    updated_times = []
    file_names = []

    @file_paths.each do |file_path|
      file_formatter = FileFormatter.new(file_path)

      @total_blocks += file_formatter.blocks
      type_and_permissions << file_formatter.file_type + file_formatter.permission
      hard_links << file_formatter.hard_link
      owners << file_formatter.owner
      groups << file_formatter.group
      file_sizes << file_formatter.file_size
      updated_times << file_formatter.updated_time
      file_names << file_formatter.name
    end

    [type_and_permissions, hard_links, owners, groups, file_sizes, updated_times, file_names]
  end
end
