#!/bin/bash

TARGET='MachOKit'
REPO_NAME='MachOKit'

generate_docc() {
  mkdir -p docs

  $(xcrun --find docc) convert \
    "./${TARGET}.docc" \
     --output-path "docs" \
     --hosting-base-path "${REPO_NAME}" \
     --additional-symbol-graph-dir ./symbol-graphs
}

sh ./scripts/generate-symbols.sh

generate_docc
