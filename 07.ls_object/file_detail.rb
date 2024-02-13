# frozen_string_literal: true

require 'etc'
require_relative './file_formatter'

class FileDetail
  NORMAL_PERMISSIONS_DIGITS = -3..-1
  SPECIAL_PERMISSION_DIGIT = -4
  SETUID_DIGIT = -7
  SETGID_DIGIT = -4
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

  def initialize(file_name)
    @file_name = file_name
    @file_stat = symlink_file? ? File.lstat(file_name) : File::Stat.new(file_name)
  end

  def blocks
    @file_stat.blocks
  end

  def file_type
    return 'l' if symlink_file?
    return '-' if @file_stat.file?
    return 'd' if @file_stat.directory?
    return 'c' if @file_stat.chardev?
    return 'b' if @file_stat.blockdev?
    return 's' if @file_stat.socket?
    return 'p' if @file_stat.pipe?

    '?'
  end

  def permission
    permissions = @file_stat.mode

    permission_digits = format('%o', permissions)[NORMAL_PERMISSIONS_DIGITS]
    special_digits = format('%o', permissions)[SPECIAL_PERMISSION_DIGIT]

    @symbolic_permissions = permission_digits.chars.map { |char| PERMISSION_SYMBOLICS[char] }.join

    replace_permissions_with_special(special_digits) if special_digits != '0'

    @symbolic_permissions
  end

  def hard_link
    @file_stat.nlink.to_s
  end

  def owner
    Etc.getpwuid(@file_stat.uid).name
  end

  def group
    Etc.getgrgid(@file_stat.gid).name
  end

  def file_size
    @file_stat.size.to_s
  end

  def updated_time
    month_and_date = @file_stat.mtime.strftime('%m %d').gsub(/\b0(\d)\b/, ' \1')
    hour_and_minutes = @file_stat.mtime.strftime('%H:%M')
    "#{month_and_date} #{hour_and_minutes}"
  end

  def name
    symlink_file? ? "#{@file_name} -> #{File.readlink(@file_name)}" : @file_name
  end

  private

  def symlink_file?
    File.lstat(@file_name).symlink?
  end

  def replace_permissions_with_special(special_digits)
    case special_digits
    when '1'
      replace_special_permission(OTHER_PERMISSION_MOVE, 't')
    when '2'
      replace_special_permission(SETGID_DIGIT, 's')
    when '4'
      replace_special_permission(SETUID_DIGIT, 's')
    end
  end

  def replace_special_permission(position, permission_symbolic)
    @symbolic_permissions[position] = @symbolic_permissions[position] == 'x' ? permission_symbolic : permission_symbolic.upcase
  end
end
