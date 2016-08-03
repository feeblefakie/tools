package table

import (
	"math/rand"
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
