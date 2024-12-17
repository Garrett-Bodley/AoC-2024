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

  def coord
    "#{x},#{y}"
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

source = nil
target = nil
matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    source = [x, y] if char == 'S'
    target = [x, y] if char == 'E'
  end
end
          # N       E       S       W
OFFSETS = [[0, -1], [1, 0], [0, 1], [-1, 0]]

DIRMAP = {
  0 => '^',
  1 => '>',
  2 => 'v',
  3 => '<',
}

def djikstra(starts, matrix)
  h = MinHeap.new
  starts.each do |x, y, dir|
    h << Node.new(x, y, dir, 0)
  end
  visited = {}
  height = matrix.length
  width = matrix.first.length
  until h.empty?
    cur = h.pop
    next if visited[cur.to_s] && visited[cur.to_s] < cur.distance
    visited[cur.to_s] = cur.distance
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
  return visited
end

visited = djikstra([source + [1]], matrix)

from_end_init = (0...4).to_a.map do |val|
  target + [val]
end
from_end = djikstra(from_end_init, matrix)


shortest = Float::INFINITY
(0...4).each do |dir|
  shortest = visited["#{target.first},#{target.last},#{dir}"] if visited["#{target.first},#{target.last},#{dir}"] < shortest
end
p shortest

path_set = {}
matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    next if char == '#'

    (0...4).each do |dir|
      key_from_start = "#{x},#{y},#{dir}"
      key_from_end = "#{x},#{y},#{(dir + 2) % 4}"
      if visited[key_from_start] && from_end[key_from_end] && visited[key_from_start] + from_end[key_from_end] == shortest
        logging[y][x] = 'O'
        path_set[[x, y]] = true
      end
    end
  end
end
# logging.each { puts _1.join }
p path_set.length
