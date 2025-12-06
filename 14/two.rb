# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

arg = ARGV.shift

case arg
when /input|input.txt/
  FILE_PATH = Pathname.new(File.expand_path('input.txt'))
  WIDTH = 101
  HEIGHT = 103
when /test|test.txt/
  FILE_PATH = Pathname.new(File.expand_path('test.txt'))
  WIDTH = 11
  HEIGHT = 7
else
  raise ArgumentError, "Expects 'input' or 'test' as command line argument"
end

lines = File.open(FILE_PATH, File::RDONLY).readlines(chomp: true)

Robot = Struct.new(*%i[x y xv yv])

robots = lines.map do |line|
  m = line.match(/^p=(\d+),(\d+) v=(-?\d+),(-?\d+)$/)
  Robot.new(*m[1..].map(&:to_i))
end

matrix = Array.new(HEIGHT) { Array.new(WIDTH, '.') }

robots.each do |r|
  matrix[r.y][r.x] = '■'
end

i = 0
loop do
  p i if (i - 88) % 103 == 0
  matrix.each { puts _1 .join('') } if (i - 12) % 101 == 0
  # binding.pry
  robots.each do |r|
    matrix[r.y][r.x] = '.'
    r.x = (r.x + r.xv) % WIDTH
    r.y = (r.y + r.yv) % HEIGHT
    matrix[r.y][r.x] = '■'
  end
  binding.pry if i == 6577
  i += 1
end

# ruby --yjit two.rb input > logging.txt
# Use eyeballs
