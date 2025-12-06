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

WTF = Class.new(StandardError)

PHONE = [
  ['7', '8', '9'],
  ['4', '5', '6'],
  ['1', '2', '3'],
  ['yucky', '0', 'A'],
]
DIRMAP = {
  '^' => [0, -1],
  '>' => [1, 0],
  'v' => [0, 1],
  '<' => [-1, 0],
}
DIRS = ['^', '>', 'v', '<']
# phone_map = Hash.new { |hash, key| hash[key] = {} }

Node = Struct.new(*%i[x y dir distance visited prev]) do
  def initialize(*args)
    super(*args)
  end

  def coord
    [self.x, self.y]
  end
end

def bfs(start, target, matrix)
  q = []
  (0...4).each do |dir|
    q << Node.new(start.first, start.last, dir, 0, {})
  end

  height = matrix.length
  width = matrix.first.length

  shortest = Float::INFINITY
  paths = {}

  until q.empty?
    cur = q.shift
    if cur.coord == target
      next if cur.distance > shortest
      shortest = cur.distance
      path = []

      while cur
        binding.pry if DIRS[cur.dir].nil?
        path << DIRS[cur.dir]
        cur = cur.prev
      end
      paths[path.reverse[1..]] = true
      next
    end

    (-1..1).each do |dir_offset|
      new_dir = (cur.dir + dir_offset) % 4
      x_offset, y_offset = DIRMAP[DIRS[new_dir]]
      binding.pry if x_offset.nil?
      new_x = cur.x + x_offset
      new_y = cur.y + y_offset
      next if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] == 'yucky'
      next if cur.visited[[new_x, new_y]]

      new_node = Node.new(new_x, new_y, new_dir, cur.distance + 1, cur.visited.dup, cur)
      new_node.visited[[new_x, new_y]] = true
      q << new_node
    end
  end
  return shortest, paths.keys
end

def turn_count(path)
  return 0 if path.length < 2
  res = 0
  prev = path.first

  (1...path.length).each do |i|
    cur = path[i]
    res += 1 if cur != prev
    prev = cur
  end
  return res
end

PHONE_MAP = Hash.new { |h, k| h[k] = Hash.new }
PHONE.each_with_index do |row, y|
  row.each_with_index do |char, x|
    next if char == 'yucky'

    PHONE.each_with_index do |inner_row, inner_y|
      inner_row.each_with_index do |inner_char, inner_x|
        next if inner_char == 'yucky' || char == inner_char


        start = [x, y]
        target = [inner_x, inner_y]
        _shortest, paths = bfs(start, target, PHONE)
        options = paths.filter { |path| turn_count(path) < 2 }
        options.each { |path| path << 'A' }
        PHONE_MAP[char][inner_char] = options
      end
    end
  end
end

ARROWS_MAP = Hash.new { |h, k| h[k] = Hash.new }
ARROWS = [
  ['yucky','^','A'],
  ['<','v','>'],
]

ARROWS.each_with_index do |row, y|
  row.each_with_index do |char, x|
    next if char == 'yucky'

    ARROWS.each_with_index do |inner_row, inner_y|
      inner_row.each_with_index do |inner_char, inner_x|
        next if inner_char == 'yucky'
        if char == inner_char
          ARROWS_MAP[char][inner_char] = [['A']]
        end

        start = [x, y]
        target = [inner_x, inner_y]
        _shortest, paths = bfs(start, target, ARROWS)
        mapped = paths.map { |path| [turn_count(path), path] }.sort_by { |el| el.first }
        filtered = mapped.select { |el| el.first == mapped.first.first }.map { |el| el[1] }
        filtered.each { |el| el << 'A' }
        ARROWS_MAP[char][inner_char] = filtered
      end
    end
  end
end
# binding.pry

ARROWS.each_with_index do |row, y|
  row.each_with_index do |char, x|
    next if char == 'yucky'

    ARROWS.each_with_index do |inner_row, inner_y|
      inner_row.each_with_index do |inner_char, inner_x|

      end
    end
  end
end

# DFS_PHONE_MEMO = {}
# def dfs_phone(code)
#   res = ''
#   prev = 'A'
#   code.each do |c|
#     options = PHONE_MAP[prev][c]
#     binding.pry
#     if options.length == 1
#       num_code = dfs_numpad(options.first)
#     else

#     end
#   end
# end

