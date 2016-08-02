package main

import (
	"bufio"
	"fmt"
	"os"
	"runtime"
	"sync"
)

func main() {
	// TODO: use flag
	var sf int64 = 1
	var numChunks int64 = 10
	//var steps []int = nil
	var alpha int64 = 10
	var beta int64 = 10
	var parallelism int64 = 2
	dir := "./data"
	texts, err := readTexts("./random.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	runtime.GOMAXPROCS(runtime.NumCPU())

	var i int64
	var j int64
	for i = 0; i < numChunks; i++ {
		var wg sync.WaitGroup
		for j = i; j < i+parallelism && j < numChunks; j++ {
			wg.Add(1)
			fmt.Printf("generating chunk %d\n", j)
			config := &ChunkConfig{
				id:    j,
				total: numChunks,
				alpha: alpha,
				beta:  beta,
				sf:    sf,
				seed:  j,
				dir:   dir,
				texts: texts,
			}
			go func(config *ChunkConfig) {
				genChunk(config)
				wg.Done()
			}(config)
		}
		wg.Wait()
		i = j - 1
	}
}

func genChunk(config *ChunkConfig) error {
	tableTypes := []TableType{T1, T2, T3}

	for _, tableType := range tableTypes {
		table, err := NewTable(tableType, config)

		err = table.OpenFile()
		if err != nil {
			fmt.Println(err)
			return err
		}
		defer table.CloseFile()

		cardinality := table.GetCardinality()
		var (
			start int64 = cardinality / config.total * config.id
			end   int64 = cardinality / config.total * (config.id + 1)
		)

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
