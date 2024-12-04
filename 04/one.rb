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

PHRASE = ['X', 'M', 'A', 'S']

Entry = Struct.new(*%i[x y idx x_offset y_offset prev]) do
  def initialize(x, y, idx, x_offset = nil, y_offset = nil, prev = nil)
    super(x, y, idx, x_offset, y_offset, prev)
  end
end

start = []

width = matrix.first.length
height = matrix.length

new_matrix = Array.new(height) { Array.new(width, '.')}

matrix.each_with_index do |line, y|
  line.each_with_index do |char, x|
    next unless char == 'X'

    e = Entry.new(x, y, 1)
    start << e
  end
end

stack = []
start.each do |e|
  [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].each do |x_offset, y_offset|
    new_x = e.x + x_offset
    new_y = e.y + y_offset
    next if new_x >= width || new_x < 0
    next if new_y >= height || new_y < 0
    next if matrix[new_y][new_x] != PHRASE[e.idx]

    stack << Entry.new(new_x, new_y, e.idx + 1, x_offset, y_offset, e)
  end
end


res = 0
until stack.empty?
  cur = stack.pop
  if cur.idx >= PHRASE.length
    while cur
      new_matrix[cur.y][cur.x] = PHRASE[cur.idx - 1]
      cur = cur.prev
    end
    res += 1
    next
  end

  new_x = cur.x + cur.x_offset
  new_y = cur.y + cur.y_offset
  next if new_x >= width || new_x < 0
  next if new_y >= height || new_y < 0
  next if matrix[new_y][new_x] != PHRASE[cur.idx]

  new_entry = Entry.new(new_x, new_y, cur.idx + 1, cur.x_offset, cur.y_offset, cur)
  stack << new_entry
end

new_matrix.each { puts _1.join('') }
p res
