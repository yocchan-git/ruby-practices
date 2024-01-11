#!/usr/bin/env ruby
# frozen_string_literal: true

require './game'

score = ARGV[0]
game = Game.new(score)
puts game.calculate_total_point
