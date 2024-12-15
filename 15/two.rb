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

WTF = Class.new(StandardError)

text = File.open(FILE_PATH, File::RDONLY).read
board, moves_raw = text.split("\n\n")

small_matrix = board.split("\n").map { _1.split("") }
moves = moves_raw.split("\n").join.split("")

matrix = []

small_matrix.each do |row|
  new_row = []
  row.each do |char|
    case char
    when "#"
      new_row += ['#', '#']
    when "O"
      new_row += ['[', ']']
    when "."
      new_row += ['.', '.']
    when '@'
      new_row += ['@', '.']
    else
      raise WTF
    end
  end
  matrix << new_row
end

# too lazy to think abt extracting x,y when inflating the matrix lol
robot = []
matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    next unless char == "@"
    robot = [x, y]
    break
  end
end

OFFSETS = {
  "^" => [0, -1],
  "v" => [0, 1],
  "<" => [-1, 0],
  ">" => [1, 0]
}

LEFTRIGHT = ['[', ']']

def bfs(x, y, dir, matrix)
  # i love defining these offsets apparently
  x_offset, y_offset = OFFSETS[dir]
  new_x = x + x_offset
  new_y = y + y_offset

  to_move = []
  visited = {}

  q = Queue.new
  q << [new_x, new_y]
  until q.empty?
    cur = q.pop
    next if visited[cur]
    visited[cur] = true

    to_move << cur
    cur_x, cur_y = cur

    case matrix[cur_y][cur_x]
    when '['
      q << [cur_x + 1, cur_y]
      q << [cur_x, cur_y + y_offset]
    when ']'
      q << [cur_x - 1, cur_y]
      q << [cur_x, cur_y + y_offset]
    when '.'
      # very bad but it is late
      to_move.pop
      next
    when '#'
      return []
    end
  end
  return to_move.reverse
end

def tricky_tricky(x, y, dir, matrix)
  # did i mention i love defining offsets
  x_offset, y_offset = OFFSETS[dir]
  if dir == '<' || dir == '>'
    # why did I write all this code instead of reusing the old logic?
    # it is very late
    new_x = x + x_offset
    new_y = y + y_offset
    char = matrix[new_y][new_x]

    while matrix[new_y][new_x] == char
      new_x += x_offset * 2
      new_y += y_offset * 2
    end

    return false if matrix[new_y][new_x] == '#'
    raise WTF if matrix[new_y][new_x] != "."

    if char == ']'
      lr_idx = 0
    elsif char == '['
      lr_idx = 1
    else
      raise WTF
    end

    while (new_x - x).abs > 1
      matrix[new_y][new_x] = LEFTRIGHT[lr_idx]
      lr_idx = (lr_idx + 1) % 2
      new_x -= x_offset
    end

    matrix[new_y][new_x] = '@'
    matrix[y][x] = '.'

    true
  else
    nodes = bfs(x, y, dir, matrix)
    return false if nodes.empty?

    nodes.each do |node|
      x, y = node
      matrix[y + y_offset][x] = matrix[y][x]
      matrix[y][x] = '.'
    end
    matrix[y][x] = '@'
    matrix[y - y_offset][x] = '.'
  end
end

x, y = robot
moves.each do |dir|
  # hey look i'm defining more offsets
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
  when /[\[\]]/
    if tricky_tricky(x, y, dir, matrix)
      x, y = new_x, new_y
    end
  else
    raise WTF
  end
end

matrix.each { puts _1.join }
res = 0
matrix.each_with_index do |row, y|
  row.each_with_index do |val, x|
    next unless val == '['
    res += 100 * y + x
  end
end
p res
