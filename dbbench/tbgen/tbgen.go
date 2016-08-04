package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"

	"./table"
)

var (
	sf          = flag.Int64("sf", 1, "scale factor")
	c           = flag.Int64("c", 1, "the number of chunks")
	s           = flag.String("s", "", "steps(chunk numbers) to generate. ex. 0,2,3. unspecified for all steps")
	alpha       = flag.Int64("alpha", 4, "alpha value")
	beta        = flag.Int64("beta", 10, "beta value")
	parallelism = flag.Int64("p", 1, "parallelism")
	dir         = flag.String("o", "./data", "ouput file directory.")
	textDir     = flag.String("t", "./", "text file directory")
)

func main() {
	flag.Parse()

	texts, err := readTexts(*textDir + "/random.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	var steps []int64
	for _, step := range strings.Split(*s, ",") {
		stepi, err := strconv.ParseInt(step, 10, 64)
		if err != nil {
			continue
		}
		steps = append(steps, stepi)
	}

	runtime.GOMAXPROCS(runtime.NumCPU())

	var i int64
	var j int64
	passed := int64(0)
	for i = 0; i < *c; i++ {
		var wg sync.WaitGroup
		for j = i; j < i+*parallelism+passed && j < *c; j++ {
			// process only specified steps
			if len(*s) > 0 {
				pass := true
				for k := 0; k < len(steps); k++ {
					if j == steps[k] {
						pass = false
						break
					}
				}
				if pass {
					passed++
					continue
				}
			}

			fmt.Printf("generating chunk %d\n", j)
			wg.Add(1)
			config := &table.ChunkConfig{
				Id:    j,
				Total: *c,
				Alpha: *alpha,
				Beta:  *beta,
				Sf:    *sf,
				Seed:  j,
				Dir:   *dir,
				Texts: texts,
			}
			go func(config *table.ChunkConfig) {
				genChunk(config)
				wg.Done()
			}(config)
		}
		wg.Wait()
		i = j - 1
	}
}

func genChunk(config *table.ChunkConfig) error {
	tableTypes := []table.TableType{table.T1, table.T2, table.T3}

	for _, tableType := range tableTypes {
		table, err := table.New(tableType, config)
		if err != nil {
			fmt.Println(err)
			return err
		}

		err = table.OpenFile()
		if err != nil {
			fmt.Println(err)
			return err
		}
		defer table.CloseFile()

		start := table.GetStartKey()
		end := table.GetEndKey()

		var i int64
		for i = start; i <= end; i++ {
			table.MakeRecord(i)
		}
		table.Flush()
	}

	return nil
}

func readTexts(filename string) ([]string, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var texts []string
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		texts = append(texts, scanner.Text())
	}
	return texts, nil
}
