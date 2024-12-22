# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

class RNG
  attr_accessor :state
  def initialize(seed)
    @state = seed
  end

  def next
    @state = ((@state << 6) ^ @state) & 16777215
    @state = ((@state >> 5) ^ @state) & 16777215
    @state = ((@state << 11) ^ @state) & 16777215
  end
end

res = 0
lines.each do |line|
  rng = RNG.new(line.to_i)
  2000.times { rng.next }
  res += rng.state
end

p res
# answer: 20441185092
