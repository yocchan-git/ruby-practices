#!/usr/bin/env ruby

require 'date'
require 'optparse'

class Calendar
    def today
        @date = Date.today
    end

    def enter_options(year, month = Date.today.month)
        year = Date.today.year if year.nil?
        @date = Date.new(year, month, 1)
    end

    def show_date
        first_date = Date.new(@date.year, @date.month, 1)
        last_date = Date.new(@date.year, @date.month, -1)

        days = "     #{@date.month}月 #{@date.year}     \n日 月 火 水 木 金 土\n"
        dates = (first_date..last_date).to_a

        dates.each do |date|
            if date.day == 1 && date == Date.today
                days << "#{space_count(date)}\e[30m\e[47m 1\e[0m "
            elsif date.day == 1
                days << "#{space_count(date)} 1 "
            elsif date == Date.today
                days << "\e[30m\e[47m#{date.strftime('%e')}\e[0m"
            else
                days << "#{date.strftime('%e')} "
            end
            days << "\n" if date.saturday?
        end
        days
    end

    def space_count(date)
        "   " * date.wday
    end
end

month = nil
year = nil
OptionParser.new do |opts|
    opts.on('-m VAL', Integer) { |number| month = number }
    opts.on('-y VAL', Integer) { |number| year = number }
end.parse!

calendar = Calendar.new
if month.nil?
    calendar.today
else
    calendar.enter_options(year, month)
end
puts calendar.show_date