DFS_ARROWS_MEMO = {}

def dfs_arrows(code, depth)
  return [code] if depth.zero?
  return DFS_ARROWS_MEMO[code.join] if DFS_ARROWS_MEMO[code.join]

  res = [[]]

  prev = 'A'
  code.each do |c|
    # binding.pry
    new_res = []
    options = ARROWS_MAP[prev][c]
    options.each do |option|
      sequences = dfs_arrows(option, depth - 1)
      sequences = sequences.sort_by{ |el| el.length }
      sequences = sequences.select { |el| el.length == sequences.first.length }

      res.each do |res_option|
        sequences.each do |seq_option|
          new_res << res_option + seq_option
        end
      end
    end

    new_res = new_res.sort_by { |el| el.length }
    new_res = new_res.select { |el| el.length == new_res.first.length }
    res = new_res
    prev = c
  end
  return res
end

def dfs_phone(code)
  res = [[]]
  prev = 'A'

  code.each do |c|
    new_res = []

    options = PHONE_MAP[prev][c]

    options.each do |option|
      sequences = dfs_arrows(option, 2)
      sequences = sequences.sort_by{ |el| el.length }
      sequences = sequences.select { |el| el.length == sequences.first.length }

      res.each do |res_option|
        sequences.each do |seq_option|
          new_res << res_option + seq_option
        end
      end
    end

    new_res = new_res.sort_by { |el| el.length }
    new_res = new_res.select { |el| el.length == new_res.first.length }
    res = new_res
    prev = c
  end

  length = res.map(&:length).min
  numeric = code.join.scan(/\d/).join.to_i
  return length, numeric
end

# res = 0
# lines.each do |line|
#   length, numeric = dfs_phone(line.split(''))
#   p [length, numeric, length * numeric]
#   res += length * numeric
# end
# p res
#
p dfs_phone(lines.first.split(''))


# sequences = dfs_arrows('<A>^>A'.split(''), 3)
# p sequences.map(&:length).min
# p dfs_phone(lines[0].split(''))

# bug from 9 => A

p dfs_arrows(["A", ">"], 5).map(&:length).min
# p dfs_arrows(["A", ">"], 2).sort_by{ _1.length }.last
# binding.pry

# <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>A     AvA^A<v<A>A>^AAAvA<^A>A
# v<<A>>^A<A>AvA<^A    A>A<vAAA>^A
# <A^A>^^A    vvvA
# 029A

# <vA<AA>>^AvAA<^A>A    <v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
# v<<A>>^A <A>AvA<^AA>A<vAAA>^A
# <A ^A>^^AvvvA
# 029A
#
# puts '<A'
# puts dfs_arrows('<A'.split(''), 1).map(&:join).any? { _1 == 'v<<A>>^A' }
# puts dfs_arrows('<A'.split(''), 2).map(&:join).any? { _1 == '<vA<AA>>^AvAA<^A>A' }

# <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A          <vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
# v<<A>>^A<A>A              vA<^AA>A<vAAA>^A
# <A^A        >^^AvvvA
# 029A

# <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A    <vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
# v<<A>>^A<A>A   vA<^AA>A<vAAA>^A
# <A^A    >^^AvvvA
# 029A
# puts '<A^A'
# puts dfs_arrows('<A^A'.split(''), 1).map(&:join).any? { _1 == 'v<<A>>^A<A>A' }
# puts dfs_arrows('<A^A'.split(''), 2).map(&:join).any? { _1.length == '<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A'.length }
#                                                               # '<vA<AA>>^AvAA<^A>A'
#                                                               #                   '<v<A>>^AvA^A'

# puts '<A^A>^^AvvvA'
# puts dfs_arrows('<A^A>^^AvvvA'.split(''), 1).map(&:join).any? { _1.length == 'v<<A>>^A<A>AvA<^AA>A<vAAA>^A'.length }
# puts dfs_arrows('<A^A>^^AvvvA'.split(''), 2).map(&:join).any? { _1.length == '<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A'.length }

# <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
# binding.pry
# maybe = dfs_arrows('<A^A>^^A'.split(''), 2)
# puts maybe.map(&:join).any? { _1 == 'v<<A>>^A<A>AvA<^AA>A<vAAA>^A'}
# 'v<<A>>^A<A>AvA<^AA>A<vAAA>^A'
# binding.pry

# dfs_phone(lines.first.split(''))
