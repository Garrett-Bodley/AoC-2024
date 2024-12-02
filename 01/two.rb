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

left = []
right = []
lines.each do |line|
  fields = line.split(/\s+/).map(&:to_i)
  left << fields[0]
  right << fields[1]
end

right_map = Hash.new { |hash, key| hash[key] = 0}
right.each do |val|
  right_map[val] += 1
end

res = 0

left.each do |val|
  res += val * right_map[val]
end
p res

# answer: 19437052
