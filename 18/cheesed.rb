# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
  MATRIX_SIZE = 71
  BYTE_COUNT = 1024
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
  MATRIX_SIZE = 7
  BYTE_COUNT = 12
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)
bytes = lines.map { _1.split(',').map(&:to_i) }

matrix = Array.new(MATRIX_SIZE) { Array.new(MATRIX_SIZE, '.') }

WTF = Class.new(StandardError)

Node = Struct.new(*%i[x y distance prev]) do
  def initialize(*args)
    super(*args)
  end

  def coord
    [self.x, self.y]
  end
end
# binding.pry

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

def bfs(x, y, matrix)
  q = Queue.new
  q << Node.new(x, y, 0)
  visited = {}
  height = matrix.length
  width = matrix.first.length

  until q.empty?
    cur = q.pop

    if cur.coord == [MATRIX_SIZE - 1, MATRIX_SIZE - 1]
      return cur.distance
    end

    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |x_offset, y_offset|
      new_x = cur.x + x_offset
      new_y = cur.y + y_offset
      new_node = Node.new(new_x, new_y, cur.distance + 1, cur)
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] == '#'
      next if visited[new_node.coord]

      visited[new_node.coord] = true
      q << new_node
    end
  end
  return -1
end


left, right = 0, bytes.length - 1
while left < right
  mid = (left + right) / 2
  bytes[0..mid].each { |x, y| matrix[y][x] = '#' }
  if bfs(0, 0, matrix).negative?
    right = mid
  else
    left = mid + 1
  end
  bytes[0..mid].each { |x, y| matrix[y][x] = '.'}
end
p left
p bytes[left]

# binding.pry

# answer idx: 3042
# bytes.each_with_index do |(x, y), idx|
#   matrix[y][x] = '#'

#   if bfs(0, 0, matrix).negative?
#     p [x, y, idx]
#     break
#   end
# end
