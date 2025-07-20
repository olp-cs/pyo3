#!/bin/bash
set -e

echo "🚀 Setting up PyO3 development environment..."

# Create cache directories
mkdir -p .devcontainer/cache/cargo-registry
mkdir -p .devcontainer/cache/cargo-git
mkdir -p .devcontainer/cache/target

# Install system dependencies that mirror CI
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    valgrind \
    zstd \
    mingw-w64 \
    llvm \
    clang

# Install Python dependencies
python -m pip install --upgrade pip
pip install nox

# Install additional Rust toolchain components used in CI
rustup component add rustfmt clippy rust-src

# Install additional Rust targets used in CI
rustup target add \
    x86_64-pc-windows-gnu \
    x86_64-pc-windows-msvc \
    i686-pc-windows-msvc \
    aarch64-pc-windows-msvc \
    wasm32-unknown-emscripten \
    wasm32-wasip1 \
    powerpc64le-unknown-linux-gnu \
    s390x-unknown-linux-gnu

# Install additional tools used in CI
cargo install cargo-semver-checks
cargo install cargo-hack
cargo install cargo-minimal-versions
cargo install cargo-careful
cargo install cargo-xwin

# Install nightly toolchain for some CI jobs
rustup toolchain install nightly
rustup component add --toolchain nightly rust-src

# Install beta toolchain for regression testing
rustup toolchain install beta
rustup component add --toolchain beta rust-src clippy

# Set up git (if not already configured)
if ! git config --global user.name >/dev/null 2>&1; then
    git config --global user.name "Dev Container User"
    git config --global user.email "dev@example.com"
fi

# Initialize Rust cache to avoid initial slow builds
echo "🔧 Warming up Rust cache..."
if [ -f Cargo.toml ]; then
    cargo check --all-features || true
fi

echo "✅ Development environment setup complete!"
echo ""
echo "Available nox sessions:"
nox -l
echo ""
echo "Quick start commands:"
echo "  nox -s ruff        # Python linting"
echo "  nox -s rustfmt     # Rust formatting"
echo "  nox -s clippy-all  # Rust linting"
echo "  nox -s test        # Run tests"
echo "  cargo check        # Quick Rust check"