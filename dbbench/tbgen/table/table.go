package table

import (
	"errors"
	"fmt"
	"math/rand"
	"os"
	"path"
)

var (
	ErrInvalidTableType = errors.New("tokyo benchmark: invalid table type")
)

const (
	NumBlocks       = 1000
	BaseCardinality = 10000000 // this should be dividable by NumBlocks
)

type TableGenerator interface {
	OpenFile() error
	CloseFile() error
	Flush() error
	MakeBlocks() error
	makeRecord(key int64, blockIndex int) error
}

type t1Columns struct {
	c1 int64
	c2 int32
	c3 int64
	c4 int64
	c5 string
}

type t2Columns struct {
	c1 int64
	c2 int64
	c3 int64
	c4 int64
	c5 string
}

type t3Columns struct {
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
	gens   [][]NumberGenerator
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

// a chunk consists of multiple consecutive blocks
type ChunkConfig struct {
	Id         int64
	Total      int64
	Sf         int64
	Alpha      int64
	Beta       int64
	Dir        string
	Texts      []string
	BlockIds   []int64
	BlockTotal int64
}

type TableType int

const (
	T1 = iota
	T2
	T3
)

func New(tableType TableType, config *ChunkConfig) (TableGenerator, error) {
	buffer := make([]string, 100000)

	t := &table{
		buffer: buffer,
		config: config,
	}

	switch tableType {
	case T1:
		card := config.Sf * BaseCardinality / config.Alpha
		for _, blockId := range config.BlockIds {
			// distinct seed per block
			r := rand.New(rand.NewSource(blockId))
			ngArray := []NumberGenerator{
				nil,
				nil, // TODO for parete
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 0, max: 99},
			}
			t.gens = append(t.gens, ngArray)
		}
		t.name = "T1"
		t.card = card
		return &t1{t}, nil

	case T2:
		card := config.Sf * BaseCardinality / config.Alpha
		for _, blockId := range config.BlockIds {
			r := rand.New(rand.NewSource(blockId))
			ngArray := []NumberGenerator{
				nil,
				&UniformRandom{r: r, min: 1, max: card / config.Beta},
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 0, max: 99},
			}
			t.gens = append(t.gens, ngArray)
		}
		t.name = "T2"
		t.card = card
		return &t2{t}, nil

	case T3:
		card := config.Sf * BaseCardinality / (config.Alpha * config.Beta)
		for _, blockId := range config.BlockIds {
			r := rand.New(rand.NewSource(blockId))
			ngArray := []NumberGenerator{
				nil,
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 1, max: card},
				&UniformRandom{r: r, min: 0, max: 99},
			}
			t.gens = append(t.gens, ngArray)
		}
		t.name = "T3"
		t.card = card
		return &t3{t}, nil

	default:
		return nil, ErrInvalidTableType
	}
}

func (t *table) OpenFile() error {
	filename := fmt.Sprintf("%s/%d/%s-%d", t.config.Dir, t.config.Id, t.name, t.config.Id)

	err := os.MkdirAll(path.Dir(filename), 0777)
	if err != nil {
		return err
	}

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
	t.buffer = nil
	return nil
}

func (t *table) makeBlocks(f func(int64, int) error) error {
	for blockIndex, blockId := range t.config.BlockIds {
		startKey := t.card / t.config.BlockTotal * blockId
		endKey := t.card/t.config.BlockTotal*(blockId+1) - 1

		for i := startKey; i <= endKey; i++ {
			f(i, blockIndex)
		}
	}
	return nil
}

// NOTICE : a little redundant code from lack of (true) polymorphism in go
func (t *t1) MakeBlocks() error {
	return t.makeBlocks(t.makeRecord)
}

func (t *t2) MakeBlocks() error {
	return t.makeBlocks(t.makeRecord)
}

func (t *t3) MakeBlocks() error {
	return t.makeBlocks(t.makeRecord)
}

func (t *t1) makeRecord(key int64, blockIndex int) error {
	var i int32
	for i = 0; i < int32(t.config.Alpha); i++ {
		c := &t1Columns{}
		c.c1 = key
		c.c2 = i
		c.c3 = t.gens[blockIndex][2].GetInt64()
		c.c4 = t.gens[blockIndex][3].GetInt64()
		c.c5 = t.config.Texts[t.gens[blockIndex][4].GetInt64()]

		record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
		t.addToBuffer(record)
	}
	return nil
}

func (t *t2) makeRecord(key int64, blockIndex int) error {
	c := &t2Columns{}
	c.c1 = key
	c.c2 = t.gens[blockIndex][1].GetInt64()
	c.c3 = t.gens[blockIndex][2].GetInt64()
	c.c4 = t.gens[blockIndex][3].GetInt64()
	c.c5 = t.config.Texts[t.gens[blockIndex][4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.addToBuffer(record)
	return nil
}

func (t *t3) makeRecord(key int64, blockIndex int) error {
	c := &t3Columns{}
	c.c1 = key
	c.c2 = t.gens[blockIndex][1].GetInt64()
	c.c3 = t.gens[blockIndex][2].GetInt64()
	c.c4 = t.gens[blockIndex][3].GetInt64()
	c.c5 = t.config.Texts[t.gens[blockIndex][4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.addToBuffer(record)
	return nil
}

func (t *table) addToBuffer(record string) {
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
}
