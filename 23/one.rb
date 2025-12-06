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

graph = Hash.new { |h, k| h[k] = [] }

pairs.each do |a, b|
  graph[a] << b
  graph[b] << a
end

triples = {}
graph.each do |first, first_neighbors|
  first_neighbors.each do |second|
    graph[second].each do |third|
      next if third == first

      graph[third].each do |maybe_first|
        triples[[first, second, third].sort] = true if first == maybe_first
      end
    end
  end
end

res = triples.keys.select { _1.any? { |n| n[0] == 't' } }.sort.length
puts res
