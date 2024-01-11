# frozen_string_literal: true

class Shot
  def scores(original_scores)
    @shots = []
    original_scores.each { |original_score| create_score(original_score) }

    @shots
  end

  private

  def create_score(original_score)
    if original_score == 'X'
      @shots << 10
      @shots << 0
    else
      @shots << original_score.to_i
    end
  end
end
