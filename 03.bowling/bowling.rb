#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'

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

frames = []
shots.each_slice(2) do |s|
  frames << s
end

def delete_frames(frames, first_number, end_number)
  (first_number..end_number).to_a.each_index do |i|
    frames.delete_at(end_number - i)
  end
end

point = 0
flg = false
# １０フレーム目で３投投げた時の処理
if frames[10]
  if frames[11]
    # ２投ともストライクの時
    last_frame = [10, 10, frames[11][0]]
    delete_frames(frames, 9, 11)
  elsif frames[9][0] == 10
    # １投目がストライクの時
    last_frame = [10, frames[10][0], frames[10][1]]
    delete_frames(frames, 9, 10)
  else
    # スペアで３投目がある時
    last_frame = [frames[9][0], frames[9][1], frames[10][0]]
    delete_frames(frames, 9, 10)
  end

  flg = true
  point += last_frame.sum
end

frames.each_with_index do |frame, i|
  # １０フレームで３投投げる　&& ９フレーム目がストライクorスペア
  if flg && i == 8
    if frame[0] == 10
      point += (10 + last_frame[0] + last_frame[1])
      next
    elsif frame.sum == 10
      point += (10 + last_frame[0])
      next
    end
  end

  if frame[0] == 10 # strike
    point += (10 + frames[i + 1].sum)
    point += frames[i + 1][0] if frames[i - 1][0] == 10
  elsif frame.sum == 10 # spare
    point += (10 + frames[i + 1][0])
  else
    point += frame.sum
  end
end

puts point
