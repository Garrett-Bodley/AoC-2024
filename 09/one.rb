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

line = lines.first.split('').map(&:to_i)

decomp = []

id = 0
line.each_with_index do |num, idx|
  if idx.even?
    decomp += [id] * num
    id += 1
  else
    decomp += ['.'] * num
  end
end
p decomp.join('')

left = 0
right = decomp.length - 1

while left < right
  left += 1 while decomp[left] != '.'
  right -= 1 while decomp[right] == '.'
  decomp[left], decomp[right] = decomp[right], decomp[left]
  left += 1
  right -= 1
end
left = 0
right = decomp.length - 1

while left < right
  left += 1 while decomp[left] != '.'
  right -= 1 while decomp[right] == '.'
  decomp[left], decomp[right] = decomp[right], decomp[left]
  left += 1
  right -= 1
end
p decomp.join('')

res = 0
decomp.each_with_index do |val, idx|
  break if val == '.'
  res += val * idx
end
p res

# 6331928801055 no
# 6332189866718
