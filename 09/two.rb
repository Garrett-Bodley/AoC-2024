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

Node = Struct.new(*%i[id length prev nxt]) do
  def initialize(id=nil, length=nil, prev=nil, nxt=nil)
    super(id, length, prev, nxt)
  end
end

dummy = Node.new
prev = dummy

id = 0
line.each_with_index do |num, idx|
  if idx.even?
    cur = Node.new(id, num, prev)
    id += 1
  else
    cur = Node.new(-1, num, prev)
  end
  prev.nxt = cur
  prev = cur
end

right = dummy.nxt
right = right.nxt while right.nxt

while right && right.id
  left = dummy.nxt
  possible = true
  loop do
    if left.id == right.id
      possible = false
      break
    end
    if left.id >= 0
      left = left.nxt
    elsif left.id.negative? && left.length < right.length
      left = left.nxt
    elsif left.id.negative? && left.length >= right.length
      break
    end
  end

  unless possible
    right = right.prev
    right = right.prev while right.id && right.id.negative?
    next
  end

  if left.length == right.length
    left.id, right.id = right.id, left.id
  elsif left.length > right.length
    child = Node.new(-1, left.length - right.length, prev)
    left.length = right.length
    left.nxt, child.nxt = child, left.nxt

    left.id, right.id = right.id, left.id
  end
end

# last_seen = -1
# while left && right && right != dummy
#   left = dummy.nxt
#   oh_no = false

#   while

#   if left.length == right.length
#     left.id, right.id = right.id, left.id
#   elsif left.length < right.length
#     left = left.nxt
#   elsif left.length > right.length

#     child = Node.new(-1, left.length - right.length, left)
#     left.length = right.length
#     left.nxt, child.nxt = child, left.nxt

#     left.id, right.id = right.id, left.id
#   else
#     puts "does this ever happen?"
#   end
# end


cur = dummy.nxt
res = []
while cur
  if cur.id.negative?
    res += ['.'] * cur.length
  else
    res += [cur.id] * cur.length
  end
  cur = cur.nxt
end


# p res.join('')
# p res
sum = 0
res.each_with_index do |val, idx|
  next if val == '.'
  sum += val * idx
end
p sum
