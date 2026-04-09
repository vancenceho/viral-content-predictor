#!/bin/bash
# Setup script for Kaggle API credentials

set -e

KAGGLE_DIR="$HOME/.kaggle"
KAGGLE_FILE="$KAGGLE_DIR/kaggle.json"

echo -e "\033[36m=== Kaggle Credentials Setup ===\033[0m"
echo ""

# Check if file exists
if [ -f "$KAGGLE_FILE" ]; then
    echo -e "\033[33mKaggle credentials already exist.\033[0m"
    read -p "Do you want to overwrite them? (y/N): " OVERWRITE
    
    if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
        echo "Keeping existing credentials."
        exit 0
    fi
fi

# Prompt user for credentials
read -p "Enter Kaggle Username: " KAGGLE_USERNAME
read -p "Enter Kaggle Key: " KAGGLE_KEY

# Create directory if not exists
mkdir -p "$KAGGLE_DIR"

# Create kaggle.json
cat > "$KAGGLE_FILE" <<EOL
{
  "username": "$KAGGLE_USERNAME",
  "key": "$KAGGLE_KEY"
}
EOL

# Set permissions (IMPORTANT)
chmod 600 "$KAGGLE_FILE"

echo ""
echo -e "\033[32m✓ Kaggle credentials configured successfully!\033[0m"
echo ""
echo "File: $KAGGLE_FILE"
echo ""
echo "Test with:"
echo "  kaggle datasets list"