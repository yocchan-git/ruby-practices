#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a
point = 0
throw_third_last_frame = false

if frames.size > 10
  first_strike = frames[9][0] == 10
  second_strike = frames[10][0] == 10

  last_frame = if first_strike && second_strike
                 [10, 10, frames[11][0]]
               elsif first_strike
                 [10, frames[10][0], frames[10][1]]
               else
                 [frames[9][0], frames[9][1], frames[10][0]]
               end

  frames = frames[0..8]
  throw_third_last_frame = true
  point += last_frame.sum
end

frames.each_with_index do |frame, i|
  strike = frame[0] == 10
  spare = frame.sum == 10
  next_frame = i + 1
  previous_frame = i - 1

  if throw_third_last_frame && i == 8
    if strike
      point += 10 + last_frame[0] + last_frame[1]
      next
    elsif spare
      point += 10 + last_frame[0]
      next
    end
  end

  if strike
    point += 10 + frames[next_frame].sum
    point += frames[next_frame][0] if frames[previous_frame][0] == 10
  elsif spare
    point += 10 + frames[next_frame][0]
  else
    point += frame.sum
  end
end

puts point
