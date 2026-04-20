#!/usr/bin/env bash
# Download vancenceho/youtube-features-clean from Hugging Face into data/processed/.
# Notebooks expect: data/processed/youtube_features_cleaned.csv
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_YOUTUBE_FEATURES_CLEAN_REPO="${HF_YOUTUBE_FEATURES_CLEAN_REPO:-vancenceho/youtube-features-clean}"
LOCAL_DIR="${HF_YOUTUBE_FEATURES_CLEAN_LOCAL_DIR:-${ROOT}/data/processed}"
MAIN_FILE="${LOCAL_DIR}/youtube_features_cleaned.csv"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# Hub may ship dataset.csv — notebooks expect youtube_features_cleaned.csv
rename_to_canonical() {
  if [[ -f "${LOCAL_DIR}/dataset.csv" ]]; then
    mv -f "${LOCAL_DIR}/dataset.csv" "$MAIN_FILE"
    echo "Renamed dataset.csv → youtube_features_cleaned.csv"
  fi
}

# Repo layout may use processed/youtube_features_cleaned.csv
flatten_processed_subdir() {
  if [[ -f "${LOCAL_DIR}/processed/youtube_features_cleaned.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
    mv -f "${LOCAL_DIR}/processed/youtube_features_cleaned.csv" "$MAIN_FILE"
    echo "Moved processed/youtube_features_cleaned.csv → youtube_features_cleaned.csv"
    rmdir "${LOCAL_DIR}/processed" 2>/dev/null || true
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

if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/processed/youtube_features_cleaned.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
  flatten_processed_subdir
  exit 0
fi

echo "Downloading ${HF_YOUTUBE_FEATURES_CLEAN_REPO} → ${LOCAL_DIR}"
# Skip Hub repo docs (does not delete an existing local data/processed/README.md you maintain yourself)
"${HF_DL[@]}" "${HF_YOUTUBE_FEATURES_CLEAN_REPO}" --repo-type dataset --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
rename_to_canonical
flatten_processed_subdir
echo "Done."
