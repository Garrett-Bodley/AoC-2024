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

def permute(rsum, idx, nums, vals)
  if idx >= nums.length
    vals << rsum
    return
  end
  a = rsum + nums[idx]
  b = rsum * nums[idx]
  permute(a, idx + 1, nums, vals)
  permute(b, idx + 1, nums, vals)
end

def possible?(target, nums)
  vals = []
  permute(nums.first, 1, nums, vals)
  vals.any? { _1 == target }
end

res_arr = []
lines.each do |line|
  res_arr << line if possible?(line.first, line[1..])
end

res = 0
res_arr.each do |arr|
  res += arr.first
end
p res
