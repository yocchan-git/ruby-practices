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

  frames = [*frames[0..8], last_frame]
  throw_third_last_frame = true
end

frames.each_with_index do |frame, i|
  strike = frame[0] == 10
  spare = !strike && frame.sum == 10
  next_frame = frames[i + 1]
  previous_frame = frames[i - 1]
  throw_first_frame = i.zero?
  throw_last_frame = i == 9

  if throw_last_frame && throw_third_last_frame
    point += last_frame.sum
    next
  end

  if strike
    point += 10 + next_frame[0] + next_frame[1]
    point += next_frame[0] if previous_frame[0] == 10 && !throw_first_frame
  elsif spare
    point += 10 + next_frame[0]
  else
    point += frame.sum
  end
end

puts point
