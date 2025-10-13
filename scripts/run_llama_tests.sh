#!/usr/bin/env bash

# Run pkg/llama tests with basic environment checks for native libraries and models.

set -euo pipefail

repo_root="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

have_required_libs() {
  local lib_dir="$1"
  [[ -f "$lib_dir/libggml.dylib" || -f "$lib_dir/libggml.so" ]] && \
    [[ -f "$lib_dir/libllama.dylib" || -f "$lib_dir/libllama.so" ]]
}

resolve_lib_dir() {
  if [[ -n "${YZMA_LIB:-}" ]]; then
    echo "$YZMA_LIB"
    return
  fi

  local default_lib="$repo_root/lib"
  if have_required_libs "$default_lib"; then
    export YZMA_LIB="$default_lib"
    echo "$YZMA_LIB"
    return
  fi

  if have_required_libs "$repo_root"; then
    export YZMA_LIB="$repo_root"
    echo "$YZMA_LIB"
    return
  fi

  echo ""  # Signal failure.
}

lib_dir="$(resolve_lib_dir)"
if [[ -z "$lib_dir" ]]; then
  cat >&2 <<'EOF'
Missing llama.cpp shared libraries.
Populate libggml/libllama builds under ./lib or export YZMA_LIB pointing to them.
EOF
  exit 1
fi

# macOS expects DYLD_LIBRARY_PATH, Linux uses LD_LIBRARY_PATH.
case "$(uname -s)" in
  Darwin)
    export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:-}:$lib_dir"
    ;;
  Linux)
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$lib_dir"
    ;;
esac

if [[ -z "${YZMA_TEST_MODEL:-}" ]]; then
  default_model="$(find "$repo_root/models" -maxdepth 1 -type f -name '*.gguf' | head -n1 || true)"
  if [[ -n "$default_model" ]]; then
    export YZMA_TEST_MODEL="$default_model"
    echo "Using YZMA_TEST_MODEL=$YZMA_TEST_MODEL"
  else
    cat >&2 <<'EOF'
Note: YZMA_TEST_MODEL is unset. Model-dependent tests will be skipped.
EOF
  fi
fi

cd "$repo_root"
log_file="$(mktemp -t yzma_llama_test.XXXXXX)"
trap 'rm -f "$log_file"' EXIT

if ! go test -v ./pkg/llama "$@" | tee "$log_file"; then
  if grep -q "VocabFIMRep returned TokenNull" "$log_file"; then
    cat >&2 <<'EOF'
Failure: Model lacks <fim_rep> token required by TestVocabFIMRep.
Provide a GGUF with FIM tokens or skip that test explicitly.
EOF
  fi
  exit 1
fi
