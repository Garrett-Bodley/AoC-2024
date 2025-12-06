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

def rotate(matrix)
  new_matrix = []
  (matrix.first.length - 1).downto(0) do |x|
    new_row = []
    (0...matrix.length).each do |y|
      new_row << matrix[y][x]
    end
    new_matrix << new_row
  end
  new_matrix
end

data = File.open(FILE_PATH, File::RDONLY).read.split("\n\n")
  .map{ _1.lines(chomp: true).map { |line| line.split('') } }
  .map{ rotate(_1) }

def analyze(matrix, keys, locks)
  is_key = matrix[0][0] == '.'
  res = []

  matrix.each do |row|
    res << row.count('#') - 1
  end

  keys << res.reverse if is_key
  locks << res.reverse if !is_key
end


keys = Set.new
locks = Set.new

data.each do |kase|
  analyze(kase, keys, locks)
end

res = 0
locks.each do |lock|
  keys.each do |key|
    valid = key.zip(lock).none? do |key_val, lock_val|
      key_val + lock_val > 5
    end
    res += 1 if valid
  end
end

p res
