#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative './file_name'
require_relative './file_detail'

options = []
is_details = nil

OptionParser.new do |opts|
  opts.on('-a') { |_v| options << :all_files }
  opts.on('-r') { |_v| options << :reverse }
  opts.on('-l') { |is_option| is_details = is_option }
end.parse!

if is_details
  file_detail = FileDetail.new
  file_detail.run_ls(options)
else
  file_name = FileName.new
  file_name.run_ls(options)
end
