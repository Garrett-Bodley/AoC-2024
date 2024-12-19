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

patterns = lines.first.split(', ').sort
designs = lines[2..]

memo = {}

def possible?(idx, design, patterns, memo)
  return true if  idx == design.length
  return memo[design[idx..]] if memo[design[idx..]]

  res = patterns.any? do |pattern|
    next unless design[idx...idx + pattern.length] == pattern
    possible?(idx + pattern.length, design, patterns, memo)
  end
  memo[design[idx..]] = res
end

res = 0
designs.each do |design|
  res += 1 if possible?(0, design, patterns, memo)
end
puts res

# answer: 238
