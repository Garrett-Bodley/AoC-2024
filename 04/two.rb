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

matrix = []
lines.each do |line|
  matrix << line.split('')
end

as = []

matrix.each_with_index do |line, y|
  line.each_with_index do |char, x|
    as << [x, y] if char == 'A'
  end
end

offsets = [
  # M       S         M       S
  # S       M         S       M
  # M       S         S       M
  # S       M         M       S
  [[-1, -1, "M"], [1, 1, "S"], [-1, 1, "M"], [1, -1, "S"]],
  [[-1, -1, "S"], [1, 1, "M"], [-1, 1, "S"], [1, -1, "M"]],
  [[-1, -1, "M"], [1, 1, "S"], [-1, 1, "S"], [1, -1, "M"]],
  [[-1, -1, "S"], [1, 1, "M"], [-1, 1, "M"], [1, -1, "S"]]
]

height = matrix.length
width = matrix.first.length

res = 0
as.each do |x, y|
  offsets.each do |offset|
    found = offset.all? do |x_offset, y_offset, char|
      new_x = x + x_offset
      new_y = y + y_offset
      if new_x >= 0 && new_x < width && new_y >= 0 && new_y < height && matrix[new_y][new_x] == char
        true
      else
        false
      end
    end
    if found
      res += 1
      break
    end
  end
end
p res
