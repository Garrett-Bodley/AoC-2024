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

matrix = lines.map { |line| line.split('') }

visited = {}
res = {}

logging = matrix.map do |line|
  line.map do |char|
    if char == '#'
      '#'
    elsif char == '^'
      '+'
    else
      '.'
    end
  end
end

start = [nil, nil]
matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    if char == '^'
      start[0] = x
      start[1] = y
      res["#{x},#{y}"] = true
    end
  end
end

OFFSETS = [
  [0, -1], #N
  [1, 0],  #E
  [0, 1],  #S
  [-1, 0]  #W
]

stack = [start]

width = matrix.first.length
height = matrix.length

offset_idx = 0
until stack.empty?
  # p stack
  x, y = stack.pop
  x_offset, y_offset = OFFSETS[offset_idx]
  new_x = x + x_offset
  new_y = y + y_offset
  next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height

  if matrix[new_y][new_x] == '#'
    offset_idx = (offset_idx + 1) % 4
    next if visited["#{x},#{y},#{offset_idx}"]

    logging[y][x] = '+'
    stack << [x, y]
  else
    next if visited["#{new_x}, #{new_y},#{offset_idx}"]

    logging[new_y][new_x] = (offset_idx.odd? ? '-' : '|')
    logging[new_y][new_x] = '+' if  res["#{new_x},#{new_y}"]

    visited["#{new_x}, #{new_y},#{offset_idx}"] = true
    res["#{new_x},#{new_y}"] = true

    # logging[new_y][new_x] = 'X'
    stack << [new_x, new_y]
  end
end

def check(matrix, start)
  visited = {}
  visited["#{start.first},#{start.last},0"]

  height = matrix.length
  width = matrix.first.length

  stack = [start]
  offset_idx = 0
  until stack.empty?
    cur = stack.pop
    x, y = cur.first, cur.last

    x_offset = OFFSETS[offset_idx].first
    y_offset = OFFSETS[offset_idx].last

    new_x = x + x_offset
    new_y = y + y_offset

    next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height
    if matrix[new_y][new_x] == '#'
      offset_idx = (offset_idx + 1) % 4
      stack << [x, y]
    else
      return true if visited["#{new_x},#{new_y},#{offset_idx}"]
      visited["#{new_x},#{new_y}"] = true
      stack << [new_x, new_y]
    end
  end
  return false
end


# logging.each_with_index do |line, y|
#   line.each_with_index do |char, x|
#     # binding.pry if y == 8 && x == 7
#     if char.match?(/[-|+]/)
#       convert = [[-1, 0], [1, 0], [0, -1], [0, 1]].any? do |x_offset, y_offset|
#         new_x = x + x_offset
#         new_y = y + y_offset
#         if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || !logging[new_y][new_x].match?(/[-|+]/)
#           false
#         else
#           true
#         end
#       end
#       binding.pry if y == 8 && x == 7
#       logging[y][x] = '+' if convert
#     end
#   end
# end

logging.each { puts _1.join('') }

# val = 0
# logging.each do |line|
#   line.each do |char|
#     val += 1 if char == 'X'
#   end
# end
# p val

# answer: 4663
