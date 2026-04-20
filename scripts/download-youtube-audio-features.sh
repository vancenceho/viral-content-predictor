#!/usr/bin/env bash
# Download vancenceho/youtube-spotify-audio-features from Hugging Face into data/raw/.
# Notebooks expect: data/raw/audio_features.csv
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_YOUTUBE_AUDIO_REPO="${HF_YOUTUBE_AUDIO_REPO:-vancenceho/youtube-spotify-audio-features}"
LOCAL_DIR="${HF_YOUTUBE_AUDIO_LOCAL_DIR:-${ROOT}/data/raw}"
MAIN_FILE="${LOCAL_DIR}/audio_features.csv"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# Hub layout may use raw/audio_features.csv — move next to other data/raw/*.csv
flatten_audio_features() {
  if [[ -f "${LOCAL_DIR}/raw/audio_features.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
    mv -f "${LOCAL_DIR}/raw/audio_features.csv" "$MAIN_FILE"
    echo "Moved raw/audio_features.csv → audio_features.csv"
    rmdir "${LOCAL_DIR}/raw" 2>/dev/null || true
  fi
}

SKIP="${HF_SKIP_EXISTING:-1}"
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "$MAIN_FILE" ]]; then
  echo "Skip: $MAIN_FILE already exists (set HF_SKIP_EXISTING=0 to re-download)."
  exit 0
fi

# Nested path only (e.g. previous partial download)
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]] && [[ -f "${LOCAL_DIR}/raw/audio_features.csv" ]] && [[ ! -f "$MAIN_FILE" ]]; then
  flatten_audio_features
  exit 0
fi

echo "Downloading ${HF_YOUTUBE_AUDIO_REPO} → ${LOCAL_DIR}"
# Skip Hub repo docs (does not delete an existing local data/raw/README.md you maintain yourself)
"${HF_DL[@]}" "${HF_YOUTUBE_AUDIO_REPO}" --repo-type dataset --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
flatten_audio_features
echo "Done."
