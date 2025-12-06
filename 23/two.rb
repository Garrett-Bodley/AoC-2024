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
pairs = lines.map { |line| line.split('-') }

Node = Struct.new(*%i[name neighbors]) do
  def initialize(name=nil, neighbors = {})
    super(name, neighbors)
  end
end

graph = {}

pairs.each do |a, b|
  graph[a] = Node.new(a) unless graph[a]
  graph[b] = Node.new(b) unless graph[b]
  graph[a].neighbors[b] = true
  graph[b].neighbors[a] = true
end

def dfs(node, friends, graph)
  return false unless friends.keys.all? do |friend|
    node.neighbors[friend]
  end

  friends[node.name] = true
  res = friends.keys
  node.neighbors.keys.each do |neighbor|
    next if friends[neighbor]
    new_res = dfs(graph[neighbor], friends, graph)
    res = new_res if new_res && new_res.length > res.length
  end
  friends.delete(node.name)

  return res
end

res = []
p graph.length
graph.each_value do |n|
  puts n.name
  new_res = dfs(n, {}, graph)
  res = new_res if new_res.length > res.length
end
p res
