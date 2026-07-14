#!/usr/bin/env bash

# This script launches an isolated zsh shell session using the local built Antigen.
# It uses a temporary folder for ZDOTDIR and ADOTDIR to avoid touching your system configs.

set -euo pipefail

# Ensure antigen is built
echo "Building local antigen..."
make build

# Create a temporary directory inside the workspace
TEMP_DIR=$(mktemp -d -t antigen-manual-test-XXXXXX)
echo "Created temporary test environment at: $TEMP_DIR"

# Clean up temp dir on exit
trap 'rm -rf "$TEMP_DIR"; echo "Cleaned up temporary test environment."' EXIT

# Build isolated .zshrc
cat > "$TEMP_DIR/.zshrc" <<EOF
# Isolated ZDOTDIR and ADOTDIR
export ADOTDIR="$TEMP_DIR/.antigen"
export ANTIGEN_LOG="$TEMP_DIR/antigen.log"
export ANTIGEN_CACHE="\$ADOTDIR/init.zsh"

echo "=== Welcome to the Antigen Manual Test Shell ==="
echo "Adotdir: \$ADOTDIR"
echo "Antigen: $(pwd)/bin/antigen.zsh"
echo "================================================"
echo ""

# Load datetime module for precise time measurement
zmodload zsh/datetime
local start_time=\$EPOCHREALTIME

# Demonstrate the modern Static Sourcing pattern!
if [[ -f "\$ANTIGEN_CACHE" ]]; then
  echo "[cache] Loading from compiled cache (instant startup!)..."
  source "\$ANTIGEN_CACHE"
  local end_time=\$EPOCHREALTIME
  local elapsed=\$(( (end_time - start_time) * 1000 ))
  printf "[cache] Sourced compiled cache in %.2f ms\n" \$elapsed
else
  echo "[loader] No cache found. Sourcing antigen and compiling cache..."
  source "$(pwd)/bin/antigen.zsh"

  # Load sample plugins
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-autosuggestions

  # Apply and generate cache
  antigen apply
  local end_time=\$EPOCHREALTIME
  local elapsed=\$(( (end_time - start_time) * 1000 ))
  printf "[loader] Initial setup & cache generation completed in %.2f ms\n" \$elapsed
fi

# Set a simple prompt
PROMPT='antigen-test-env> '

echo ""
echo "Tip: To test the cache loading speed, reload the shell by running:"
echo "     source \$ZDOTDIR/.zshrc"
echo ""
EOF

# Spawn the isolated shell
echo "Spawning isolated zsh shell..."
ZDOTDIR="$TEMP_DIR" zsh -i
