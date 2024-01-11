# frozen_string_literal: true

require './frame'
require './shot'

class Game
  def initialize(score)
    @original_scores = score.split(',')
    @shot = Shot.new
    @frame = Frame.new
    create_formatted_scores
  end

  def calculate_total_point
    point = 0
    @frames.each_with_index do |frame, frame_number|
      set_terms(frame, frame_number)

      if @strike && @throw_before_last_frame
        point += 10 + @next_frame[0] + @next_frame[1]
        point += @next_frame[0] if @previous_frame[0] == 10 && @throw_after_first_frame
      elsif @spare
        point += 10 + @next_frame[0]
      else
        point += frame.sum
      end
    end

    point
  end

  private

  def create_formatted_scores
    formatted_scores = @shot.scores(@original_scores)
    @frames = @frame.create_frames(formatted_scores)
  end

  def set_terms(frame, frame_number)
    @strike = frame[0] == 10
    @spare = !@strike && frame.sum == 10

    @next_frame = @frames[frame_number + 1]
    @previous_frame = @frames[frame_number - 1]

    @throw_after_first_frame = !frame_number.zero?
    @throw_before_last_frame = frame_number != 9
  end
end
