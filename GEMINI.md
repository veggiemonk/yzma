# Gemini Code Assistant Context: `yzma` Project

## Project Overview

`yzma` is a Go library that enables local inference with a variety of language models, including Vision Language Models (VLMs), Large Language Models (LLMs), and Small Language Models (SLMs). It acts as a wrapper around the `llama.cpp` library, allowing Go applications to leverage the power of `llama.cpp` for hardware-accelerated inference on local machines.

A key feature of `yzma` is its use of `purego` and `ffi` instead of CGo. This design choice allows developers to use pre-compiled `llama.cpp` dynamic libraries (`.so`, `.dylib`, `.dll`) without needing a C compiler during the build process. It also means the `llama.cpp` libraries can be updated independently of the Go application, as long as there are no breaking API changes.

The project is structured with a core `llama` package that provides Go bindings to the `llama.cpp` functions, and several examples that demonstrate its usage for tasks like interactive chat and multimodal VLM inference.

## Building and Running

The project uses standard Go tooling.

### Prerequisites

1.  **Go:** A recent version of the Go toolchain.
2.  **llama.cpp libraries:** Download the pre-compiled `llama.cpp` libraries for your operating system from the [llama.cpp releases page](https://github.com/ggml-org/llama.cpp/releases).
3.  **Environment Variables:** Set the `YZMA_LIB` environment variable to the path where you extracted the `llama.cpp` libraries. On some systems, you may also need to update your dynamic linker path (e.g., `LD_LIBRARY_PATH` on Linux).

    ```shell
    export YZMA_LIB=/path/to/your/llama/libs
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/path/to/your/llama/libs
    ```

### Running Examples

The `examples` directory contains several programs that demonstrate how to use the `yzma` library.

**Interactive Chat Example:**

This example runs an interactive chat session with a text-based language model.

```shell
# Download a model, for example:
# wget https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-fp16.gguf -O ./models/qwen2.5-0.5b-instruct-fp16.gguf

# Run the chat example
go run ./examples/chat/ -model ./models/qwen2.5-0.5b-instruct-fp16.gguf
```

**Vision Language Model (VLM) Example:**

This example uses a VLM to describe an image based on a text prompt.

```shell
# Download a VLM model and its corresponding multimodal projector
# (See USAGE.md for links)

# Run the VLM example
go run ./examples/vlm/ -model ./models/Qwen2.5-VL-3B-Instruct-Q8_0.gguf \
  -mmproj ./models/mmproj-Qwen2.5-VL-3B-Instruct-Q8_0.gguf \
  -image ./images/domestic_llama.jpg \
  -p "What is in this picture?"
```

### Testing

The project uses the standard Go testing framework. To run the tests for a package, navigate to its directory and run:

```shell
go test
```

## Development Conventions

*   **Go Modules:** The project uses Go modules for dependency management. The main dependencies are `github.com/jupiterrider/ffi` and `github.com/ebitengine/purego`.
*   **Coding Style:** The code follows standard Go formatting and conventions.
*   **Package Structure:** The core logic is located in the `pkg/` directory, with the main `llama.cpp` bindings in `pkg/llama/`.
*   **API Coverage:** The `ROADMAP.md` file tracks the implementation status of wrappers for the `llama.cpp` API, indicating a systematic approach to development.
*   **Error Handling:** Errors are handled using Go's standard error mechanism.
*   **Logging:** The underlying `llama.cpp` library produces logs. The examples show that these can be suppressed for cleaner output by redirecting stderr (`2>/dev/null`) or by using the `llama.LogSet` function.
