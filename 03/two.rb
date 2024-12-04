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
matches = input.scan(/(mul\(\d+,\d+\)|don't\(\)|do\(\))/).map { _1[0] }

res = 0
enable = true
matches.each_with_index do |exp, idx|
  case exp
  when "don't()"
    enable = false
  when "do()"
    enable = true
  else
    next unless enable
    re = exp.match(/mul\((\d+),(\d+)\)/)
    val = re.to_a[1..].map(&:to_i).reduce(1) { _1 * _2 }
    res += val
  end
end

p res
# answer: 113965544
