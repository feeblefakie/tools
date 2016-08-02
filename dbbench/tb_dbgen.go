package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"sync"
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

type T1 struct {
	name   string
	buffer []string
	file   *os.File
	gens   []NumberGenerator
	card   int64
	config *Config
}

type T2 struct {
	name   string
	buffer []string
	file   *os.File
	gens   []NumberGenerator
	card   int64
	config *Config
}

type T3 struct {
	name   string
	buffer []string
	file   *os.File
	gens   []NumberGenerator
	card   int64
	config *Config
}

type Config struct {
	sf          int64
	alpha       int64
	beta        int64
	seed        int64
	numChunks   int64
	baseDir     string
	randomTexts []string
}

type TableGenerator interface {
	OpenFile(suffix string) error
	CloseFile() error
	MakeRecord(offset int64, step uint32) error
	Flush() error
	GetCardinality() int64
}

func T1New(name string, config *Config) (*T1, error) {
	r := rand.New(rand.NewSource(config.seed))
	card := config.sf * 10000000 / config.alpha
	gens := []NumberGenerator{
		nil,
		nil, // TODO for parete
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 0, max: 99},
	}

	t := &T1{
		name:   name,
		buffer: make([]string, 10000),
		gens:   gens,
		card:   card,
		config: config,
	}

	return t, nil
}

func (t *T1) OpenFile(suffix string) error {
	filename := t.config.baseDir + "/" + t.name + "-" + suffix
	fmt.Println(filename)
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	t.file = f
	return nil
}

func (t *T1) CloseFile() error {
	return t.file.Close()
}

func (t *T1) MakeRecord(offset int64, step uint32) error {
	var i int32
	for i = 0; i < int32(t.config.alpha); i++ {
		c := &T1Columns{}
		c.c1 = offset
		c.c2 = i
		c.c3 = t.gens[2].GetInt64()
		c.c4 = t.gens[3].GetInt64()
		c.c5 = t.config.randomTexts[t.gens[4].GetInt64()]

		record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
		t.buffer = append(t.buffer, record)
		if len(t.buffer) == cap(t.buffer) {
			t.Flush()
		}
	}
	return nil
}

func (t *T1) Flush() error {
	for _, record := range t.buffer {
		t.file.WriteString(record)
	}
	return nil
}

func (t *T1) GetCardinality() int64 {
	return t.card
}

func T2New(name string, config *Config) (*T2, error) {
	r := rand.New(rand.NewSource(config.seed))
	card := config.sf * 10000000 / config.alpha
	gens := []NumberGenerator{
		nil,
		&UniformRandom{r: r, min: 1, max: card / config.beta},
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 0, max: 99},
	}

	t := &T2{
		name:   name,
		buffer: make([]string, 10000),
		gens:   gens,
		card:   card,
		config: config,
	}

	return t, nil
}

func (t *T2) OpenFile(suffix string) error {
	filename := t.config.baseDir + "/" + t.name + "-" + suffix
	fmt.Println(filename)
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	t.file = f
	return nil
}

func (t *T2) CloseFile() error {
	return t.file.Close()
}

func (t *T2) MakeRecord(offset int64, step uint32) error {
	c := &T2Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.randomTexts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
	return nil
}

func (t *T2) Flush() error {
	for _, record := range t.buffer {
		t.file.WriteString(record)
	}
	return nil
}

func (t *T2) GetCardinality() int64 {
	return t.card
}

func T3New(name string, config *Config) (*T3, error) {
	r := rand.New(rand.NewSource(config.seed))
	card := config.sf * 10000000 / (config.alpha * config.beta)
	gens := []NumberGenerator{
		nil,
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 1, max: card},
		&UniformRandom{r: r, min: 0, max: 99},
	}

	t := &T3{
		name:   name,
		buffer: make([]string, 10000),
		gens:   gens,
		card:   card,
		config: config,
	}

	return t, nil
}

func (t *T3) OpenFile(suffix string) error {
	filename := t.config.baseDir + "/" + t.name + "-" + suffix
	fmt.Println(filename)
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	t.file = f
	return nil
}

func (t *T3) CloseFile() error {
	return t.file.Close()
}

func (t *T3) MakeRecord(offset int64, step uint32) error {
	c := &T3Columns{}
	c.c1 = offset
	c.c2 = t.gens[1].GetInt64()
	c.c3 = t.gens[2].GetInt64()
	c.c4 = t.gens[3].GetInt64()
	c.c5 = t.config.randomTexts[t.gens[4].GetInt64()]

	record := fmt.Sprintf("%d,%d,%d,%d,%s\n", c.c1, c.c2, c.c3, c.c4, c.c5)
	t.buffer = append(t.buffer, record)
	if len(t.buffer) == cap(t.buffer) {
		t.Flush()
	}
	return nil
}

func (t *T3) Flush() error {
	for _, record := range t.buffer {
		t.file.WriteString(record)
	}
	return nil
}

func (t *T3) GetCardinality() int64 {
	return t.card
}

func main() {
	var sf int64 = 1
	var numChunks int64 = 10
	//var steps []int = nil
	var alpha int64 = 10
	var beta int64 = 10
	var parallelism int64 = 5
	baseDir := "./data"
	randomTexts, err := readRandomTexts("./random.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	// TODO: flag

	var i int64
	var j int64
	for i = 0; i <= numChunks; i++ {
		var wg sync.WaitGroup
		for j = i; j < i+parallelism && j <= numChunks; j++ {
			wg.Add(1)
			fmt.Printf("processing chunk %d\n", j)
			config := &Config{
				alpha:       alpha,
				beta:        beta,
				sf:          sf,
				seed:        i,
				baseDir:     baseDir,
				numChunks:   numChunks,
				randomTexts: randomTexts,
			}
			go func(config *Config, chunkId int64) {
				genChunk(config, chunkId)
				wg.Done()
			}(config, j)
		}
		wg.Wait()
		i += j - 1
	}
}

func genChunk(config *Config, chunkId int64) error {
	t1, err := T1New("t1", config)
	if err != nil {
		fmt.Println(err)
		return err
	}
	t2, err := T2New("t2", config)
	if err != nil {
		fmt.Println(err)
		return err
	}
	t3, err := T3New("t3", config)
	if err != nil {
		fmt.Println(err)
		return err
	}
	tables := []TableGenerator{
		t1,
		t2,
		t3,
	}

	for _, table := range tables {
		suffix := fmt.Sprintf("%d", chunkId)
		err = table.OpenFile(suffix)
		if err != nil {
			fmt.Println(err)
			return err
		}
		defer table.CloseFile()

		cardinality := table.GetCardinality()
		var (
			start int64 = cardinality / config.numChunks * chunkId
			end   int64 = cardinality / config.numChunks * (chunkId + 1)
		)

		var i int64
		for i = start; i <= end; i++ {
			table.MakeRecord(i, 0)
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
