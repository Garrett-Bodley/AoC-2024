package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"regexp"
	"strconv"
)

func main() {
	args := os.Args[1:]
	if len(args) != 1 {
		panic("error: expects 'input' or 'test' as an argument")
	}

	var filepath string
	arg := args[0]
	if matched, err := regexp.Match("test", []byte(arg)); matched {
		if err != nil {
			panic(err)
		}
		filepath = "test.txt"
	} else if matched, err := regexp.Match("input", []byte(arg)); matched {
		if err != nil {
			panic(err)
		}
		filepath = "input.txt"
	} else {
		panic("error: expects 'input' or 'test' as an argument")
	}

	file, err := os.Open(filepath)
	if err != nil {
		panic(err)
	}

	scanner := bufio.NewScanner(file)
	lines := []string{}
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	res := 0
	for _, line := range lines {
		if isSafe(line) {
			res++
		}
	}
	fmt.Println(res)
}

func isSafe(line string) bool {
	vals := toi(line)
	diff := vals[0] - vals[1]
	if diff == 0 {
		return false
	}
	if diff < 0 {
		return isIncreasing(vals)
	} else {
		return isDecreasing(vals)
	}
}

func toi(line string) []int {
	vals := []int{}
	split := regexp.MustCompile(`\s+`).Split(line, -1)
	for _, char := range split {
		num, err := strconv.Atoi(char)
		if err != nil {
			panic(err)
		}
		vals = append(vals, num)
	}
	return vals
}

func isIncreasing(vals []int) bool {
	prev := vals[0]
	for i := 1; i < len(vals); i++ {
		cur := vals[i]
		if cur <= prev {
			return false
		}
		diff := int(math.Abs(float64(cur - prev)))
		if diff < 1 || diff > 3 {
			return false
		}
		prev = cur
	}
	return true
}

func isDecreasing(vals []int) bool {
	prev := vals[0]
	for i := 1; i < len(vals); i++ {
		cur := vals[i]
		if cur >= prev {
			return false
		}
		diff := int(math.Abs(float64(cur - prev)))
		if diff < 1 || diff > 3 {
			return false
		}
		prev = cur
	}
	return true
}

// answer: 483
