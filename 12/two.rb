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

inflated_matrix = []
lines.each do |line|
  inflated_line = line.split("").map { |val| [val, val] }.flatten
  inflated_matrix += [inflated_line, inflated_line]
end

if inflated_matrix.length != lines.length * 2
  puts "wtf"
end

if inflated_matrix.first.length != lines.first.length * 2
  puts "wtf"
end

PERIM_OFFSETS = [[1, 0], [0, 1], [-1, 0], [0, -1]]
def side_count(x, y, matrix)
  color = matrix[y][x]
  stack = [[x, y]]
  height = matrix.length
  width = matrix.first.length

  dir = 0

  # spin around until we're pointing the wrong way
  loop do
    offset = PERIM_OFFSETS[dir]
    x_offset, y_offset = offset.first, offset.last
    new_x, new_y = x + x_offset, y + y_offset
    break if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color
    dir = (dir + 1) % 4
  end

  # spin around until we're pointing the right way
  loop do
    offset = PERIM_OFFSETS[dir]
    x_offset, y_offset = offset.first, offset.last
    new_x, new_y = x + x_offset, y + y_offset
    break if new_x >= 0 && new_x < width && new_y >= 0 && new_y < height && matrix[new_y][new_x] == color
    dir = (dir + 1) % 4
  end

  # how many directions were bad anyway?
  bad_dirs = [0, 1, 2, 3].count do |idx|
    offset = PERIM_OFFSETS[idx]
    x_offset, y_offset = offset.first, offset.last
    new_x, new_y = x + x_offset, y + y_offset
    new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color
  end

  # are we on a corner?
  if bad_dirs == 2
    # yes
    sides = 1
  elsif bad_dirs == 1
    # no
    sides = 0
  else
    puts "wtf"
  end

  visited = {}

  until stack.empty?
    cur = stack.pop
    x, y = cur.first, cur.last
    next if visited[[x, y]]
    visited[[x, y]] = true

    # let's try turning left!
    dir = (dir - 1) % 4
    offset = PERIM_OFFSETS[dir]
    x_offset, y_offset = offset.first, offset.last
    new_x = x + x_offset
    new_y = y + y_offset

    # can we go left?
    if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color
      # no! let's try going straight!
      dir = (dir + 1) % 4
      offset = PERIM_OFFSETS[dir]
      x_offset, y_offset = offset.first, offset.last
      new_x = x + x_offset
      new_y = y + y_offset

      # Can we go straight?
      if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color
        # no we cannot! nvm let's try a right turn!
        dir = (dir + 1) % 4
        offset = PERIM_OFFSETS[dir]
        x_offset, y_offset = offset.first, offset.last
        new_x = x + x_offset
        new_y = y + y_offset

        # Did that work?
        if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != color
          # Singular point degenerate case womp womp
          return [4, visited]
        end

        # turning right here!
        sides += 1
        stack << [new_x, new_y]
      else
        # going straight here!
        stack << [new_x, new_y]
      end

    else
      # turning left here :D
      sides += 1
      stack << [new_x, new_y]
    end
  end
  [sides, visited]
end

def flood_fill(x, y, matrix, perim_set)
  area = 0
  new_sides = 0

  flood_set = {}
  inner_perim_set = {}

  stack = [[x, y]]
  flood_set[[x, y]] = true
  color = matrix[y][x]

  height = matrix.length
  width = matrix.first.length

  until stack.empty?
    cur = stack.pop
    area += 1
    x, y = cur.first, cur.last
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |x_offset, y_offset|
      new_x = x + x_offset
      new_y = y + y_offset
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || flood_set[[new_x, new_y]]

      if matrix[new_y][new_x] != color && !inner_perim_set[[new_x, new_y]]

        outer_border = [[-1, 0], [1, 0], [0, -1], [0, 1]].any? do |x_offset2, y_offset2|
          new_x2, new_y2 = new_x + x_offset2, new_y + y_offset2
          perim_set[[new_x2, new_y2]]
        end
        unless outer_border
          inner_sides, new_perim = side_count(new_x, new_y, matrix)
          # p inner_sides
          new_sides += inner_sides
          new_perim.each_key { |k| inner_perim_set[k] = true }
        end
      end
      next if matrix[new_y][new_x] != color

      flood_set[[new_x, new_y]] = true
      stack << [new_x, new_y]
    end
  end

  return [area, new_sides, flood_set]
end

# inflated_matrix.each { puts _1.join('')}

visited = {}

res = 0
inflated_matrix.each_with_index do |row, y|
  row.each_with_index do |val, x|
    next if visited[[x, y]]

    sides, perim_set = side_count(x, y, inflated_matrix)
    area, interior_sides, flood_set = flood_fill(x, y, inflated_matrix, perim_set)
    flood_set.each_key { |key| visited[key] = true }

    new_price =  (sides + interior_sides) * area / 4
    binding.pry if (sides + interior_sides).odd?
    # puts [inflated_matrix[y][x], area / 4, sides + interior_sides].join(" ")
    res += new_price
  end
end
p res

# 869514 nope, too low!
# 891230 nope, too high!
# 891230 nope
# 891354 no i want to die
# answer: 891106
