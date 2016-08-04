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

type TableGenerator interface {
	OpenFile() error
	CloseFile() error
	Flush() error
	GetStartKey() int64
	GetEndKey() int64
	MakeRecord(offset int64) error
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
	Id    int64
	Total int64
	Sf    int64
	Alpha int64
	Beta  int64
	Seed  int64
	Dir   string
	Texts []string
}

type TableType int

const (
	T1 = iota
	T2
	T3
)

func New(tableType TableType, config *ChunkConfig) (TableGenerator, error) {
	r := rand.New(rand.NewSource(config.Seed))
	buffer := make([]string, 100000)

	t := &table{
		buffer: buffer,
		config: config,
	}

	switch tableType {
	case T1:
		card := config.Sf * 10000000 / config.Alpha
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
		card := config.Sf * 10000000 / config.Alpha
		gens := []NumberGenerator{
			nil,
			&UniformRandom{r: r, min: 1, max: card / config.Beta},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 1, max: card},
			&UniformRandom{r: r, min: 0, max: 99},
		}
		t.name = "T2"
		t.gens = gens
		t.card = card
		return &t2{t}, nil

	case T3:
		card := config.Sf * 10000000 / (config.Alpha * config.Beta)
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
	return nil
}

func (t *table) GetStartKey() int64 {
	return t.card / t.config.Total * t.config.Id
}

func (t *table) GetEndKey() int64 {
	return t.card / t.config.Total * (t.config.Id + 1)
}

func (t *table) addToBuffer(record string) {
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
}

func (t *table) MakeRecord(offset int64) error {
	panic("this method must be overridden.")
}

func (t *t1) MakeRecord(offset int64) error {
	var i int32
	for i = 0; i < int32(t.config.Alpha); i++ {
		c := &t1Columns{}
		c.c1 = offset
		c.c2 = i
		c.c3 = t.gens[2].GetInt64()
		c.c4 = t.gens[3].GetInt64()
		c.c5 = t.config.Texts[t.gens[4].GetInt64()]

		record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
		t.addToBuffer(record)
	}
	return nil
}

func (t *t2) MakeRecord(offset int64) error {
	c := &t2Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.Texts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.addToBuffer(record)
	return nil
}

func (t *t3) MakeRecord(offset int64) error {
	c := &t3Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.Texts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.addToBuffer(record)
	return nil
}
