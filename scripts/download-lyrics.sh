#!/bin/bash

# Name of your virtual environment folder
VENV_DIR="venv"

# Dataset target directory
DATA_DIR="data/raw"
DATA_FILE="$DATA_DIR/spotify_million_song_dataset.csv"  # adjust if filename differs

# Kaggle dataset identifier
DATASET="notshrirang/spotify-million-song-dataset"

echo "Checking virtual environment..."

# Activate venv if not active
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "Virtual environment not activated. Activating..."
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment is already active."
fi

# Check if kaggle CLI is installed
if ! command -v kaggle &> /dev/null; then
    echo "Kaggle CLI not found. Installing..."
    pip install kaggle
fi

# Ensure Kaggle config is accessible
export KAGGLE_CONFIG_DIR="$HOME/.kaggle"

# Check if kaggle.json exists
if [[ ! -f "$KAGGLE_CONFIG_DIR/kaggle.json" ]]; then
    echo "Kaggle API credentials not found in $KAGGLE_CONFIG_DIR/kaggle.json"
    echo "Download it from https://www.kaggle.com/me/account"
    exit 1
fi

# Create data directory
mkdir -p "$DATA_DIR"

# Check if dataset already exists
if [[ -f "$DATA_FILE" ]]; then
    echo "Dataset already exists at $DATA_FILE. Skipping download."
else
    echo "Downloading dataset..."
    kaggle datasets download -d "$DATASET" -p "$DATA_DIR" --unzip
    echo "Dataset downloaded to $DATA_DIR."

    echo "Files in directory:"
    ls -lh "$DATA_DIR"
fi