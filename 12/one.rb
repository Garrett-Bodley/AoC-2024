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
matrix = lines.map { |line| line.split("") }

def flood_fill(x, y, matrix, visited)
  perim = 0
  area = 0

  stack = [[x, y]]
  visited[[x, y]] = true

  color = matrix[y][x]

  height = matrix.length
  width = matrix.first.length

  until stack.empty?
    # p stack
    cur = stack.pop
    area += 1
    x, y = cur.first, cur.last
    new_perim = 4

    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |x_offset, y_offset|
      new_x = x + x_offset
      new_y = y + y_offset
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color

      new_perim -= 1
      next if visited[[new_x, new_y]]

      visited[[new_x, new_y]] = true
      stack << [new_x, new_y]
    end
    perim += new_perim
  end

  return [perim, area]
end

visited = Hash.new

res = 0
matrix.each_with_index do |line, y|
  line.each_with_index do |color, x|
    next if visited[[x, y]]
    perim, area = flood_fill(x, y, matrix, visited)
    res += perim * area
  end
end
p res
