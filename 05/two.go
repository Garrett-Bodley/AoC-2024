package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"slices"
	"strconv"
	"strings"
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
	content := strings.Join(lines, "\n")
	sections := strings.Split(content, "\n\n")
	rulesRaw := strings.Split(sections[0], "\n")
	updatesRaw := strings.Split(sections[1], "\n")

	rules := make([][]int, len(rulesRaw))
	for i, r := range rulesRaw {
		split := strings.Split(r, "|")
		from, err := strconv.Atoi(split[0])
		if err != nil {
			panic(err)
		}
		to, err := strconv.Atoi(split[1])
		if err != nil {
			panic(err)
		}
		rules[i] = []int{from, to}
	}

	updates := make([][]int, len(updatesRaw))
	for i, u := range updatesRaw {
		split := strings.Split(u, ",")
		newUpdate := make([]int, len(split))
		for j, word := range split {
			num, err := strconv.Atoi(word)
			if err != nil {
				panic(err)
			}
			newUpdate[j] = num
		}
		updates[i] = newUpdate
	}

	depends := map[int]map[int]bool{}

	for _, rule := range rules {
		from, to := rule[0], rule[1]
		if depends[from] == nil {
			depends[from] = map[int]bool{}
		}
		depends[from][to] = true
	}

	invalid := [][]int{}
	for _, update := range updates {
		valid := true

		for i, num := range update {
			for j := i + 1; j < len(update); j++ {
				cur := update[j]
				if depends[num][cur] {
					continue
				}
				valid = false
				break
			}
			if !valid {
				break
			}
		}
		if !valid {
			invalid = append(invalid, update)
		}
	}

	for _, kase := range invalid {
		slices.SortStableFunc(kase, func(a, b int) int {
			if depends[a][b] {
				return -1
			}else{
				return 1
			}
		})
		res += kase[len(kase)/2]
	}

	fmt.Println(res)
}

// answer: 4121