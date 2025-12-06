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
  parsed = match[1..].map(&:to_i)
  parsed[-1] = parsed[-1] + 10000000000000
  parsed[-2] = parsed[-2] + 10000000000000
  parsed
end

COST_A = 3
COST_B = 1

Node = Struct.new(*%i[x y cost])

def cost(ax, ay, bx, by, tx, ty)
  b = (ty * ax / ay - tx) / (by * ax / ay - bx)
  a = (tx - b * bx)/ax
  return -1 if a.round * ax + b.round * bx != tx
  return -1 if a.round * ay + b.round * by != ty
  a.round * COST_A + b.round * COST_B
end

res = 0
kases.each_with_index do |kase, idx|
  kost = cost(*kase.map(&:to_f))
  res += kost if kost != -1
end
p res
