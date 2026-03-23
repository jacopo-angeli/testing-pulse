# testing-pulse

A project combining a Rust implementation of the [Raft consensus algorithm](https://en.wikipedia.org/wiki/Raft_(algorithm)) with formal verification of critical components using [F\*](https://fstar-lang.org/) and [Pulse](https://github.com/FStarLang/pulse).

## Overview

This repository brings together two complementary approaches to building a reliable distributed consensus system:

| Component | Language / Tooling | Purpose |
|-----------|-------------------|---------|
| [`raft-rs`](./raft-rs/) | Rust + Tokio | Production-oriented async Raft implementation |
| [`raft-fstar`](./raft-fstar/) | F\* + Pulse + KaRaMeL | Formal verification of the heartbeat handler |

The idea is to use F\*/Pulse to formally verify the correctness of the most security-sensitive logic (e.g., the heartbeat handler that governs leader demotion), then extract that verified logic to Rust via the Pulse2Rust tool and integrate it with the broader Raft implementation.

## Repository Structure

```
testing-pulse/
├── .devcontainer/          # VS Code Dev Container (F*, Pulse, KaRaMeL, Rust)
├── .docker/                # Docker image for the F* toolchain
├── .github/
│   └── workflows/
│       └── ci.yml          # CI pipeline (fmt, clippy, machete, test, build)
├── raft-fstar/             # F*/Pulse source and extracted Rust output
│   ├── HeartbeatHandler.fst    # Verified heartbeat handler
│   ├── Makefile                # Verify and extract targets
│   └── extracted/
│       ├── HeartbeatHandler.ast
│       └── heartbeathandler.rs # Auto-generated Rust from F*
└── raft-rs/                # Raft consensus library (git submodule)
```

## Components

### `raft-rs` — Rust Raft Implementation

A fast, asynchronous Raft library built on the [Tokio](https://tokio.rs/) runtime.

**Key features:**
- Asynchronous I/O with zero-copy support
- Leader election and log replication
- Log compaction and snapshot support
- Dynamic cluster membership changes
- Leadership preferences and configurable default leader
- Replica repair (TigerBeetle-style) for corrupted or malicious storage

See [`raft-rs/README.md`](./raft-rs/README.md) for the full feature list and roadmap.

### `raft-fstar` — Formal Verification with F\* and Pulse

The `HeartbeatHandler.fst` module contains a formally verified implementation of the Raft heartbeat handling logic, written in [Pulse](https://github.com/FStarLang/pulse) (a separation-logic DSL embedded in F\*).

The verified functions include:

- **`extract_term`** — Reads the term from a raw byte array (big-endian, bytes 4–7).
- **`extract_leader_id`** — Reads the leader ID from a raw byte array (big-endian, bytes 0–3).
- **`handle_heartbeat`** — Decides whether a leader should step down based on an incoming heartbeat message, taking into account `default_leader` configuration.

After verification, the F\* code is extracted to Rust via the Pulse2Rust tool (output in `raft-fstar/extracted/heartbeathandler.rs`).

## Development Environment

A fully configured Dev Container is provided with all required tools (F\*, Pulse, KaRaMeL, Z3, Rust).

### Using VS Code Dev Containers

1. Install [Docker](https://docs.docker.com/get-docker/) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open this repository in VS Code.
3. When prompted, click **Reopen in Container** (or run **Dev Containers: Reopen in Container** from the command palette).

The container installs the [FStarLang VS Code Assistant](https://marketplace.visualstudio.com/items?itemName=FStarLang.fstar-vscode-assistant) extension automatically.

## Getting Started

### Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (for `raft-rs`)
- F\*, Pulse, KaRaMeL, and Z3 ≥ 4.13.3 (for `raft-fstar` — easiest via the Dev Container)

### Running the Raft Examples

```sh
cd raft-rs

# Start a 5-node cluster
cargo run --example simple_run

# Simulate node failures
cargo run --example simulate_node_failure

# Simulate dynamic membership changes
cargo run --example simulate_add_node

# Simulate replica repair
cargo run --example simulate_replica_repair
```

### Building the Rust Library

```sh
cd raft-rs
cargo build --release
```

### Running Tests

```sh
cd raft-rs
cargo test
```

### Verifying and Extracting the F\* Code

> Run these commands inside the Dev Container where the F\* toolchain is available.

```sh
cd raft-fstar

# Verify the F* source and extract to Rust
make

# Verify only
make verify

# Extract only (assumes already verified)
make extract

# Clean extracted artifacts and rebuild
make rebuild
```

## CI

The CI pipeline (`.github/workflows/ci.yml`) runs on every push and pull request:

1. `cargo fmt --check` — Code formatting
2. `cargo machete` — Unused dependency check
3. `cargo clippy -- -D warnings` — Linting
4. `cargo test` — Unit tests
5. `cargo build` — Build verification

## License

The Rust implementation (`raft-rs`) is licensed under the [MIT License](./raft-rs/LICENSE).

## Contact

For questions or feedback about the Rust implementation, reach out to [vaibhaw.vipul@gmail.com](mailto:vaibhaw.vipul@gmail.com).
