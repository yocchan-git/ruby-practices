#!/usr/bin/env ruby
# frozen_string_literal: true

require './game'

score = ARGV[0]
bowling = Game.new(score)
puts bowling.calculate_total_point
