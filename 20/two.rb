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

start, target = nil, nil

matrix.each_with_index do |row, y|
  row.each_with_index do |char, x|
    start = [x, y] if char == 'S'
    target = [x, y] if char == 'E'
  end
end

WTF = Class.new(StandardError)

Node = Struct.new(*%i[x y distance prev]) do
  def initialize(*args)
    super(*args)
  end

  def coord
    [self.x, self.y]
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

def djikstra(x, y, matrix)
  h = MinHeap.new
  h << Node.new(x, y, 0)
  visited = {}
  height = matrix.length
  width = matrix.first.length
  path = []

  until h.empty?
    cur = h.pop
    next if visited[cur.coord] && visited[cur.coord] < cur.distance
    visited[cur.coord] = cur.distance

    if matrix[cur.y][cur.x] == 'E'
      distance = cur.distance
      while cur
        path << cur
        cur = cur.prev
      end
      return [distance, path]
    end

    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |x_offset, y_offset|
      new_x = cur.x + x_offset
      new_y = cur.y + y_offset
      new_node = Node.new(new_x, new_y, cur.distance + 1, cur)
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] == '#'
      next if visited[new_node.coord] && visited[new_node.coord] <= new_node.distance

      visited[new_node.coord] = new_node.distance
      h << new_node
    end

  end
  return visited
end

distance, path = djikstra(start.first, start.last, matrix)

path_to_end = {}
path.each_with_index do |node, idx|
  path_to_end[node.coord] = idx
end

path.reverse!

res = 0
path.each_with_index do |node, idx|
  path[idx + 1...].each do |option|
    x_distance = (node.x - option.x).abs
    y_distance = (node.y - option.y).abs
    cartesian = x_distance + y_distance
    next unless cartesian <= 20

    distance_with_cheat = idx + path_to_end[option.coord] + cartesian
    saved = distance - distance_with_cheat
    res += 1 if saved >= 100
  end
end

p res
