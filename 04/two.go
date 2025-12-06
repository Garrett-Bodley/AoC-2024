package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

var lines []string
var res int

func init() {
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
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
}

func main() {
	matrix := make([][]rune, 0, len(lines))
	for i := range lines {
		line := lines[i]
		row := make([]rune, len(line))
		for j, r := range line {
			row[j] = r
		}
		matrix = append(matrix, row)
	}

	as := [][]int{}
	for y, line := range matrix {
		for x, r := range line {
			if r != 'A' {
				continue
			}
			as = append(as, []int{x, y})
		}
	}

	offsets := [][][]int {
		[][]int{[]int{-1, -1, int('M')}, []int{1, 1, int('S')}, []int{-1, 1, int('M')}, []int{1, -1, int('S')}},
		[][]int{[]int{-1, -1, int('S')}, []int{1, 1, int('M')}, []int{-1, 1, int('S')}, []int{1, -1, int('M')}},
		[][]int{[]int{-1, -1, int('M')}, []int{1, 1, int('S')}, []int{-1, 1, int('S')}, []int{1, -1, int('M')}},
		[][]int{[]int{-1, -1, int('S')}, []int{1, 1, int('S')}, []int{-1, 1, int('M')}, []int{1, -1, int('S')}},
	}

	height := len(matrix)
	width := len(matrix[0])

	for _, a := range as {
		x, y := a[0], a[1]
		for _, offset := range offsets {
			found := true
			for _, dir := range offset {
				x_offset, y_offset := dir[0], dir[1]
				char := rune(dir[2])
				new_x := x + x_offset
				new_y := y + y_offset
				if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != char {
					found = false
					break
				}
			}
			if found {
				res++
				break
			}
		}
	}

	fmt.Println(res)
}
