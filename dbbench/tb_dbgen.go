package main

import (
	"bufio"
	"errors"
	"fmt"
	"math/rand"
	"os"
	"sync"
)

var (
	ErrInvalidTableType = errors.New("tokyo benchmark: invalid table type")
)

type UniformRandom struct {
	r   *rand.Rand
	min int64
	max int64
}

/*
type PareteRandom struct {
	r *rand.Rand
}
*/

type NumberGenerator interface {
	GetInt64() int64
}

func (ur *UniformRandom) GetInt64() int64 {
	return ur.r.Int63n(ur.max-ur.min) + ur.min
}

type T1Columns struct {
	c1 int64
	c2 int32
	c3 int64
	c4 int64
	c5 string
}

type T2Columns struct {
	c1 int64
	c2 int64
	c3 int64
	c4 int64
	c5 string
}

type T3Columns struct {
	c1 int64
	c2 int64
	c3 int64
	c4 int64
	c5 string
}

type table struct {
	name   string
	buffer []string
	file   *os.File
	gens   []NumberGenerator
	card   int64
	config *ChunkConfig
}

type t1 struct {
	*table
}

type t2 struct {
	*table
}

type t3 struct {
	*table
}

type ChunkConfig struct {
	id    int64
	total int64
	sf    int64
	alpha int64
	beta  int64
	seed  int64
	dir   string
	texts []string
}

type TableGenerator interface {
	OpenFile() error
	CloseFile() error
	Flush() error
	GetCardinality() int64
	MakeRecord(offset int64) error
}

type TableType int

const (
	T1 = iota
	T2
	T3
)

func NewTable(tableType TableType, config *ChunkConfig) (TableGenerator, error) {

	r := rand.New(rand.NewSource(config.seed))
	buffer := make([]string, 10000)

	t := &table{
		buffer: buffer,
		config: config,
	}

	switch tableType {
	case T1:
		card := config.sf * 10000000 / config.alpha
		gens := []NumberGenerator{
			nil,
			nil, // TODO for parete
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 0, max: 99},
		}
		t.name = "T1"
		t.gens = gens
		t.card = card
		return &t1{t}, nil

	case T2:
		card := config.sf * 10000000 / config.alpha
		gens := []NumberGenerator{
			nil,
			&UniformRandom{r: r, min: 1, max: card / config.beta},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 0, max: 99},
		}
		t.name = "T2"
		t.gens = gens
		t.card = card
		return &t2{t}, nil

	case T3:
		card := config.sf * 10000000 / (config.alpha * config.beta)
		gens := []NumberGenerator{
			nil,
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 0, max: 99},
		}
		t.name = "T3"
		t.gens = gens
		t.card = card
		return &t3{t}, nil

	default:
		return nil, ErrInvalidTableType
	}

}

func (t *table) OpenFile() error {
	filename := fmt.Sprintf("%s/%s-%d", t.config.dir, t.name, t.config.id)
	fmt.Println(filename)
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	t.file = f
	return nil
}

func (t *table) CloseFile() error {
	return t.file.Close()
}

func (t *table) Flush() error {
	for _, record := range t.buffer {
		t.file.WriteString(record)
	}
	return nil
}

func (t *table) GetCardinality() int64 {
	return t.card
}

func (t *table) MakeRecord(offset int64) error {
	panic("please override this method")
}

func (t *t1) MakeRecord(offset int64) error {
	var i int32
	for i = 0; i < int32(t.config.alpha); i++ {
		c := &T1Columns{}
		c.c1 = offset
		c.c2 = i
		c.c3 = t.gens[2].GetInt64()
		c.c4 = t.gens[3].GetInt64()
		c.c5 = t.config.texts[t.gens[4].GetInt64()]

		record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
		t.buffer = append(t.buffer, record)
		if len(t.buffer) == cap(t.buffer) {
			t.Flush()
		}
	}
	return nil
}

func (t *t2) MakeRecord(offset int64) error {
	c := &T2Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.texts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
	return nil
}

func (t *t3) MakeRecord(offset int64) error {
	c := &T3Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.texts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
	return nil
}

func main() {
	var sf int64 = 1
	var numChunks int64 = 10
	//var steps []int = nil
	var alpha int64 = 10
	var beta int64 = 10
	var parallelism int64 = 2
	dir := "./data"
	texts, err := readRandomTexts("./random.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	// TODO: use flag

	var i int64
	var j int64
	for i = 0; i <= numChunks; i++ {
		var wg sync.WaitGroup
		for j = i; j < i+parallelism && j <= numChunks; j++ {
			wg.Add(1)
			fmt.Printf("processing chunk %d\n", j)
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
		i += j - 1
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

func readRandomTexts(filename string) ([]string, error) {
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
