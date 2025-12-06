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

graph = Hash.new { |h, k| h[k] = Hash.new }

pairs.each do |a, b|
  graph[a][b] = true
  graph[b][a] = true
end

nodes = graph.keys
triples = {}
nodes.each do |first|
  graph[first].keys.each do |second|
    graph[second].keys.each do |third|
      next if third == first

      graph[third].keys.each do |maybe_first|
        triples[[first, second, third].sort] = true if maybe_first == first
      end
    end
  end
end

res = triples.keys.select { _1.any? { |n| n[0] == 't' } }.sort.length
puts "Part 1: #{res}"

# triples = {}
# graph.each do |first, first_neighbors|
#   first_neighbors.each do |second|
#     graph[second].each do |third|
#       next if third == first

#       graph[third].each do |maybe_first|
#         triples[[first, second, third].sort] = true if first == maybe_first
#       end
#     end
#   end
# end

cliques = triples
counter = 0
loop do
  p counter
  largest = {}

  cliques.keys.each do |clique|
    nodes.each do |node|
      next if clique.include?(node)
      if clique.all? { |member| graph[member][node] }
        largest[clique.dup.push(node).sort] = true
      end
    end
  end
  break if largest.length == 0

  cliques = largest
  counter += 1
end

puts "Part 2: #{cliques.keys.sort_by(&:length).last.sort.join(',')}"

# binding.pry
# cliques = triples
# counter = 0
# loop do
#   p counter
#   new_cliques = {}

#   cliques.keys.each do |clique|
#     common_neighbors = clique.map { |member| graph[member].keys }.reduce(:&)
#     common_neighbors.each do |node|
#       next if clique.include?(node)
#       new_cliques[clique.dup.push(node).sort] = true
#     end
#   end

#   break if new_cliques.keys.to_set == cliques.keys.to_set
#   cliques = new_cliques
#   counter += 1
# end
#
# cliques = triples
# counter = 0
# loop do
#   p counter
#   new_cliques = {}

#   cliques.keys.each do |clique|
#     nodes.each do |node|
#       next if clique.include?(node)
#       if clique.all? { |member| graph[member][node] }
#         new_cliques[(clique + [node]).sort] = true
#       end
#     end
#   end

#   break if new_cliques.keys.to_set == cliques.keys.to_set || new_cliques.length == 0
#   cliques = new_cliques
#   counter += 1
# end


# binding.pry
