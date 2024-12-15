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

text = File.open(FILE_PATH, File::RDONLY).read

board, moves_raw = text.split("\n\n")

matrix = board.split("\n").map { _1.split("") }
moves = moves_raw.split("\n").join.split("")

robot = []

matrix.each_with_index do |row, y|
  row.each_with_index do |val, x|
    if val == "@"
      robot = [x, y]
      break
    end
  end
end

OFFSETS = {
  "^" => [0, -1],
  "v" => [0, 1],
  "<" => [-1, 0],
  ">" => [1, 0]
}

WTF = Class.new(StandardError)

def shift_stones(x, y, offset, matrix)
  x_offset, y_offset = offset

  new_x = x + x_offset
  new_y = y + y_offset

  while matrix[new_y][new_x] == 'O'
    new_x += x_offset
    new_y += y_offset
  end
  return false if matrix[new_y][new_x] == '#'
  raise WTF if matrix[new_y][new_x] != "."

  matrix[new_y][new_x] = "O"
  matrix[y][x] = "."
  matrix[y + y_offset][x + x_offset] = '@'
  true
end

x, y = robot
moves.each do |dir|
  x_offset, y_offset = OFFSETS[dir]

  new_x = x + x_offset
  new_y = y + y_offset

  case matrix[new_y][new_x]
  when "."
    matrix[y][x] = '.'
    matrix[new_y][new_x] = '@'
    x, y = new_x, new_y
  when "#"
    next
  when "O"
    if shift_stones(x, y, OFFSETS[dir], matrix)
      x, y = new_x, new_y
    end
  else
    raise WTF
  end
end

res = 0
matrix.each_with_index do |row, y|
  row.each_with_index do |val, x|
    next unless val == 'O'
    res += 100 * y + x
  end
end
p res
