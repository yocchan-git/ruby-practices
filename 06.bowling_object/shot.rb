# frozen_string_literal: true

class Shot
  def scores(original_scores)
    shots = []
    original_scores.each do |s|
      if s == 'X'
        shots << 10
        shots << 0
      else
        shots << s.to_i
      end
    end
    shots
  end
end
