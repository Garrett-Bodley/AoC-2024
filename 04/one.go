package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

var lines []string

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

type Entry struct {
	x        int
	y        int
	idx      int
	x_offset int
	y_offset int
	prev     *Entry
}

var OFFSETS = [][]int{
	[]int{-1, -1},
	[]int{-1, 0},
	[]int{-1, 1},
	[]int{0, -1},
	[]int{0, 1},
	[]int{1, -1},
	[]int{1, 0},
	[]int{1, 1},
}

var PHRASE = []rune{'X', 'M', 'A', 'S'}

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
	width := len(matrix[0])
	height := len(matrix)

	new_matrix := make([][]rune, height)
	for i := 0; i < height; i++ {
		row := make([]rune, width)
		for j := range row {
			row[j] = '.'
		}
		new_matrix[i] = row
	}

	start := []*Entry{}
	for y, line := range matrix {
		for x, r := range line {
			if r != 'X' {
				continue
			}
			start = append(start, &Entry{
				x:   x,
				y:   y,
				idx: 1,
			})
		}
	}

	stack := make([]*Entry, 0)

	for _, e := range start {
		for _, offset := range OFFSETS {
			x_offset, y_offset := offset[0], offset[1]
			new_x := e.x + x_offset
			new_y := e.y + y_offset
			if new_x >= width || new_x < 0 || new_y >= height || new_y < 0 || matrix[new_y][new_x] != PHRASE[e.idx] {
				continue
			}
			stack = append(stack, &Entry{
				x:        new_x,
				y:        new_y,
				x_offset: x_offset,
				y_offset: y_offset,
				idx:      e.idx + 1,
				prev:     e,
			})
		}
	}

	res := 0
	for len(stack) > 0 {
		cur := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		if cur.idx >= len(PHRASE) {
			for cur != nil {
				new_matrix[cur.y][cur.x] = PHRASE[cur.idx-1]
				cur = cur.prev
			}
			res++
			continue
		}

		new_x := cur.x + cur.x_offset
		new_y := cur.y + cur.y_offset
		if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height || matrix[new_y][new_x] != PHRASE[cur.idx] {
			continue
		}

		newEntry := Entry{
			x:        new_x,
			y:        new_y,
			idx:      cur.idx + 1,
			x_offset: cur.x_offset,
			y_offset: cur.y_offset,
			prev:     cur,
		}
		stack = append(stack, &newEntry)
	}

	fmt.Println(res)
}
