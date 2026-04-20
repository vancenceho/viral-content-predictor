#!/usr/bin/env bash
# Download the Spotify lyrics (Million Song-style) dataset from Hugging Face into data/raw/.
# Default repo: vancenceho/spotify-lyrics — override with HF_LYRICS_REPO if needed.
#
# Notebooks expect: data/raw/spotify_millsongdata.csv (see explore_lyrics_clean.ipynb).
# If the Hub snapshot uses dataset.csv, it is renamed to spotify_millsongdata.csv.
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_LYRICS_REPO="${HF_LYRICS_REPO:-vancenceho/spotify-lyrics}"
LOCAL_DIR="${HF_LYRICS_LOCAL_DIR:-${ROOT}/data/raw}"
MAIN_FILE="${LOCAL_DIR}/spotify_millsongdata.csv"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# Hub often ships dataset.csv — notebooks expect spotify_millsongdata.csv
rename_lyrics_csv() {
  if [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
    mv -f "${LOCAL_DIR}/dataset.csv" "$MAIN_FILE"
    echo "Renamed dataset.csv → spotify_millsongdata.csv"
  fi
}

SKIP="${HF_SKIP_EXISTING:-1}"
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "$MAIN_FILE" ]]; then
  echo "Skip: $MAIN_FILE already exists (set HF_SKIP_EXISTING=0 to re-download)."
  exit 0
fi

if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
  rename_lyrics_csv
  exit 0
fi

echo "Downloading ${HF_LYRICS_REPO} → ${LOCAL_DIR}"
# Skip Hub repo docs (does not delete an existing local data/raw/README.md you maintain yourself)
"${HF_DL[@]}" "${HF_LYRICS_REPO}" --repo-type dataset --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
rename_lyrics_csv
echo "Done."
