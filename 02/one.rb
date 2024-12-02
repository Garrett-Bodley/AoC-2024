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
  prev = vals.first
  (1...vals.length).each do |i|
    cur = vals[i]
    return false if cur <= prev

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
  diff = vals[0] - vals[1]
  return false if diff == 0

  if diff < 0
    return increasing?(vals)
  else
    return decreasing?(vals)
  end
end

res = 0
lines.each do |line|
  res += 1 if safe?(line)
end
puts res

# answer: 483
