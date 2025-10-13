package main

import (
	"flag"
	"fmt"
	"os"
)

const usage = `
  -model string
    	path to the GGUF model
  -prompt string
    	prompt to embed
`

func parseFlags() (string, string) {
	var model, prompt string
	flag.StringVar(&model, "model", "", "path to the GGUF model")
	flag.StringVar(&prompt, "prompt", "", "prompt to embed")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "usage: embeddings %s
", usage)
	}
	flag.Parse()
	return model, prompt
}
