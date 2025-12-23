# keccak_perf

Small Noir circuit that stress-tests a Keccak256 hash with a configurable number of permutation rounds (`NUM_ROUNDS` in `src/main.nr`).

## Quick start
- Run tests: `nargo test`
- Execute example input (zeroed message): `nargo execute --silence-warnings`

## Proving perf script (production bb)
`scripts/prove_perf.sh` wraps compilation, witness generation, and repeated proving with your production `bb`, recording timing and bench output.

Example:
```bash
BACKEND=/path/to/bb \           # production bb binary
BB_CRS_PATH=/path/to/crs \      # optional; skip if bb can fetch CRS
BB_SCHEME=ultra_honk \          # bb prove --scheme
VK_DIR=target/keccak_perf.vk \  # where to cache/read the verification key dir
ITERATIONS=1 \                  # number of proof runs
PROOF_NAME=perf \               # prefix for output files
./scripts/prove_perf.sh
```

With all defaults (expects `bb` in PATH, `nargo` available, and optional CRS downloads permitted):
```bash
./scripts/prove_perf.sh
```

The script writes a verification key once (`bb write_vk`, to `VK_DIR`/`vk`) and reuses it for each proof run.

Outputs:
- Proofs: `target/proofs/<PROOF_NAME>-<i>.proof`
- Bench JSON + logs: `target/bench/<PROOF_NAME>-<i>.json` and `.log`

Notes:
- The script uses `nargo compile` and `nargo execute` before proving.
- If `BB_CRS_PATH` is unset, bb may attempt to download CRS; set it explicitly when running in restricted environments.
