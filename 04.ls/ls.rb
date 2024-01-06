#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

ROW_LENGTH = 3
NORMAL_PERMISSIONS_DIGITS = -3..-1
SPECIAL_PERMISSION_DIGIT = -4
OTHER_PERMISSION_MOVE = -1
HARD_LINKS = 1
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

opt = OptionParser.new
option = nil
opt.on('-l [VAL]') { |_v| option = :detail }
opt.parse!(ARGV)

def create_max_length(check_files_or_details)
  check_files_or_details.max_by(&:length).length
end

def create_max_lengths(files_or_details)
  files_or_details.map { |file_or_detail| create_max_length(file_or_detail.compact) }
end

def create_symbolic_permissions(permission_digits)
  permission_digits.chars.map { |char| PERMISSION_SYMBOLICS[char] }.join
end

def find_symlink_file(file_name)
  'l' if File.lstat(file_name).symlink?
end

def find_file_type(file_stat)
  return '-' if file_stat.file?
  return 'd' if file_stat.directory?
  return 'c' if file_stat.chardev?
  return 'b' if file_stat.blockdev?
  return 's' if file_stat.socket?
  return 'p' if file_stat.pipe?

  '?'
end

def create_special_permission(special_digits)
  case special_digits
  when '1' then 't'
  when '2' then 's'
  when '4' then 's'
  else ''
  end
end

def create_permission(file_stat)
  permissions = file_stat.mode

  permission_digits = format('%o', permissions)[NORMAL_PERMISSIONS_DIGITS]
  special_digits = format('%o', permissions)[SPECIAL_PERMISSION_DIGIT]

  symbolic_permissions = create_symbolic_permissions(permission_digits)
  special_permission = create_special_permission(special_digits)

  unless special_permission.empty?
    symbolic_permissions[OTHER_PERMISSION_MOVE] = symbolic_permissions[OTHER_PERMISSION_MOVE] == 'x' ? special_permission : special_permission.upcase
  end

  symbolic_permissions
end

def create_file_name(file_name)
  find_symlink_file(file_name) ? "#{file_name} -> #{File.readlink(file_name)}" : file_name
end

def create_updated_time(file_stat)
  month_and_date = file_stat.mtime.strftime('%m %d').gsub(/\b0(\d)\b/, ' \1')
  hour_and_minutes = file_stat.mtime.strftime('%H:%M')
  "#{month_and_date} #{hour_and_minutes}"
end

def create_file_details(files)
  total_blocks = 0
  type_and_permissions = []
  hard_links = []
  owners = []
  groups = []
  file_sizes = []
  updated_times = []
  file_names = []

  files.each do |file|
    file_stat = find_symlink_file(file) ? File.lstat(file) : File::Stat.new(file)
    total_blocks += file_stat.blocks

    type_and_permissions << (find_symlink_file(file) || find_file_type(file_stat)) + create_permission(file_stat)
    hard_links << file_stat.nlink.to_s
    owners << Etc.getpwuid(file_stat.uid).name
    groups << Etc.getgrgid(file_stat.gid).name
    file_sizes << file_stat.size.to_s
    updated_times << create_updated_time(file_stat)
    file_names << create_file_name(file)
  end

  [total_blocks, [type_and_permissions, hard_links, owners, groups, file_sizes, updated_times, file_names]]
end

def display_file_details(total, file_details, max_lengths)
  puts "total #{total}"

  transposed_groups = file_details.transpose
  transposed_groups.each do |group|
    group.compact.each_with_index do |item, index|
      print [HARD_LINKS, FILE_SIZE].include?(index) ? item.rjust(max_lengths[index]) : item.ljust(max_lengths[index])
      print '  '
    end
    puts
  end
end

def show_file_details(file_or_directory)
  total_blocks, file_or_directory_details = create_file_details(file_or_directory)
  max_lengths = create_max_lengths(file_or_directory_details)

  display_file_details(total_blocks, file_or_directory_details, max_lengths)
end

def display_file_or_directory(files_or_directories, max_lengths)
  transposed_groups = files_or_directories.transpose
  transposed_groups.each do |group|
    group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
    puts
  end
end

def show_file_or_directory(file_or_directory)
  column_length, column_length_remainder = file_or_directory.length.divmod(ROW_LENGTH)
  column_length += 1 unless column_length_remainder.zero?

  groups = file_or_directory.each_slice(column_length).map { |slice| slice.fill(nil, slice.length...column_length) }
  max_lengths = create_max_lengths(groups)

  display_file_or_directory(groups, max_lengths)
end

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort

if option == :detail
  show_file_details(file_or_directory)
else
  show_file_or_directory(file_or_directory)
end
