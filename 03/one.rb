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

input = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)
input = input.join('')
matches = input.scan(/(mul\(\d+,\d+\))/).map { _1[0] }

res = 0
matches.each do |exp|
  re = exp.match(/mul\((\d+),(\d+)\)/)
  val = re.to_a[1..].map(&:to_i).reduce(1) { _1 * _2 }
  res += val
end
p res

# 30534327 no
# answer: 188192787
