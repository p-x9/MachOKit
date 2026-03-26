#!/bin/bash

TARGET='MachOKit'

preview_docc() {
  mkdir -p docs

  $(xcrun --find docc) preview \
    "./Sources/${TARGET}/Documentation.docc" \
    --additional-symbol-graph-dir symbol-graphs \
    --output-path "docs"
}

sh ./scripts/generate-symbols.sh

preview_docc
