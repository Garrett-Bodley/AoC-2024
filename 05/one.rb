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

string = lines.join("\n")

sections = string.split("\n\n")
rules = sections[0].split("\n")
updates = sections[1].split("\n")

rules.map! do |rule|
  rule.split("|").map(&:to_i)
end

updates.map! do |update|
  update.split(",").map(&:to_i)
end

depends = Hash.new {|hash, key| hash[key] = {}}

rules.each do |from, to|
  depends[from][to] = true
end

res = 0
updates.each do |update|


  valid = true
  p update

  update.each_with_index do |num, i|
    valid = true
    (i + 1...update.length).none? do |j|
      cur = update[j]
      unless depends[num][cur]
        valid = false
        break
      end
    end
    p valid
    break unless valid
  end
  res += update[update.length/2] if valid


end

p res
# answer: 6951
