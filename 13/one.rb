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

text = File.open(FILE_PATH, File::RDONLY).read

kases = text.split("\n\n")
kases.map! do |kase|
  match = kase.match(/Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)/)
  match[1..].map(&:to_i)
end

COST_A = 3
COST_B = 1

Node = Struct.new(*%i[x y cost])

def djikstra(ax, ay, bx, by, tx, ty)
  h = Containers::Heap.new { |a, b| a.cost <=> b.cost }
  h << Node.new(0, 0, 0)
  visited = {}
  until h.empty?
    cur = h.pop
    next if visited[[cur.x, cur.y]]

    visited[[cur.x, cur.y]] = true
    return cur.cost if cur.x == tx && cur.y == ty

    a = Node.new(cur.x + ax, cur.y + ay, cur.cost + COST_A)
    h << a unless visited[[a.x, a.y]] || a.x > tx || a.y > ty
    b = Node.new(cur.x + bx, cur.y + by, cur.cost + COST_B)
    h << b unless visited[[b.x, b.y]] || b.x > tx || b.y > ty
  end
  return -1
end

res = 0
kases.each_with_index do |kase, idx|
  p idx
  cost = djikstra(*kase)
  res += cost unless cost < 0
end
p res
