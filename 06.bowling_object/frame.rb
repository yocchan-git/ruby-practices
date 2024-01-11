# frozen_string_literal: true

class Frame
  def create_frames(formatted_scores)
    @frames = formatted_scores.each_slice(2).to_a

    if @frames.size > 10
      set_strikes
      last_frame = create_last_frame

      @frames = [*@frames[0..8], last_frame]
    end

    @frames
  end

  private

  def set_strikes
    @first_strike = @frames[9][0] == 10
    @second_strike = @frames[10][0] == 10
  end

  def create_last_frame
    if @first_strike && @second_strike
      [10, 10, @frames[11][0]]
    elsif @first_strike
      [10, @frames[10][0], @frames[10][1]]
    else
      [@frames[9][0], @frames[9][1], @frames[10][0]]
    end
  end
end
