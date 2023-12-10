#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def today
  Date.today
end

def enter_options(year, month = Date.today.month)
  year = Date.today.year if year.nil?
  Date.new(year, month, 1)
end

def space_count(date)
  '   ' * date.wday
end

def show_calendar(setting_date)
  first_date = Date.new(setting_date.year, setting_date.month, 1)
  last_date = Date.new(setting_date.year, setting_date.month, -1)

  days = "     #{setting_date.month}月 #{setting_date.year}     \n日 月 火 水 木 金 土\n"
  dates = (first_date..last_date).to_a

  dates.each do |date|
    days << if date.day == 1 && date == Date.today
              "#{space_count(date)}\e[30m\e[47m 1\e[0m "
            elsif date.day == 1
              "#{space_count(date)} 1 "
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

setting_date = if month.nil?
                 today
               else
                 enter_options(year, month)
               end
puts show_calendar(setting_date)
