#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

ROW_LENGTH = 3
NORMAL_PERMISSIONS_DIGITS = -3..-1
SPECIAL_PERMISSION_DIGIT = -4
OTHER_PERMISSION_MOVE = -1
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

def create_max_length(check_files_or_details)
  check_files_or_details.max_by(&:length).length
end

def create_max_lengths(files_or_details)
  files_or_details.map { |file_or_detail| create_max_length(file_or_detail.compact) }
end

def grouped_files_or_directories(files_or_directories, column_length)
  files_or_directories.each_slice(column_length).map { |slice| slice.fill(nil, slice.length...column_length) }
end

def create_file_name(file_name)
  find_symlink_file(file_name) ? "#{file_name} -> #{File.readlink(file_name)}" : file_name
end

def create_file_detail(file_name, file_stat)
  file_or_directory_detail = {}

  file_or_directory_detail[:type_and_permission] = (find_symlink_file(file_name) || find_file_type(file_stat)) + create_permission(file_stat)
  file_or_directory_detail[:hard_link] = file_stat.nlink.to_s
  file_or_directory_detail[:owner] = Etc.getpwuid(file_stat.uid).name
  file_or_directory_detail[:group] = Etc.getgrgid(file_stat.gid).name
  file_or_directory_detail[:file_size] = file_stat.size.to_s
  file_or_directory_detail[:updated_at] = file_stat.mtime.strftime('%m %d %H:%M')
  file_or_directory_detail[:file_name] = create_file_name(file_name)

  file_or_directory_detail
end

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort

if option == :detail
  file_or_directory_details = []
  total_blocks = 0

  file_or_directory.each do |file|
    file_stat = File::Stat.new(file)
    total_blocks += file_stat.blocks

    file_or_directory_details << create_file_detail(file, file_stat)
  end

  puts "total #{total_blocks}"
  file_or_directory_details.each do |file_detail|
    file_detail.each do |key, value|
      print value
      print '  '
    end
    puts
  end
  exit
end

column_length, column_length_remainder = file_or_directory.length.divmod(ROW_LENGTH)
column_length += 1 unless column_length_remainder.zero?

groups = grouped_files_or_directories(file_or_directory, column_length)
max_lengths = create_max_lengths(groups)

transposed_groups = groups.transpose
transposed_groups.each do |group|
  group.compact.each_with_index { |item, index| printf("%-#{max_lengths[index]}s   ", item) }
  puts
end
