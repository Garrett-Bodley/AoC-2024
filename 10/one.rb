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
matrix = lines.map do |line|
  line.split('').map do |char|
    if char == '.'
      -1
    else
      char.to_i
    end
  end
end

heads = []

matrix.each_with_index do |row, y|
  row.each_with_index do |val, x|
    heads << [x, y] if val == 0
  end
end

def peak_count(head, matrix)
  stack = [head]
  height = matrix.length
  width = matrix.first.length
  res = 0
  visited = {}

  until stack.empty?
    cur = stack.pop
    x, y = cur.first, cur.last
    if matrix[y][x] == 9
      res += 1 unless visited[[x, y]]
      visited[[x, y]] = true
      next
    end

    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |x_offset, y_offset|
      new_x = x + x_offset
      new_y = y + y_offset
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != matrix[y][x] + 1

      stack << [new_x, new_y]
    end
  end
  return res
end
# p heads.count
res = 0
heads.each do |head|
  count = peak_count(head, matrix)
  # p count
  res += count
end

p res
