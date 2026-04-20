#!/usr/bin/env bash
# Log in to the Hugging Face Hub (datasets & models download/upload via hf CLI).
#
# Requires: virtualenv with huggingface_hub — run: make setup   (or: make setup-huggingface)
# Token: https://huggingface.co/settings/tokens
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

HF="${ROOT}/.venv/bin/hf"
if [[ ! -x "$HF" ]]; then
  echo "hf CLI not found. Run: make setup" >&2
  exit 1
fi

echo -e "\033[36m=== Hugging Face Hub login ===\033[0m"
echo ""
echo "Create a token (read is enough for public downloads; write for uploads):"
echo "  https://huggingface.co/settings/tokens"
echo ""
echo "You will be prompted to paste your token (or use browser login if offered)."
echo ""

exec "$HF" auth login
