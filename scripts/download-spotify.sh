#!/bin/bash

# Name of your virtual environment folder
VENV_DIR="venv"

# Dataset target directory
DATA_DIR="data/raw"
DATA_FILE="$DATA_DIR/spotify_tracks.csv"  # adjust if the main file has a different name

# Kaggle dataset identifier
DATASET="maharshipandya/spotify-tracks-dataset"

echo "Checking virtual environment..."

# Check if venv is activated
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "Virtual environment not activated. Activating..."
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment is already active."
fi

# Check if kaggle is installed
if ! command -v kaggle &> /dev/null; then
    echo "Kaggle CLI not found. Installing..."
    pip install kaggle
fi

# Set Kaggle config directory explicitly
export KAGGLE_CONFIG_DIR="$HOME/.kaggle"

# Check if Kaggle API credentials exist
if [[ ! -f "$KAGGLE_CONFIG_DIR/kaggle.json" ]]; then
    echo "Kaggle API credentials not found in $KAGGLE_CONFIG_DIR/kaggle.json"
    echo "Please download your kaggle.json from https://www.kaggle.com/me/account"
    exit 1
fi

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Check if dataset already exists
if [[ -f "$DATA_FILE" ]]; then
    echo "Dataset already exists at $DATA_FILE. Skipping download."
else
    echo "Downloading dataset..."
    kaggle datasets download -d "$DATASET" -p "$DATA_DIR" --unzip
    echo "Dataset downloaded to $DATA_DIR."
fi