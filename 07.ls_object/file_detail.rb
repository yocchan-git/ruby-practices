# frozen_string_literal: true

require 'etc'

class FileDetail
  NORMAL_PERMISSIONS_DIGITS = -3..-1
  SPECIAL_PERMISSION_DIGIT = -4
  OTHER_PERMISSION_MOVE = -1
  HARD_LINK = 1
  FILE_SIZE = 4
  PERMISSION_SYMBOLICS = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def initialize(file_paths)
    @file_paths = file_paths

    @total_blocks = 0
    @type_and_permissions = []
    @hard_links = []
    @owners = []
    @groups = []
    @file_sizes = []
    @updated_times = []
    @file_names = []

    set_details
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

  def set_details
    @file_paths.each do |file|
      @file_name = file
      @file_stat = find_symlink_file ? File.lstat(file) : File::Stat.new(file)

      @total_blocks += @file_stat.blocks
      @type_and_permissions << (find_symlink_file || find_file_type) + create_permission
      @hard_links << @file_stat.nlink.to_s
      @owners << Etc.getpwuid(@file_stat.uid).name
      @groups << Etc.getgrgid(@file_stat.gid).name
      @file_sizes << @file_stat.size.to_s
      @updated_times << create_updated_time
      @file_names << create_file_name
    end

    @file_details = [@type_and_permissions, @hard_links, @owners, @groups, @file_sizes, @updated_times, @file_names]
  end

  def find_symlink_file
    'l' if File.lstat(@file_name).symlink?
  end

  def find_file_type
    return '-' if @file_stat.file?
    return 'd' if @file_stat.directory?
    return 'c' if @file_stat.chardev?
    return 'b' if @file_stat.blockdev?
    return 's' if @file_stat.socket?
    return 'p' if @file_stat.pipe?

    '?'
  end

  def create_permission
    permissions = @file_stat.mode

    permission_digits = format('%o', permissions)[NORMAL_PERMISSIONS_DIGITS]
    @special_digits = format('%o', permissions)[SPECIAL_PERMISSION_DIGIT]

    symbolic_permissions = permission_digits.chars.map { |char| PERMISSION_SYMBOLICS[char] }.join
    special_permission = create_special_permission

    return symbolic_permissions if special_permission.empty?

    special_permission_symbolic = symbolic_permissions[OTHER_PERMISSION_MOVE] == 'x' ? special_permission : special_permission.upcase
    symbolic_permissions.gsub(/.$/, special_permission_symbolic)
  end

  def create_special_permission
    case @special_digits
    when '1' then 't'
    when '2' then 's'
    when '4' then 's'
    else ''
    end
  end

  def create_updated_time
    month_and_date = @file_stat.mtime.strftime('%m %d').gsub(/\b0(\d)\b/, ' \1')
    hour_and_minutes = @file_stat.mtime.strftime('%H:%M')
    "#{month_and_date} #{hour_and_minutes}"
  end

  def create_file_name
    find_symlink_file ? "#{@file_name} -> #{File.readlink(@file_name)}" : @file_name
  end
end
