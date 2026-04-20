#!/usr/bin/env bash
# Download the Spotify tracks dataset from Hugging Face into data/raw/ (one-shot, full repo snapshot).
# Default repo: vancenceho/spotify-tracks — override with HF_SPOTIFY_REPO if needed.
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_SPOTIFY_REPO="${HF_SPOTIFY_REPO:-vancenceho/spotify-tracks}"
# Notebook pipeline expects CSV under data/raw/ (not ./spotify-tracks at repo root)
LOCAL_DIR="${HF_SPOTIFY_LOCAL_DIR:-${ROOT}/data/raw}"
MAIN_FILE="${LOCAL_DIR}/spotify_tracks.csv"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# Hub dataset ships as dataset.csv — notebooks expect spotify_tracks.csv
rename_dataset() {
  if [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
    mv -f "${LOCAL_DIR}/dataset.csv" "$MAIN_FILE"
    echo "Renamed dataset.csv → spotify_tracks.csv"
  fi
}

# Already have the canonical name
SKIP="${HF_SKIP_EXISTING:-1}"
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "$MAIN_FILE" ]]; then
  echo "Skip: $MAIN_FILE already exists (set HF_SKIP_EXISTING=0 to re-download)."
  exit 0
fi

# Only dataset.csv present (e.g. previous run) — rename, no download
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
  rename_dataset
  exit 0
fi

echo "Downloading ${HF_SPOTIFY_REPO} → ${LOCAL_DIR}"
# Skip Hub repo docs (does not delete an existing local data/raw/README.md you maintain yourself)
"${HF_DL[@]}" "${HF_SPOTIFY_REPO}" --repo-type dataset --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
rename_dataset
echo "Done."
