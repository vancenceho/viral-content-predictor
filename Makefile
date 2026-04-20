.PHONY: help setup venv cleanup setup-kaggle check-kaggle init-kaggle download-spotify download-lyrics download-youtube-audio-features download-spotify-tracks-clean download-spotify-lyrics-clean download-youtube-features-clean

# Colors
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
BLUE   = \033[0;34m
NC     = \033[0m

# Targets
VENV_DIR := .venv
PYTHON := ${VENV_DIR}/bin/python
PIP := ${VENV_DIR}/bin/pip

help: ## Show the commands and their descriptions
	@echo "$(BLUE)=== Makefile Commands ===$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "Use 'make <command>' to run a command."
	@echo "Use 'make help' to show the commands and their descriptions."

cleanup: ## Clean up the project
	@echo "${YELLOW}Cleaning up...${NC}"
	rm -rf ${VENV_DIR}
	rm -f data/raw/*.csv
	rm -f data/raw/*.zip
	rm -f data/raw/*.gz
	rm -f data/raw/*.bz2
	rm -f data/raw/*.tar
	rm -f data/raw/*.tgz
	rm -f data/raw/*.tar.gz
	rm -f data/raw/*.tar.bz2
	rm -f data/raw/*.tar.gz
	rm -f data/processed/*.csv
	rm -f data/processed/*.zip
	rm -f data/processed/*.gz
	rm -f data/processed/*.bz2
	rm -f data/processed/*.tar
	rm -f data/processed/*.tgz
	rm -f data/processed/*.tar.gz
	rm -f data/processed/*.tar.bz2
	rm -f data/processed/*.tar.gz
	rm -f secrets.sh
	@echo "${GREEN}Cleaned up successfully!${NC}"

# ------------------------------------------------------------
# Custom targets
# ------------------------------------------------------------

setup-kaggle: ## Setup kaggle credentials
	@echo "${YELLOW}Setting up Kaggle credentials...${NC}"
	bash scripts/setup-kaggle.sh
	@echo "${GREEN}Kaggle credentials setup successfully!${NC}"
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1) Activate venv, run: 'source ${VENV_DIR}/bin/activate'"
	@echo "  2) Install Kaggle API, run: 'pip install kaggle' (if not already installed)"
	@echo "  3) Verify Kaggle API, run: 'kaggle -version'"


venv: ## Create a virtual environment if it doesn't exist
	@if [ ! -d "${VENV_DIR}" ]; then \
		echo "${YELLOW}Creating virtual environment...${NC}"; \
		${PYTHON} -m venv ${VENV_DIR}; \
		echo "${GREEN}Virtual environment created successfully!${NC}"; \
	fi

setup: venv ## Install the dependencies, if venv doesn't exist
	@echo "${YELLOW}Installing dependencies...${NC}"
	${PIP} install -r requirements.txt
	@echo "${GREEN}Dependencies installed successfully!${NC}"


download-spotify: setup ## Download Spotify tracks from Hugging Face (vancenceho/spotify-tracks → data/raw/)
	@echo "${YELLOW}Downloading Spotify dataset...${NC}"
	bash scripts/download-spotify.sh
	@echo "${GREEN}Spotify dataset downloaded successfully!${NC}"

download-lyrics: setup ## Download Spotify lyrics from Hugging Face (vancenceho/spotify-lyrics → data/raw/spotify_millsongdata.csv)
	@echo "${YELLOW}Downloading Lyrics dataset...${NC}"
	bash scripts/download-lyrics.sh
	@echo "${GREEN}Lyrics dataset downloaded successfully!${NC}"

download-youtube-audio-features: setup ## Download YouTube/Spotify audio features (vancenceho/youtube-spotify-audio-features → data/raw/)
	@echo "${YELLOW}Downloading youtube-spotify-audio-features...${NC}"
	bash scripts/download-youtube-audio-features.sh
	@echo "${GREEN}Download finished.${NC}"

download-spotify-tracks-clean: setup ## Download cleaned Spotify tracks (vancenceho/spotify-tracks-clean → data/cleaned/)
	@echo "${YELLOW}Downloading spotify-tracks-clean...${NC}"
	bash scripts/download-spotify-tracks-clean.sh
	@echo "${GREEN}Download finished.${NC}"

download-spotify-lyrics-clean: setup ## Download cleaned lyrics (vancenceho/spotify-lyrics-clean → data/cleaned/lyrics_cleaned.csv)
	@echo "${YELLOW}Downloading spotify-lyrics-clean...${NC}"
	bash scripts/download-spotify-lyrics-clean.sh
	@echo "${GREEN}Download finished.${NC}"

download-youtube-features-clean: setup ## Download cleaned YouTube features (vancenceho/youtube-features-clean → data/processed/)
	@echo "${YELLOW}Downloading youtube-features-clean...${NC}"
	bash scripts/download-youtube-features-clean.sh
	@echo "${GREEN}Download finished.${NC}"