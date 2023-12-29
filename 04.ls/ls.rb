#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require "etc"

ROW_LENGTH = 3
NORMAL_PERMISSIONS_DIGITS = -3..-1
SPECIAL_PERMISSION_DIGIT = -4
OTHER_PERMISSION_MOVE = -1
HARD_LINKS = 1
SIZE = 4

opt = OptionParser.new
option = nil
opt.on('-l [VAL]') { |_v| option = :detail }
opt.parse!(ARGV)

def create_file_details(file_name)
  file_stat = File::Stat.new(file_name)
  permissions = file_stat.mode

  permission_digits = sprintf('%o', permissions)[NORMAL_PERMISSIONS_DIGITS]
  special_digits = sprintf('%o', permissions)[SPECIAL_PERMISSION_DIGIT]

  symbolic_permissions = 
    permission_digits.chars.map do |char|
      case char
      when '0' then '---'
      when '1' then '--x'
      when '2' then '-w-'
      when '3' then '-wx'
      when '4' then 'r--'
      when '5' then 'r-x'
      when '6' then 'rw-'
      when '7' then 'rwx'
      end
    end.join

  file_type = 
    case
      when file_stat.file? then '-'
      when file_stat.directory? then 'd'
      when file_stat.chardev? then 'c'
      when file_stat.blockdev? then 'b'
      when file_stat.symlink? then 'l'
      when file_stat.socket? then 's'
      when file_stat.pipe? then 'p'
      else '?'
    end

  special_permission = 
    case special_digits
      when '1' then 't'
      when '2' then 's'
      when '4' then 's'
      else ''
    end

  unless special_permission.empty?
    if symbolic_permissions[OTHER_PERMISSION_MOVE] == 'x'
      symbolic_permissions[OTHER_PERMISSION_MOVE] = special_permission
    else
      symbolic_permissions[OTHER_PERMISSION_MOVE] = special_permission.upcase
    end
  end

  @total += file_stat.blocks
  @type_and_permissions << "#{file_type}#{symbolic_permissions}"
  @hard_link << file_stat.nlink.to_s
  @owner << Etc.getpwuid(file_stat.uid).name
  @group << Etc.getgrgid(file_stat.gid).name
  @size << file_stat.size.to_s
  @created_at << file_stat.birthtime.strftime("%m %d %H:%M")
  @file_name << file_name
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

file_or_directory = Dir.entries('.').reject { |file| file.match(/^\./) }.sort

if option == :detail
  @file_or_directory_details = []
  @total = 0
  @type_and_permissions = []
  @hard_link = []
  @owner = []
  @group = []
  @size = []
  @created_at = []
  @file_name = []

  file_or_directory.each do |file|
    create_file_details(file)
  end

  @file_or_directory_details = [@type_and_permissions, @hard_link, @owner, @group, @size, @created_at, @file_name]
  max_lengths = create_max_lengths(@file_or_directory_details)

  puts "total #{@total}"
  transposed_groups = @file_or_directory_details.transpose
  transposed_groups.each do |group|
    group.compact.each_with_index do |item, index| 
      if index == HARD_LINKS || index == SIZE
        print item.rjust(max_lengths[index])
      else
        print item.ljust(max_lengths[index])
      end
      print "  "
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
