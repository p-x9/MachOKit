#!/bin/bash

TARGET='MachOKit'

preview_docc() {
  mkdir -p docs

  $(xcrun --find docc) preview \
    "./${TARGET}.docc" \
    --additional-symbol-graph-dir symbol-graphs \
    --output-path "docs"
}

sh ./scripts/generate-symbols.sh

preview_docc
