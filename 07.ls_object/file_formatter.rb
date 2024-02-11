# frozen_string_literal: true

class FileFormatter
  HARD_LINK = 1
  FILE_SIZE = 4

  def initialize(file_paths)
    @file_paths = file_paths
    @total_blocks = 0
    @file_details = fetch_file_details
  end

  def display
    formatted_file_details = format_file_details
    max_lengths = formatted_file_details.map { |formatted_file_detail| formatted_file_detail.compact.max_by(&:length).length }

    puts "total #{@total_blocks}"
    formatted_file_details.transpose.each do |formatted_file_detail|
      formatted_file_detail.compact.each_with_index do |item, index|
        print [HARD_LINK, FILE_SIZE].include?(index) ? item.rjust(max_lengths[index]) : item.ljust(max_lengths[index])
        print '  '
      end
      puts
    end
  end

  private

  def fetch_file_details
    @file_paths.map { |file_path| FileDetail.new(file_path) }
  end

  def format_file_details
    type_and_permissions = []
    hard_links = []
    owners = []
    groups = []
    file_sizes = []
    updated_times = []
    file_names = []

    @file_details.each do |file_detail|
      @total_blocks += file_detail.blocks
      type_and_permissions << file_detail.file_type + file_detail.permission
      hard_links << file_detail.hard_link
      owners << file_detail.owner
      groups << file_detail.group
      file_sizes << file_detail.file_size
      updated_times << file_detail.updated_time
      file_names << file_detail.name
    end

    [type_and_permissions, hard_links, owners, groups, file_sizes, updated_times, file_names]
  end
end
