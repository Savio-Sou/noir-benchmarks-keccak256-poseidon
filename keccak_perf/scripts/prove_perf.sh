#!/usr/bin/env bash
set -euo pipefail

# Simple perf harness around proving with production bb.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PACKAGE="${PACKAGE:-keccak_perf}"
PROOF_NAME="${PROOF_NAME:-perf}"
ITERATIONS="${ITERATIONS:-3}"
BACKEND="${BACKEND:-bb}"
BB_CRS_PATH="${BB_CRS_PATH:-}"
BB_SCHEME="${BB_SCHEME:-ultra_honk}"
NARGO_BIN="${NARGO_BIN:-nargo}"
VK_DIR="${VK_DIR:-target/${PACKAGE}.vk}"
VK_PATH="${VK_PATH:-${VK_DIR}/vk}"

BYTECODE="target/${PACKAGE}.json"
WITNESS="target/${PACKAGE}.gz"
OUTPUT_DIR="${OUTPUT_DIR:-target/proofs}"
BENCH_DIR="${BENCH_DIR:-target/bench}"

if ! command -v "$BACKEND" >/dev/null 2>&1; then
    echo "bb binary not found (looked for '$BACKEND'). Set BACKEND to your production bb." >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR" "$BENCH_DIR"

echo "Compiling circuit with ${NARGO_BIN}..."
"$NARGO_BIN" compile

echo "Building witness with ${NARGO_BIN}..."
"$NARGO_BIN" execute --silence-warnings

crs_args=()
if [[ -n "$BB_CRS_PATH" ]]; then
    crs_args=(--crs_path "$BB_CRS_PATH")
fi

echo "Writing verification key with ${BACKEND}..."
"$BACKEND" write_vk \
    --scheme "$BB_SCHEME" \
    -b "$BYTECODE" \
    -o "$VK_DIR" \
    "${crs_args[@]}"

for i in $(seq 1 "$ITERATIONS"); do
    proof_path="${OUTPUT_DIR}/${PROOF_NAME}-${i}.proof"
    bench_json="${BENCH_DIR}/${PROOF_NAME}-${i}.json"
    bench_log="${BENCH_DIR}/${PROOF_NAME}-${i}.log"

    echo "[${i}/${ITERATIONS}] Proving with ${BACKEND} (scheme=${BB_SCHEME})..."
    start_time=$(date +%s.%N)
    {
        "$BACKEND" prove \
            --scheme "$BB_SCHEME" \
            -b "$BYTECODE" \
            -w "$WITNESS" \
            -k "$VK_PATH" \
            -o "$proof_path" \
            --bench_out "$bench_json" \
            --print_bench \
            "${crs_args[@]}"
    } 2>&1 | tee "$bench_log"
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l)

    printf "Proof %s time: %.2f seconds\n" "$PROOF_NAME" "$duration" | tee -a "$bench_log"
    echo "Proof: ${proof_path}"
    echo "Bench JSON: ${bench_json}"
    echo "Log: ${bench_log}"
done
