package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
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
	str := strings.Join(lines, "")
	re := regexp.MustCompile(`(mul\(\d+,\d+\))`)
	matches := re.FindAllString(str, -1)

	re2 := regexp.MustCompile(`mul\((\d+),(\d+)\)`)
	res := 0
	for _, exp := range matches {
		matches2 := re2.FindAllStringSubmatch(exp, -1)
		a, err := strconv.Atoi(matches2[0][1])
		if err != nil {
			panic(err)
		}
		b, err := strconv.Atoi(matches2[0][2])
		if err != nil {
			panic(err)
		}
		res += a * b
	}
	fmt.Println(res)
}

// answer: 188192787