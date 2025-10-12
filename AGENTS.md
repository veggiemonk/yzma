# Repository Guidelines

## Project Structure & Module Organization
Core Go packages live under `pkg/`: `llama` exposes FFI wrappers, `mtmd` handles multimodal helpers, `loader` locates shared libraries, and `utils` hosts shared helpers. Example apps live in `examples/` with matching assets in `images/`. Keep downloaded `llama.cpp` binaries in `lib/` and point environment variables there. The module entry point `yzma.go` mirrors the root defined in `go.mod`.

## Build, Test, and Development Commands
- `go build ./...` ensures packages and samples compile against the linked libraries.
- `go test ./...` runs the suite; export `YZMA_TEST_MODEL` to target a local GGUF during llama tests.
- `go run ./examples/<name>/ -model ./models/<file>` executes a sample (`chat`, `hello`, `vlm`).
- `go fmt ./...` (or an editor auto-format) keeps sources canonical before review.

## Coding Style & Naming Conventions
Stick to idiomatic Go: tabs, one declaration per line, and PascalCase for exported symbols with concise doc comments. Use `camelCase` for locals and package-level variables. Prefer descriptive package aliases over single letters when importing external modules. New examples should follow the `examples/<topic>/main.go` pattern and include short flag help. Run `goimports` alongside `go fmt` to maintain import grouping.

## Testing Guidelines
All tests use the standard library’s `testing` package. Integration helpers in `pkg/llama/helpers_test.go` load native libraries through `YZMA_LIB`; ensure that variable (and on Linux, `LD_LIBRARY_PATH`) point to the directory in `lib/`. Keep tests deterministic and table-driven where possible, and skip GPU-specific paths unless they prove unique behavior. Maintain coverage in `pkg/llama`, the highest-risk bindings layer, and document any model prerequisites in test comments.

## Commit & Pull Request Guidelines
History follows Conventional Commits (`feature:`, `fix:`, `docs:`, etc.); keep subject lines under 72 characters and use the body for rationale or follow-up steps. Pull requests should summarize scope, call out testing evidence (`go test ./...` output or demo transcripts), and link related issues or roadmap entries. Flag any new models, environment variables, or manual steps so reviewers can reproduce quickly.

## Model Assets & Environment Notes
Do not commit GGUF assets; instead, store them under `models/` (ignored by git) and reference filenames in docs. Mention hardware (CPU/GPU) and backend (`CUDA`, `Vulkan`, `Metal`, etc.) when sharing performance numbers so others can compare results. Update the `lib/README.md` if library requirements change, keeping installation instructions in sync.
