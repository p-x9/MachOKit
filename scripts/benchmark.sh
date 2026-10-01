#!/usr/bin/env bash

set -euo pipefail

# This script can run directly from a checkout or from GitHub Actions.
#
# Run the current checkout:
#   scripts/benchmark.sh
#
# Compare the current checkout with another checkout:
#   BENCHMARK_MODE=compare BASELINE_ROOT=/path/to/baseline scripts/benchmark.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BENCHMARK_MODE="${BENCHMARK_MODE:-run}"
BENCHMARK_FILTER="${BENCHMARK_FILTER:-}"
BENCHMARK_PAIRS="${BENCHMARK_PAIRS:-1}"
CANDIDATE_ROOT="${CANDIDATE_ROOT:-$REPOSITORY_ROOT}"
BASELINE_ROOT="${BASELINE_ROOT:-}"
BENCHMARK_RESULTS_DIR="${BENCHMARK_RESULTS_DIR:-/tmp/machokit-benchmark-results}"
MACHOKIT_BENCH_MACHO="${MACHOKIT_BENCH_MACHO:-$BENCHMARK_RESULTS_DIR/MachOKitBenchmarks-fixture}"
BENCHMARK_DISABLE_JEMALLOC="${BENCHMARK_DISABLE_JEMALLOC:-1}"

export BENCHMARK_DISABLE_JEMALLOC
export MACHOKIT_BENCH_MACHO

fail() {
  echo "benchmark: $*" >&2
  exit 1
}

canonical_directory() {
  local path="$1"
  [[ -d "$path" ]] || fail "directory does not exist: $path"
  (cd "$path" && pwd)
}

case "$BENCHMARK_MODE" in
run | compare)
  ;;
*)
  fail "BENCHMARK_MODE must be 'run' or 'compare'"
  ;;
esac

case "$BENCHMARK_PAIRS" in
1 | 3)
  ;;
*)
  fail "BENCHMARK_PAIRS must be '1' or '3'"
  ;;
esac

CANDIDATE_ROOT="$(canonical_directory "$CANDIDATE_ROOT")"
[[ -d "$CANDIDATE_ROOT/Benchmarks" ]] || fail "candidate has no Benchmarks directory"

if [[ "$BENCHMARK_MODE" == "compare" ]]; then
  [[ -n "$BASELINE_ROOT" ]] || fail "BASELINE_ROOT is required in compare mode"
  BASELINE_ROOT="$(canonical_directory "$BASELINE_ROOT")"
  [[ -e "$BASELINE_ROOT/.git" ]] || fail "baseline must be a Git checkout"
  [[ -d "$BASELINE_ROOT/Benchmarks" ]] || fail "baseline has no Benchmarks directory"
  [[ "$BASELINE_ROOT" != "$CANDIDATE_ROOT" ]] || fail "baseline and candidate must be different directories"
fi

mkdir -p "$BENCHMARK_RESULTS_DIR"
SUMMARY_FILE="$BENCHMARK_RESULTS_DIR/summary.md"
: > "$SUMMARY_FILE"

append_summary() {
  local section_file="$1"
  cat "$section_file" >> "$SUMMARY_FILE"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    cat "$section_file" >> "$GITHUB_STEP_SUMMARY"
  fi
}

prepare_benchmark_sources() {
  # The baseline checkout is disposable. Mirror the candidate's benchmark
  # definitions and dependency lock so only the MachOKit source ref differs.
  rsync -a --delete \
    --exclude .benchmarkBaselines/ \
    --exclude .build/ \
    --exclude .swiftpm/ \
    --exclude result.txt \
    "$CANDIDATE_ROOT/Benchmarks/" \
    "$BASELINE_ROOT/Benchmarks/"
}

build_benchmarks() {
  local checkout="$1"
  local label="$2"
  (
    cd "$checkout/Benchmarks"
    swift build -c release --product MachOKitBenchmarks
  ) 2>&1 | tee "$BENCHMARK_RESULTS_DIR/build-$label.log"
}

create_fixed_fixture() {
  local candidate_bin_path
  candidate_bin_path="$(
    cd "$CANDIDATE_ROOT/Benchmarks"
    swift build -c release --show-bin-path
  )"
  cp "$candidate_bin_path/MachOKitBenchmarks" "$MACHOKIT_BENCH_MACHO"
}

record_environment() {
  local section_file="$BENCHMARK_RESULTS_DIR/environment.md"
  local cpu
  local candidate_sha
  local baseline_sha="not applicable"
  local filter_display

  cpu="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || uname -m)"
  candidate_sha="$(git -C "$CANDIDATE_ROOT" rev-parse HEAD)"
  if [[ "$BENCHMARK_MODE" == "compare" ]]; then
    baseline_sha="$(git -C "$BASELINE_ROOT" rev-parse HEAD)"
  fi

  filter_display="${BENCHMARK_FILTER//$'\n'/ }"
  filter_display="${filter_display//$'\r'/ }"
  filter_display="${filter_display//\`/\\\`}"
  filter_display="${filter_display//|/\\|}"

  {
    echo "## Benchmark environment"
    echo
    echo "| Item | Value |"
    echo "| --- | --- |"
    echo "| Mode | \`$BENCHMARK_MODE\` |"
    echo "| Candidate | \`$candidate_sha\` |"
    echo "| Baseline | \`$baseline_sha\` |"
    echo "| Runner | \`${RUNNER_NAME:-local} (${RUNNER_OS:-$(uname -s)})\` |"
    echo "| Runner image | \`${ImageOS:-unknown} ${ImageVersion:-unknown}\` |"
    echo "| CPU | \`$cpu\` |"
    echo "| Memory | \`$(sysctl -n hw.memsize) bytes\` |"
    echo "| Xcode | \`$(xcodebuild -version | tr '\n' ' ')\` |"
    echo "| Fixture SHA-256 | \`$(shasum -a 256 "$MACHOKIT_BENCH_MACHO" | awk '{print $1}')\` |"
    echo "| Filter | \`${filter_display:-all benchmarks}\` |"
    if [[ "$BENCHMARK_MODE" == "compare" ]]; then
      echo "| Pairs | \`$BENCHMARK_PAIRS\` |"
    else
      echo "| Pairs | \`not applicable\` |"
    fi
    echo
  } > "$section_file"

  append_summary "$section_file"
}

