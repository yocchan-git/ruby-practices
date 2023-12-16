#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def create_options_date_instance(year, month)
  year = Date.today.year if year.nil?
  Date.new(year, month, 1)
end

def forward_first_day_space(date)
  '   ' * date.wday
end

def show_calendar(setting_date)
  first_date = Date.new(setting_date.year, setting_date.month, 1)
  last_date = Date.new(setting_date.year, setting_date.month, -1)

  days = "     #{setting_date.month}月 #{setting_date.year}     \n日 月 火 水 木 金 土\n"
  dates = (first_date..last_date).to_a

  dates.each do |date|
    days << if date.day == 1 && date == Date.today
              "#{forward_first_day_space(date)}\e[30m\e[47m 1\e[0m "
            elsif date.day == 1
              "#{forward_first_day_space(date)} 1 "
            elsif date == Date.today
              "\e[30m\e[47m#{date.strftime('%e')}\e[0m "
            else
              "#{date.strftime('%e')} "
            end
    days << "\n" if date.saturday?
  end
  days
end

month = nil
year = nil
OptionParser.new do |opts|
  opts.on('-m VAL', Integer) { |number| month = number }
  opts.on('-y VAL', Integer) { |number| year = number }
end.parse!

setting_date = month.nil? ? Date.today : create_options_date_instance(year, month)
puts show_calendar(setting_date)
