package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"

	"github.com/hybridgroup/yzma/pkg/llama"
)

func main() {
	if err := run(context.Background()); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v", err)
		os.Exit(1)
	}
}

func run(ctx context.Context) error {
	model, prompt := parseFlags()
	if model == "" || prompt == "" {
		flag.Usage()
		return nil
	}

	l, err := llama.New(model)
	if err != nil {
		return err
	}
	defer l.Free()

	embedding, err := l.NewEmbedding()
	if err != nil {
		return err
	}

	vec, err := embedding.Eval(prompt)
	if err != nil {
		return err
	}

	var b strings.Builder
	for i, v := range vec {
		if i > 0 {
			b.WriteString(" ")
		}
		b.WriteString(fmt.Sprintf("%f", v))
	}
	fmt.Println(b.String())

	return nil
}
