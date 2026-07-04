package calculator

import "testing"

func TestAdd(t *testing.T) {
	result := Add(2, 3)

	if result != 5 {
		t.Fatalf("Add(2,3) = %d; expected 5", result)
	}
}
