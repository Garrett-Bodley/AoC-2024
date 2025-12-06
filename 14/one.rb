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

quadrants = [0, 0, 0, 0]
quadrant_map = {
  'NE' => 0,
  'NW' => 1,
  'SE' => 2,
  'SW' => 3
}

matrix = Array.new(HEIGHT) { Array.new(WIDTH, '.') }

robots.each do |r|
  r.x = (r.x + r.xv * 100) % WIDTH
  r.y = (r.y + r.yv * 100) % HEIGHT
  next if r.x == WIDTH / 2
  left = r.x < WIDTH / 2 ? true : false
  next if r.y == HEIGHT / 2
  top = r.y < HEIGHT / 2 ? true : false
  binding.pry if r.x.negative? || r.y.negative?
  if left && top
    q = 'NW'
  elsif !left && top
    q = 'NE'
  elsif left && !top
    q = 'SW'
  elsif !left && !top
    q = 'SE'
  else
    puts "wtf"
  end
  quadrants[quadrant_map[q]] += 1
  if matrix[r.y][r.x] == '.'
    matrix[r.y][r.x] = 1
  else
    matrix[r.y][r.x] += 1
  end
end
# binding.pry
puts quadrants.reduce(1) { |accum, val| accum * val }