benchmark_args=(--no-progress --quiet)
if [[ -n "$BENCHMARK_FILTER" ]]; then
  benchmark_args+=(--filter "$BENCHMARK_FILTER")
fi

run_baseline() {
  local checkout="$1"
  local baseline_name="$2"
  local log_file="$3"
  (
    cd "$checkout/Benchmarks"
    swift package --allow-writing-to-package-directory benchmark baseline update \
      "$baseline_name" \
      "${benchmark_args[@]}"
  ) 2>&1 | tee "$log_file"
}

copy_baseline_to_candidate() {
  local baseline_name="$1"
  local source_dir="$BASELINE_ROOT/Benchmarks/.benchmarkBaselines/MachOKitBenchmarks/$baseline_name"
  local destination_dir="$CANDIDATE_ROOT/Benchmarks/.benchmarkBaselines/MachOKitBenchmarks/$baseline_name"
  mkdir -p "$destination_dir"
  cp "$source_dir/results.json" "$destination_dir/results.json"
}

export_baseline() {
  local baseline_name="$1"
  local output_dir="$2"
  mkdir -p "$output_dir/samples"
  (
    cd "$CANDIDATE_ROOT/Benchmarks"
    swift package --allow-writing-to-directory "$output_dir/samples" \
      benchmark baseline read "$baseline_name" \
      --format histogramSamples \
      --path "$output_dir/samples" \
      --no-progress \
      --quiet
  )
  cp "$CANDIDATE_ROOT/Benchmarks/.benchmarkBaselines/MachOKitBenchmarks/$baseline_name/results.json" \
    "$output_dir/$baseline_name.results.json"
}

run_single() {
  local section_file="$BENCHMARK_RESULTS_DIR/run.md"

  run_baseline "$CANDIDATE_ROOT" candidate "$BENCHMARK_RESULTS_DIR/run.log"

  {
    echo "## Benchmark results"
    echo
    (
      cd "$CANDIDATE_ROOT/Benchmarks"
      swift package benchmark baseline read candidate \
        --format markdown \
        --no-progress
    )
  } > "$section_file"
  append_summary "$section_file"

  export_baseline candidate "$BENCHMARK_RESULTS_DIR"
}

run_comparison() {
  local pair
  local pair_dir
  local baseline_name
  local candidate_name
  local measurement_order

  for ((pair = 1; pair <= BENCHMARK_PAIRS; pair++)); do
    pair_dir="$BENCHMARK_RESULTS_DIR/pair-$pair"
    baseline_name="baseline-pair-$pair"
    candidate_name="candidate-pair-$pair"
    mkdir -p "$pair_dir"

    if ((pair % 2 == 1)); then
      measurement_order="baseline → candidate"
      run_baseline "$BASELINE_ROOT" "$baseline_name" "$pair_dir/baseline.log"
      run_baseline "$CANDIDATE_ROOT" "$candidate_name" "$pair_dir/candidate.log"
    else
      measurement_order="candidate → baseline"
      run_baseline "$CANDIDATE_ROOT" "$candidate_name" "$pair_dir/candidate.log"
      run_baseline "$BASELINE_ROOT" "$baseline_name" "$pair_dir/baseline.log"
    fi

    copy_baseline_to_candidate "$baseline_name"

    {
      echo "## Comparison pair $pair"
      echo
      echo "Measurement order: $measurement_order"
      echo
      (
        cd "$CANDIDATE_ROOT/Benchmarks"
        swift package benchmark baseline compare \
          "$baseline_name" \
          "$candidate_name" \
          --format markdown \
          --no-progress
      )
    } > "$pair_dir/comparison.md"
    append_summary "$pair_dir/comparison.md"

    export_baseline "$baseline_name" "$pair_dir"
    export_baseline "$candidate_name" "$pair_dir"
  done
}

if [[ "$BENCHMARK_MODE" == "compare" ]]; then
  prepare_benchmark_sources
fi

build_benchmarks "$CANDIDATE_ROOT" candidate
if [[ "$BENCHMARK_MODE" == "compare" ]]; then
  build_benchmarks "$BASELINE_ROOT" baseline
fi

create_fixed_fixture
record_environment

if [[ "$BENCHMARK_MODE" == "compare" ]]; then
  run_comparison
else
  run_single
fi

echo "Benchmark results: $BENCHMARK_RESULTS_DIR"
