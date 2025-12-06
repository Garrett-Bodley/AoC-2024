package main

import (
	"bufio"
	"fmt"
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

	nums := []int{}
	for _, numStr := range regexp.MustCompile(`\s+`).Split(lines[0], -1) {
		num, err := strconv.Atoi(numStr)
		if err != nil {
			panic(err)
		}
		nums = append(nums, num)
	}

	for i := 0; i < 25; i++ {
		newNums := make([]int, 0, len(nums))
		for j := range nums {
			children := blink(nums[j])
			for _, child := range children {
				newNums = append(newNums, child)
			}
		}
		nums = newNums
	}

	fmt.Println(len(nums))
}

func blink(num int) (res []int) {
	if num == 0 {
		res = []int{1}
	} else if numStr := strconv.Itoa(num); len(numStr)&1 == 0 {
		half := len(numStr) / 2
		leftStr := numStr[0:half]
		rightStr := numStr[half:]

		left, err := strconv.Atoi(leftStr)
		if err != nil {
			panic(err)
		}

		right, err := strconv.Atoi(rightStr)
		if err != nil {
			panic(err)
		}
		res = []int{left, right}
	} else {
		res = []int{num * 2024}
	}
	return res
}

// answer: 193269