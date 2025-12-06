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
antinodes = {}

nodes.each do |x, y, char|
  antinodes[[x, y]] = true
  dict[char].each do |neighbor|
    nx = neighbor.first
    ny = neighbor.last
    next if nx == x && ny == y
    x_offset = x - nx
    y_offset = y - ny

    new_x = x + x_offset
    new_y = y + y_offset

    while new_x >= 0 && new_x < width && new_y >= 0 && new_y < height
      antinodes[[new_x, new_y]] = true if matrix[new_y][new_x] != char
      new_x += x_offset
      new_y += y_offset
    end

    new_x = x - x_offset
    new_y = y - y_offset

    while new_x >= 0 && new_x < width && new_y >= 0 && new_y < height
      antinodes[[new_x, new_y]] = true if matrix[new_y][new_x] != char
      new_x -= x_offset
      new_y -= y_offset
    end

  end
end

antinodes.each_key do |x, y|
  matrix[y][x] = '#' if matrix[y][x] == '.'
  p [x, y] if matrix[y][x].match?(/[0A]/)
end
matrix.each { puts _1.join('') }
p antinodes.length
