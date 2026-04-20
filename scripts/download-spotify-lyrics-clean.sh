#!/usr/bin/env bash
# Download vancenceho/spotify-lyrics-clean from Hugging Face into data/cleaned/.
# Notebooks expect: data/cleaned/lyrics_cleaned.csv
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_SPOTIFY_LYRICS_CLEAN_REPO="${HF_SPOTIFY_LYRICS_CLEAN_REPO:-vancenceho/spotify-lyrics-clean}"
LOCAL_DIR="${HF_SPOTIFY_LYRICS_CLEAN_LOCAL_DIR:-${ROOT}/data/cleaned}"
MAIN_FILE="${LOCAL_DIR}/lyrics_cleaned.csv"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# Hub may ship dataset.csv — notebooks expect lyrics_cleaned.csv
rename_to_canonical() {
  if [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
    mv -f "${LOCAL_DIR}/dataset.csv" "$MAIN_FILE"
    echo "Renamed dataset.csv → lyrics_cleaned.csv"
  fi
}

# Repo layout may use cleaned/lyrics_cleaned.csv
flatten_cleaned_subdir() {
  if [[ -f "${LOCAL_DIR}/cleaned/lyrics_cleaned.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
    mv -f "${LOCAL_DIR}/cleaned/lyrics_cleaned.csv" "$MAIN_FILE"
    echo "Moved cleaned/lyrics_cleaned.csv → lyrics_cleaned.csv"
    rmdir "${LOCAL_DIR}/cleaned" 2>/dev/null || true
  fi
}

SKIP="${HF_SKIP_EXISTING:-1}"
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "$MAIN_FILE" ]]; then
  echo "Skip: $MAIN_FILE already exists (set HF_SKIP_EXISTING=0 to re-download)."
  exit 0
fi

if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
  rename_to_canonical
  exit 0
fi

if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/cleaned/lyrics_cleaned.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
  flatten_cleaned_subdir
  exit 0
fi

echo "Downloading ${HF_SPOTIFY_LYRICS_CLEAN_REPO} → ${LOCAL_DIR}"
# Skip Hub repo docs (does not delete an existing local data/cleaned/README.md you maintain yourself)
"${HF_DL[@]}" "${HF_SPOTIFY_LYRICS_CLEAN_REPO}" --repo-type dataset --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
rename_to_canonical
flatten_cleaned_subdir
echo "Done."
