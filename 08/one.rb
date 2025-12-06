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

matrix = lines.map { _1.split('') }
matrix.each { p _1 }

dict = Hash.new {|hash,  key| hash[key] = [] }
nodes = []
matrix.each_with_index do |line, y|
  line.each_with_index do |char, x|
    next if char == '.'

    dict[char] << [x, y]
    nodes << [x, y, char]
  end
end

height = matrix.length
width = matrix.first.length
visited = {}
antinodes = {}

nodes.each do |x, y, char|
  # visited[[x, y]] = true
  dict[char].each do |neighbor|
    nx = neighbor.first
    ny = neighbor.last
    next if nx == x && ny == y
    x_offset = x - nx
    y_offset = y - ny

    new_x1 = x + x_offset
    new_y1 = y + y_offset

    if new_x1 >= 0 && new_x1 < width && new_y1 >= 0 && new_y1 < height && (new_x1 != nx && new_y1 != ny)
      antinodes[[new_x1, new_y1]] = true
    end

    new_x2 = x - x_offset
    new_y2 = y - y_offset

    if new_x2 >= 0 && new_x2 < width && new_y2 >= 0 && new_y2 < height && (new_x2 != nx && new_y2 != ny)
      antinodes[[new_x2, new_y2]] = true
    end

  end
end

antinodes.each_key do |x, y|
  matrix[y][x] = '#' if matrix[y][x] == '.'
  p [x, y] if matrix[y][x].match?(/[0A]/)
end
matrix.each { puts _1.join('') }
p antinodes.length
# nodes go in [x_offset, y_offset]

# ....
# .0..
# ..0.
# ....
