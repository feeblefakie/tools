package main

import (
	"flag"
	"fmt"
	"math/rand"
)

func main() {
	num := flag.Int64("num", 0, "number of numbers")
	max := flag.Int64("max", 0, "max number")
	flag.Parse()

	r := rand.New(rand.NewSource(1))
	i := int64(0)
	for i = 0; i < *num; i++ {
		fmt.Printf("%d\n", r.Int63n(*max+1))
	}

	return
}
