package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"regexp"
	"slices"
	"strconv"
)

func main() {
	args := os.Args[1:]
	if len(args) != 1 {
		panic("error: expects 'input' or 'test' as an argument")
	}

	var filepath string
	arg := args[0]
	if matched, err := regexp.Match(`test`, []byte(arg)); matched {
		if err != nil {
			panic(err)
		}
		filepath = "test.txt"
	} else if matched, err := regexp.Match(`input`, []byte(arg)); matched {
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

	left := make([]int, len(lines))
	right := make([]int, len(lines))

	for i, line := range lines {
		fields := regexp.MustCompile(`\s+`).Split(line, -1)
		leftInt, err := strconv.Atoi(fields[0])
		if err != nil {
			panic(err)
		}
		rightInt, err := strconv.Atoi(fields[1])
		if err != nil {
			panic(err)
		}

		left[i] = leftInt
		right[i] = rightInt
	}

	slices.Sort(left)
	slices.Sort(right)

	res := 0
	for i := range left {
		res += int(math.Abs(float64(left[i] - right[i])))
	}
	fmt.Println(res)
}

// answer: 1882714
