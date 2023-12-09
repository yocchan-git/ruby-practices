#!/usr/bin/env ruby

require 'date'

class Calendar
    def initialize
        @date = Date.today
        @first_date = Date.new(@date.year, @date.month, 1)
        @last_date = Date.new(@date.year, @date.month, -1)
    end

    def show_date
        days = "     #{@date.month}月 #{@date.year}     \n日 月 火 水 木 金 土\n"
        dates = @last_date.day - @first_date.day

        # 1日目は自分で決める感じ
        # 曜日によって空白文字を決める
        empty = ["", "     ", "     ", "       ", "        ", "                ", "                  "]
        if @first_date.saturday?
            days << "#{empty[6]}1\n"
        else
            days << "#{empty[@first_date.wday]}1 "
        end

        dates.times.each do |day|
            that_day = Date.new(@date.year, @date.month, day + 2)
            if that_day.saturday?
                days << "#{that_day.strftime('%e')} \n"
            else
                days << "#{that_day.strftime('%e')} "
            end
        end
        days
    end
end

calendar = Calendar.new
puts calendar.show_date