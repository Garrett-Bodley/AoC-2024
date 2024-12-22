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

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true).map(&:to_i)

WTF = Class.new(StandardError)

REPEAT = 2000

class RNG
  attr_accessor :state
  def initialize(seed)
    @state = seed
  end
  # 16777215 == 1 << 24
  def next
    @state = ((@state << 6) ^ @state) & 16777215
    @state = ((@state >> 5) ^ @state) & 16777215
    @state = ((@state << 11) ^ @state) & 16777215
  end
end

puts 'precomputing! takes a minute...'

cycle = []
seen = {}
puts "generating full cycle"

rng = RNG.new(1)

until seen[rng.state]
  seen[rng.state] = true
  cycle << rng.state
  rng.next
end

puts 'computing cycle diffs'
cycle_diffs = Array.new(cycle.length)

cycle.each_with_index do |val, i|
  diff = val % 10 - cycle[i - 1] % 10
  cycle_diffs[i] = diff
end

raise WTF if cycle.length != cycle_diffs.length
raise WTF if cycle_diffs.any? { _1.nil? }

puts 'finding all windows'
windows = {}

(0...cycle_diffs.length).each do |i|
  sequence = [
    cycle_diffs[i - 3],
    cycle_diffs[i - 2],
    cycle_diffs[i - 1],
    cycle_diffs[i],
  ]
  windows[sequence] = true
end

puts "There are #{windows.length} possible windows"

LineCache = Struct.new(*%i[sequence diffs dict]) do
  def initialize(sequence = [], diffs = [], dict = {})
    super(sequence, diffs, dict)
  end
end

caches = Array.new(lines.length) { LineCache.new }

puts "building cache for each line"
lines.each_with_index do |seed, i|
  rng = RNG.new(seed)
  cache = caches[i]

  cache.sequence << rng.state
  2000.times { cache.sequence << rng.next }
  cache.diffs = Array.new(2001)
  cache.diffs[0] = nil
  cache.sequence.each_with_index do |_val, i|
    next if i.zero?

    cache.diffs[i] = (cache.sequence[i] % 10) - (cache.sequence[i - 1] % 10)
  end
  (4...cache.diffs.length).each do |i|
    window = [
      cache.diffs[i - 3],
      cache.diffs[i - 2],
      cache.diffs[i - 1],
      cache.diffs[i],
    ]
    next if cache.dict[window]

    cache.dict[window] = cache.sequence[i] % 10
  end
end

puts 'searching windows'
res = 0
windows.each_key do |window|
  new_res = 0
  caches.each do |line_cache|
    new_res += line_cache.dict[window] if line_cache.dict[window]
  end
  res = [res, new_res].max
end

puts res
# answer 2268
