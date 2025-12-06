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
nums = lines.first.split.map(&:to_i)

def blink(num)
  # If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
  if num == 0
    return [1]
  # If the stone is engraved with a number that has an even number of digits, it is replaced by two stones.
  # The left half of the digits are engraved on the new left stone,
  # and the right half of the digits are engraved on the new right stone.
  # (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
  elsif num.to_s.length.even?
    s = num.to_s
    half = s.length / 2
    left = s[0...half]
    right = s[half..]
    return [left.to_i, right.to_i]

  # If none of the other rules apply, the stone is replaced by a new stone;
  # the old stone's number multiplied by 2024 is engraved on the new stone.
  else
    return [num * 2024]
  end
end

tally = nums.tally
75.times do
  new_tally = Hash.new { |hash, key| hash[key] = 0}
  tally.each_key do |val|
    turns_into = blink(val)
    turns_into.each do |new_val|
      new_tally[new_val] += tally[val]
    end
  end
  tally = new_tally
end

p tally.values.sum
