# frozen_string_literal: true

require 'pathname'
require 'pry-nav'
require 'algorithms'

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

logging = []

matrix.each { logging << _1.dup }

Node = Struct.new(*%i[x y dir distance prev]) do
  def initialize(*args)
    super(*args)
  end

  def to_s
    "#{x},#{y},#{dir}"
  end
end

class MinHeap
  def initialize
    @data = []
  end

  def push(val)
    @data << val
    bubble_up
  end

  def pop
    @data[0], @data[-1] = @data[-1], @data[0]
    res = @data.pop
    bubble_down
    return res
  end

  def empty?
    @data.empty?
  end

  def length
    @data.length
  end

  def <<(val)
    push(val)
  end

  private

  def bubble_up
    i = @data.length - 1
    while i > 0
      parent = (i - 1) / 2
      break if @data[parent].distance <= @data[i].distance

      @data[i], @data[parent] = @data[parent], @data[i]
      i = parent
    end
  end

  def bubble_down
    i = 0
    while i * 2 + 1 < @data.length
      left = i * 2 + 1
      right = left + 1

      if right >= @data.length || @data[left].distance < @data[right].distance
        min = left
      else
        min = right
      end

      break if @data[i].distance <= @data[min].distance
      @data[i], @data[min] = @data[min], @data[i]
      i = min
    end
  end
end

h = MinHeap.new

matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    if char == 'S'
      h << Node.new(x, y, 1, 0)
      p [x, y]
      break
    end
  end
end

visited = {}

height = matrix.length
width = matrix.first.length
          # N       E       S       W
OFFSETS = [[0, -1], [1, 0], [0, 1], [-1, 0]]

DIRMAP = {
  0 => '^',
  1 => '>',
  2 => 'v',
  3 => '<',
}

res = Float::INFINITY
until h.empty?
  cur = h.pop

  next if visited[cur.to_s] && visited[cur.to_s] < cur.distance
  visited[cur.to_s] = cur.distance

  if matrix[cur.y][cur.x] == 'E'
    res = cur.distance
    while cur.prev
      logging[cur.y][cur.x] = DIRMAP[cur.dir] unless matrix[cur.y][cur.x].match?(/[ES]/)
      cur = cur.prev
    end

    break
  end

  [-1, 1].each do |offset_offset|
    new_dir = (cur.dir + offset_offset) % 4
    new_node =  Node.new(cur.x, cur.y, new_dir, cur.distance + 1000, cur)
    next if visited[new_node.to_s] && visited[new_node.to_s] <= new_node.distance
    visited[new_node.to_s] = new_node.distance
    h << new_node
  end

  x_offset, y_offset = OFFSETS[cur.dir]
  new_x = cur.x + x_offset
  new_y = cur.y + y_offset
  new_node = Node.new(new_x, new_y, cur.dir, cur.distance + 1, cur)
  next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] == '#'
  next if visited[new_node.to_s] && visited[new_node.to_s] <= new_node.distance
  visited[new_node.to_s] = new_node.distance
  h << new_node
end

p res
