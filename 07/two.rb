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
lines.map! { _1.split(/:?\s+/).map(&:to_i) }

# DFS true : false
def possible?(rsum, idx, nums, target)
  if idx >= nums.length
    return rsum == target
  elsif rsum > target
    return false
  end

  a = rsum + nums[idx]
  b = rsum * nums[idx]
  c = (rsum.to_s + nums[idx].to_s).to_i
  possible?(a, idx + 1, nums, target) || possible?(b, idx + 1, nums, target) || possible?(c, idx + 1, nums, target)
end

res_arr = []
lines.each do |line|
  res_arr << line if possible?(line[1], 1, line[1...], line.first)
end

res = 0
res_arr.each do |arr|
  res += arr.first
end
p res
