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

def increasing?(vals)
  removed = false

  prev = vals.first
  (1...vals.length).each do |i|
    cur = vals[i]
    if cur <= prev
      return false if removed

    end

    diff = (cur - prev).abs
    return false if diff < 1 || diff > 3

    prev = cur
  end
  true
end

def decreasing?(vals)
  prev = vals.first
  (1...vals.length).each do |i|
    cur = vals[i]
    return false if cur >= prev

    diff = (cur - prev).abs
    return false if diff < 1 || diff > 3
  
    prev = cur
  end
  true
end

def safe?(line)
  vals = line.split(/\s+/).map(&:to_i)
  (0...vals.length).each do |i|
    sub_array = vals[0...i] + vals[i + 1..]
    return true if increasing?(sub_array) || decreasing?(sub_array)
  end
  false
end

res = 0
lines.each_with_index do |line, idx|
  if safe?(line)
    res += 1
  end
end
puts res

# 511 no
# 543 no
# 511 no
# answer: 528
