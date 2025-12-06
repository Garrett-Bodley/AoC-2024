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

lines = File.open(FILE_PATH, File::RDONLY).read
inputs_raw, wires_raw = lines.split("\n\n").map { _1.split("\n") }

WTF = Class.new(StandardError)

GRAPH = {}

Register = Struct.new(*%i[id state dependencies]) do
  def initialize(id=nil, state=nil, dependencies=[])
    super(id, state, dependencies)
  end
end

Gate = Struct.new(*%i[id dependencies type]) do
  def initialize(id=nil, dependencies=[], type=nil)
    super(id, dependencies, type)
  end

  def state
    raise WTF if dependencies.length != 2
    case type
    when 'AND'
      GRAPH[self.dependencies[0]].state & GRAPH[self.dependencies[1]].state
    when 'OR'
      GRAPH[self.dependencies[0]].state | GRAPH[self.dependencies[1]].state
    when 'XOR'
      GRAPH[self.dependencies[0]].state ^ GRAPH[self.dependencies[1]].state
    end
  end
end


inputs_raw.each do |input|
  name, val = input.split(": ")
  GRAPH[name] = Register.new(name, val.to_i)
end

wires_raw.each do |wire|
  in1, type, in2, id = wire.match(/(\w+\d?) (AND|OR|XOR) (\w+\d?)+ -> (\w+\d?)/).captures
  gate = Gate.new(id, [in1, in2], type)
  GRAPH[gate.id] = gate
end

def out
  GRAPH.values.select { |n| n.id[0] == 'z' }.sort_by{ |n| n.id }
  .reverse.map {|n| n.state }.map(&:to_s).join.to_i(2)
end

def init(x, y)
  x_nodes = GRAPH.values.select { |n| n.id[0] == 'x' }.sort_by { _1.id }.reverse
  y_nodes = GRAPH.values.select { |n| n.id[0] == 'y' }.sort_by { _1.id }.reverse

  raise WTF if x_nodes.length != y_nodes.length
  bits = x_nodes.length

  x_bits = x.to_s(2).rjust(bits, '0').split('').map(&:to_i)
  y_bits = y.to_s(2).rjust(bits, '0').split('').map(&:to_i)
  x_nodes.zip(x_bits) do |node, val|
    node.state = val
  end
  y_nodes.zip(y_bits) do |node, val|
    node.state = val
  end
end

# def graphviz_compile(wires_raw)
#   File.open("graphviz.txt", "w+") do |f|
#     f.puts "digraph G {"
#     f.puts "\trankdir=LR;"
#     f.puts "\tnode [shape=circle];"
#     wires_raw.each do |wire|
#       from1, type, from2, to = wire.match(/(\w+\d?) (AND|OR|XOR) (\w+\d?)+ -> (\w+\d?)/).captures
#       f.puts "\t#{from1} -> #{to} [label=\"#{type}\"];"
#       f.puts "\t#{from2} -> #{to} [label=\"#{type}\"];"
#     end
#     f.puts "}"
#   end
# end
# graphviz_compile(wires_raw)

# Used to check if my fix worked:
# 
# x, y = (1 << 33) - 1, 4
# init(x, y)
# puts "x: #{x.to_s(2).rjust(45, '0')}"
# puts "y: #{y.to_s(2).rjust(45, '0')}"
# puts "o: #{out.to_s(2).rjust(45, '0')}"
# puts
# return
# binding.pry if out != x + y

x, y = 0, 1
45.times do
  init(x, y)
  if out != x + y
    puts "x: #{x.to_s(2).rjust(45, '0')}"
    puts "y: #{y.to_s(2).rjust(45, '0')}"
    puts "o: #{out.to_s(2).rjust(45, '0')}"
    puts "bit #{Math.log2(y).to_i}"
    puts
  end
  y <<= 1
end

# y16 AND x16 -> z16 | y16 AND x16 -> hmk
# vmr XOR bnc -> hmk | vmr XOR bnc -> z16
#
# pns XOR tsc - fhp | pns XOR tsc - z20
# pns AND tsc - z20 | pns AND tsc - fhp
#
# x27 AND y27 -> rvf | x27 AND y27 -> tpc
# y27 XOR x27 -> tpc | y27 XOR x27 -> rvf
#
# smf XOR rfd -> fcd | smf XOR rfd -> z33
# wkw OR jgr  -> z33 | wkw OR jgr  -> fcd

puts %w[hmk z16 z20 fhp tpc rvf z33 fcd].sort.join(",")
