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

p out
