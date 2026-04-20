#!/usr/bin/env bash
# Download trained ensemble / stacking artifacts from Hugging Face into notebooks/models/.
# Default: vancenceho/vcp-combined-ensemble-stacking
#
# Hub repos for weights are usually --repo-type model; if you uploaded as a dataset, set:
#   HF_REPO_TYPE=dataset
#
# Requires: pip install huggingface_hub (see: make setup)
# Private repo: hf auth login  or  export HF_TOKEN=...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${ROOT}/.venv/bin:${PATH}"

HF_VCP_ENSEMBLE_REPO="${HF_VCP_ENSEMBLE_REPO:-vancenceho/vcp-combined-ensemble-stacking}"
HF_REPO_TYPE="${HF_REPO_TYPE:-model}"
LOCAL_DIR="${HF_VCP_ENSEMBLE_LOCAL_DIR:-${ROOT}/notebooks/models}"

if command -v hf &>/dev/null; then
  HF_DL=(hf download)
elif command -v huggingface-cli &>/dev/null; then
  HF_DL=(huggingface-cli download)
else
  echo "HF CLI not found. Run: make setup  (installs huggingface_hub → hf)" >&2
  exit 1
fi

mkdir -p "$LOCAL_DIR"

# If Hub nests files under models/ or ensemble/, lift them into notebooks/models/
flatten_nested_models() {
  local sub f
  for sub in models ensemble; do
    if [[ ! -d "${LOCAL_DIR}/${sub}" ]]; then
      continue
    fi
    shopt -s nullglob
    for f in "${LOCAL_DIR}/${sub}/"*; do
      [[ -e "$f" ]] || continue
      mv -f "$f" "${LOCAL_DIR}/"
    done
    shopt -u nullglob
    rmdir "${LOCAL_DIR}/${sub}" 2>/dev/null || true
    echo "Flattened ${sub}/ into notebooks/models/"
  done
}

SKIP="${HF_SKIP_EXISTING:-1}"
if [[ "$SKIP" != "0" && "$SKIP" != "false" ]]; then
  shopt -s nullglob
  existing=( "${LOCAL_DIR}"/*.joblib "${LOCAL_DIR}"/*.pkl "${LOCAL_DIR}"/*.safetensors )
  shopt -u nullglob
  if (( ${#existing[@]} > 0 )); then
    echo "Skip: ${LOCAL_DIR} already has model artifact(s) (*.joblib / *.pkl / *.safetensors)."
    echo "      Set HF_SKIP_EXISTING=0 to re-download."
    exit 0
  fi
fi

echo "Downloading ${HF_VCP_ENSEMBLE_REPO} (repo-type=${HF_REPO_TYPE}) → ${LOCAL_DIR}"
"${HF_DL[@]}" "${HF_VCP_ENSEMBLE_REPO}" --repo-type "${HF_REPO_TYPE}" --local-dir "${LOCAL_DIR}" \
  --exclude 'README.md' --exclude 'readme.md' --exclude 'README.rst' --exclude 'README.txt' --exclude 'README'
flatten_nested_models
echo "Done."
