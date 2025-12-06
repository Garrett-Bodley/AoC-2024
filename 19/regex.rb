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

patterns_raw, designs = File.open(FILE_PATH, File::RDONLY).read.split("\n\n")
patterns = patterns_raw.split(', ')
pattern = /^(#{patterns.join("|")})+$/m
puts designs.scan(pattern).count
