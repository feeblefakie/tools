package main

import (
	"flag"
	"fmt"
	"math/rand"
)

const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func main() {
	n := flag.Int("n", 68, "length of a text")
	flag.Parse()

	for i := 0; i < 100; i++ {
		fmt.Println(genRandText(*n))
	}

	return
}

func genRandText(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
