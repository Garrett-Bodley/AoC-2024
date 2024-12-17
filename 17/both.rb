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

init = lines[0...3].map do |line|
  line.split(":").last.to_i
end
program = lines[4].scan(/\d+/).map(&:to_i)

WTF = Class.new(StandardError)
class VM
  attr_accessor :a, :b, :c, :ip, :program, :outbuf
  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
    @ip = 0
    @buff = []
  end

  def load(program)
    @program = program
  end

  def run
    while @ip < @program.length
      opcode = @program[@ip]
      operand = @program[@ip + 1]

      case opcode
      when 0
        adv(opcode, operand)
      when 1
        bxl(opcode, operand)
      when 2
        bst(opcode, operand)
      when 3
        jnz(opcode, operand)
      when 4
        bxc(opcode, operand)
      when 5
        out(opcode, operand)
      when 6
        bdv(opcode, operand)
      when 7
        cdv(opcode, operand)
      end
      @ip += 2
    end
  end

  def operand_parse(operand)
    case operand
    when 0..3
      return operand
    when 4
      return @a
    when 5
      return @b
    when 6
      return @c
    when 7
      raise WTF
    end
  end

  def adv(opcode, operand)
    # The adv instruction (opcode 0) performs division. The numerator is the value in the A register.
    # The denominator is found by raising 2 to the power of the instruction's combo operand.
    # (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.)
    # The result of the division operation is truncated to an integer and then written to the A register.
    # divisor = operand_parse(operand)
    shift = operand_parse(operand)
    @a = @a >> shift
  end

  def bxl(opcode, operand)
    # The bxl instruction (opcode 1) calculates the bitwise XOR of register B
    # and the instruction's literal operand, then stores the result in register B.
    @b ^= operand
  end

  def bst(opcode, operand)
    # The bst instruction (opcode 2) calculates the value of its combo operand modulo 8
    # (thereby keeping only its lowest 3 bits), then writes that value to the B register.
    combo = operand_parse(operand)
    @b = combo & 7
  end

  def jnz(opcode, operand)
    # The jnz instruction (opcode 3) does nothing if the A register is 0.
    # However, if the A register is not zero, it jumps by setting the instruction pointer
    # to the value of its literal operand;
    # if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
    return if @a == 0
    @ip = operand
    raise WTF if @ip >= @program.length
    @ip -= 2
  end

  def bxc(opcode, operand)
    # The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C,
    # then stores the result in register B.
    # (For legacy reasons, this instruction reads an operand but ignores it.)
    @b ^= @c
  end

  def out(opcode, operand)
    # The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value.
    # (If a program outputs multiple values, they are separated by commas.)
    val = operand_parse(operand) & 7
    @buff << val
  end

  def bdv(opcode, operand)
    # The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register.
    # (The numerator is still read from the A register.)
    shift = operand_parse(operand)
    @b = @a >> shift
  end

  def cdv(opcode, operand)
    # The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register.
    # (The numerator is still read from the A register.)
    shift = operand_parse(operand)
    @c = @a >> shift
  end

  def flush
    puts @buff.join(",").to_s
  end

  def buf_int
    @buff.join.to_i
  end
end

def query(seed, program)
  vm = VM.new(seed, 0, 0)
  vm.load(program)
  vm.run
  vm.buf_int
end

def dfs(idx, pre, program)
  return pre if idx.negative?

  options = []
  (0...8).each do |new_val|
    seed = (pre << 3) | new_val
    out = query(seed, program)
    if program[idx..].join.to_i == out
      options << seed
    end
  end
  return -1 if options.empty?

  options.each do |option|
    branch = dfs(idx - 1, option, program)
    return branch unless branch.negative?
  end
  -1
end

# Part 1
vm = VM.new(*init)
vm.load(program)
vm.run
vm.flush
puts

# Part 2
answer = dfs(program.length - 1, 0, program)
puts answer
puts query(answer, program).to_s.split('').join(',')
